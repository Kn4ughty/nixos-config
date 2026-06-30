# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./packages.nix
    ];


  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.d = {
    isNormalUser = true;
    extraGroups = [ "wheel" "wireshark" "gamemode" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };


  # Enable the X11 windowing system.
  #services.xserver.enable = true;


  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # List services that you want to enable:

  services.printing.enable = true;
  services.gvfs.enable = true;

  security.rtkit.enable = true;

  security.polkit.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
	#    extraConfig = {
	# pipewire.:
	#    }
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services.xserver.displayManager.lightdm.enable = false;
  services.displayManager.ly.enable = false;
  services.displayManager.ly.settings = {
	# https://codeberg.org/fairyglade/ly/src/branch/master/res/config.ini
  	animation = "colormix";
  };


  services.upower.enable = true;

  services.syncthing = {
  	enable = true;
	openDefaultPorts = true;
	user = "d";
	group = "users";
	dataDir = "/home/d/";    # Default folder for new synced folders
  };

  services.tlp.enable = true;

  services.tailscale.enable = true;
  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
        enable = true;
        userServices = true;
        addresses = true;
    };
  };

  services.mpd = {
  	enable = true;
	user = "d";
	settings.music_directory = "/home/d/Music";
	settings.audio_output = [
		{
			type = "pipewire";
			name = "Pipewire Output";
		}
	];
  };
  systemd.services.mpd.environment = {
    # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
    XDG_RUNTIME_DIR = "/run/user/1000";
  };
  # services.mpd-mpris.enable = true;
  systemd.user.services.mpd-mpris = {
  	enable = true;
	description = "mpd-mpris: An implementation of the MPRIS protocol for MPD";
	after =[ "mpd.service" ];
	wantedBy = [ "default.target" ];
	serviceConfig = {
		ExecStart = "${pkgs.mpd-mpris}/bin/mpd-mpris";
		Restart = "on-failure";
		Type = "dbus";
		BusName = "org.mpris.MediaPlayer2.mpd";
	};
  };


#   services.udev.extraRules = ''
#   KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl" 
# '';
# services.udev.extraRules = ''
# KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
# '';

  nix.settings.experimental-features = [ "flakes" "nix-command" ];

  programs.bash = {
  interactiveShellInit = ''
    export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
    eval "$(ssh-agent -s)"
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
  '';
  };

  environment.variables = {
    GTK_THEME = "Adwaita-dark";
    # ANKI_WAYLAND = "1";
    EDITOR = "nvim";
    VISUAL = "nvim";
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    BROWSER = "firefox";
    TERMINAL = "kitty";
  };

  hardware.graphics = {
      enable = true;
      enable32Bit = true;
  };
  hardware.amdgpu.opencl.enable = true;

  hardware.keyboard.qmk.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  virtualisation.podman = {
	enable = true;
	dockerCompat = true;
  };

  xdg.portal = {
      enable = true;
      wlr.enable = true;
      config.common.default = "*";
  };

  # xdg.portal = {
  #     wlr.enable = true;
  #     enable = true;
  #     extraPortals = [ 
  #       pkgs.xdg-desktop-portal-wlr 
  #       pkgs.xdg-desktop-portal-gnome 
  #     ];
  #     config = {
  #         common = {
  #             default = [ "gtk" ];
  #         };
  #     };
  # };

  fonts.fontDir.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  environment.etc."qemu/bridge.conf" = {
    text = "allow br0";
    mode = "0644";
  };

  security.wrappers.qemu-bridge-helper = {
    setuid = true;
    owner = "root";
    group = "root";
    source = "${pkgs.qemu}/libexec/qemu-bridge-helper";
  };

  # services.flatpak.enable = true;
  # systemd.services.flatpak-repo = {
  #   wantedBy = [ "multi-user.target" ];
  #   path = [ pkgs.flatpak ];
  #   script = ''
  #     flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  #   '';
  # };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
}

