# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./keyboard_cava.nix
    ];

  # From https://nixos.wiki/wiki/ZFS
  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.loader.efi.canTouchEfiVariables = false;

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
    { device = "/dev/disk/by-id/nvme-SPCC_M.2_PCIe_SSD_AA000000000000000433_1-part1";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [{
     device = "/dev/disk/by-partuuid/8e5ec0fb-c19e-470e-85d1-d775d4949190"; 
     randomEncryption = true;
  }];

  boot.zfs.extraPools = [ "zpool" ];

  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  networking.hostId = "d34df33f";
  networking.hostName = "unicorn";


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
        target = "zfs_sync@minirack:main/${config.networking.hostName}";
		recursive = true;
		sendOptions = "w";
		source = "zpool";
	};
  };





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

