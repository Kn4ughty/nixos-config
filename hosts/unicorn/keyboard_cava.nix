{ pkgs, lib, ...}:

let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    hid
    colour
  ]);


  keyboardScript = pkgs.writeScriptBin "keyboard-cava" ''
#!${pythonEnv}/bin/python3
import sys
import hid
import time
import random
import os
import struct
import subprocess
import tempfile
import math
import json
import signal
from colour import Color

BARS_NUMBER = 12
OUTPUT_BIT_FORMAT = "8bit"
# OUTPUT_BIT_FORMAT = "16bit"
# RAW_TARGET = "/tmp/cava.fifo"
RAW_TARGET = "/dev/stdout"

conpat = """
[general]
bars = %d
; autosens = 0
; sensitivity = 200
[output]
method = raw
raw_target = %s
bit_format = %s
;channels = stereo
channels = mono
"""

config = conpat % (BARS_NUMBER, RAW_TARGET, OUTPUT_BIT_FORMAT)
bytetype, bytesize, bytenorm = (
    ("H", 2, 65535) if OUTPUT_BIT_FORMAT == "16bit" else ("B", 1, 255)
)

vendor_id     = 0xCB10
product_id    = 0x1656

usage_page    = 0xFF60
usage         = 0x61
report_length = 32

process = None
def signal_handler(sig, frame):
    global process
    print("Received termination signal, cleaning up...")
    if process:
        process.terminate()
    sys.exit(0)

# Register the signal handlers
signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)

def get_raw_hid_interface():
    device_interfaces = hid.enumerate(vendor_id, product_id)
    raw_hid_interfaces = [i for i in device_interfaces if i['usage_page'] == usage_page and i['usage'] == usage]

    if len(raw_hid_interfaces) == 0:
        return None

    interface = hid.Device(path=raw_hid_interfaces[0]['path'])

    print(f"Manufacturer: {interface.manufacturer}")
    print(f"Product: {interface.product}")

    return interface


def send_raw(interface, data):
    request_data = [0x00] * (report_length + 1) # First byte is Report ID
    request_data[1:len(data) + 1] = data
    request_report = bytes(request_data)

    interface.write(request_report)
    # _ = interface.read(report_length, timeout=0)


def run(interface):
    global process
    with tempfile.NamedTemporaryFile() as config_file:
        config_file.write(config.encode())
        config_file.flush()

        process = subprocess.Popen(
            ["${pkgs.cava}/bin/cava", "-p", config_file.name], stdout=subprocess.PIPE
        )
        chunk = bytesize * BARS_NUMBER
        fmt = bytetype * BARS_NUMBER

        if RAW_TARGET != "/dev/stdout":
            if not os.path.exists(RAW_TARGET):
                os.mkfifo(RAW_TARGET)
            source = open(RAW_TARGET, "rb")
        else:
            source = process.stdout

        # start_time = time.perf_counter()
        while True:
            data = source.read(chunk)
            if len(data) < chunk:
                break
            # sample = [i for i in struct.unpack(fmt, data)]  # raw values without norming
            sample = [i / bytenorm for i in struct.unpack(fmt, data)]
            assert(len(sample) == BARS_NUMBER)
            out = [int(255*i) for i in sample]
            # print(out)
            send_raw(interface, out)
            # end_time = time.perf_counter()
            # elapsed_time = (end_time - start_time) * 1000
            # print(f"Elapsed: {elapsed_time:.2f}ms")
            # start_time = time.perf_counter()



if __name__ == '__main__':
    time.sleep(10)
    interface = get_raw_hid_interface()
    if interface is None:
        sys.exit(1)

    try:
        run(interface)
    finally:
        if process:
            process.kill()
        interface.close()
        sys.exit(1)
  '';
in {
  environment.systemPackages = [ keyboardScript pkgs.cava ];
  systemd.user.services.keyboard-cava = {
    description = "Keyboard cava";
    wantedBy = [ "default.target" ];
    after = [ "sound.target" ];

    # restartIfChanged = false;

    serviceConfig = {
      ExecStart = "${keyboardScript}/bin/keyboard-cava";

      Restart="on-failure";
      RestartSec=10;

      NoNewPrivileges = true;
      PrivateTmp = true;

      KillMode = "control-group"; 
      TimeoutStopSec = 3;
    };

  };
}
