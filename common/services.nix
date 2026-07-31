{ pkgs, ... }:

let
  chargenScript = pkgs.writeShellScript "chargen" ''
    trap "" PIPE
    while :; do
      for i in $(seq 0 94); do
        line=""
        for j in $(seq 0 71); do
          n=$(( (i + j) % 95 + 33 ))
          line+=$(printf "\\$(printf '%03o' "$n")")
        done
        echo "$line" || exit 0
      done
    done
  '';

  chargenLine = pkgs.writeShellScript "chargen-udp-line" ''
    n=$(( (RANDOM % 512) + 1 ))
    tr -dc '\041-\176' < /dev/urandom | head -c "$n"
    echo
  '';

  mkTcp =
    {
      name,
      port,
      exec,
      output ? "socket",
    }:
    {
      "${name}" = {
        description = "${name} protocol socket (TCP, port ${toString port})";
        listenStreams = [ (toString port) ];
        socketConfig.Accept = true;
        wantedBy = [ "sockets.target" ];
      };
    };

  mkUdp =
    {
      name,
      port,
      exec,
    }:
    {
      description = "${name} protocol (UDP, port ${toString port})";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.socat}/bin/socat UDP4-RECVFROM:${toString port},fork ${exec}";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        DynamicUser = true;
        Restart = "on-failure";
      };
    };
in
{
  systemd.sockets = {
    daytime.listenStreams = [ "13" ];
    daytime.socketConfig.Accept = true;
    daytime.wantedBy = [ "sockets.target" ];
    echo.listenStreams = [ "7" ];
    echo.socketConfig.Accept = true;
    echo.wantedBy = [ "sockets.target" ];
    discard.listenStreams = [ "9" ];
    discard.socketConfig.Accept = true;
    discard.wantedBy = [ "sockets.target" ];
    chargen.listenStreams = [ "19" ];
    chargen.socketConfig.Accept = true;
    chargen.wantedBy = [ "sockets.target" ];
  };

  systemd.services = {
    "daytime@".serviceConfig = {
      ExecStart = "${pkgs.coreutils}/bin/date";
      StandardInput = "socket";
      StandardOutput = "socket";
    };
    "echo@".serviceConfig = {
      ExecStart = "${pkgs.coreutils}/bin/cat";
      StandardInput = "socket";
      StandardOutput = "socket";
    };
    "discard@".serviceConfig = {
      ExecStart = "${pkgs.coreutils}/bin/cat";
      StandardInput = "socket";
      StandardOutput = "null";
    };
    "chargen@".serviceConfig = {
      ExecStart = "${chargenScript}";
      StandardInput = "socket";
      StandardOutput = "socket";
    };

    "udp-daytime" = mkUdp {
      name = "Daytime";
      port = 13;
      exec = "EXEC:${pkgs.coreutils}/bin/date";
    };
    "udp-echo" = mkUdp {
      name = "Echo";
      port = 7;
      exec = "EXEC:${pkgs.coreutils}/bin/cat";
    };
    "udp-discard" = mkUdp {
      name = "Discard";
      port = 9;
      exec = "OPEN:/dev/null,wronly";
    };
    "udp-chargen" = mkUdp {
      name = "Chargen";
      port = 19;
      exec = "EXEC:${chargenLine}";
    };
  };

  networking.firewall.allowedTCPPorts = [
    7
    9
    13
    19
  ];
  networking.firewall.allowedUDPPorts = [
    7
    9
    13
    19
  ];
}
