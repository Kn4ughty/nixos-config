
{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # From https://nixos.wiki/wiki/ZFS
  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      { devices = [ "nodev"]; path = "/boot"; }
    ];
  };
  boot.zfs.forceImportRoot = false;

  fileSystems."/" =
    { device = "zpool/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/nix" =
    { device = "zpool/nix";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/var" =
    { device = "zpool/var";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/home" =
    { device = "zpool/home";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/D3D0-72A8";
      fsType = "vfat";
    };

  # swapDevices = [{
  #   device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_1TB_S7HDNJ0Y860823A_1-part2";
  #   randomEncryption = true;
  # }];

  boot.zfs.extraPools = [ "zpool" ];

  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  networking.hostId = "ddccbfbd";
  networking.hostName = "framework";

  boot.loader.efi.canTouchEfiVariables = false;



  services.fprintd.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;
  

  services.sanoid = {
  	enable = true;

	templates.production = {
		hourly = 12;
		daily = 7;
		autosnap = true;
		autoprune = true;
	};

	datasets."zpool" = {
		useTemplate = [ "production" ];
		recursive = true;
	};

  };

  services.syncoid = {
  	enable = true;
	user = "syncoid";
	sshKey = "/var/lib/syncoid/.ssh/id_ed25519";
	localSourceAllow = [ "bookmark" "hold" "send:raw" "snapshot" "destroy" "mount" ];
	# commonArgs = ["--force-delete"]; # Dangerous!

	commands."sync" = {
		target = "zfs_sync@minirack:main/framework";
		recursive = true;
		sendOptions = "w";
		source = "zpool";
	};
  };
  systemd.services.syncoid-sync = {
    unitConfig.ConditionACPower = true;
  };


  hardware.bluetooth.enable = true;



  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

