
{ pkgs, inputs, rustPlatform, ...}:

let 
lumin = pkgs.rustPlatform.buildRustPackage {
	pname = "lumin";
	version = "git";

	src = pkgs.fetchFromGitHub {
		owner = "Kn4ughty";
		repo = "lumin";
		rev = "main";
		hash = "sha256-O7yCs7PU8/fp2CQOND6UyUWKxZ74gSQxHIRcuBB+L74=";
	};

	cargoHash = "sha256-LfDrzFKozidp+7gmNSONet7hV2lIRlluwx9KjYZtZb8=";

	nativeBuildInputs = [
		pkgs.pkg-config
	];

	buildInputs = with pkgs; [
		openssl
	];
};
eww = pkgs.rustPlatform.buildRustPackage {
	pname = "eww-fork";
	version = "git";

	src = pkgs.fetchFromGitHub {
		owner = "Kn4ughty";
		repo = "eww";
		rev = "main";
		hash = "sha256-1OeU2RMC+ZY4UW/ASI/8IPL1WnV9/q6vdqxHP/n+oRs";
	};

	cargoHash = "sha256-Kf99eojqXvdbZ3eRS8GBgyLYNpZKJGIJtsOsvhhSVDk=";

	nativeBuildInputs = [
		pkgs.pkg-config
	];
	buildInputs = with pkgs; [
		glib
		gtk3
		libdbusmenu-gtk3
		gtk-layer-shell
	];
};
bacon = pkgs.bacon.overrideAttrs (oldAttrs: {
    cargoBuildFlags = (oldAttrs.cargoBuildFlags or []) ++ [ "--features" "sound" ];
    buildInputs = (oldAttrs.buildInputs or []) ++ [ pkgs.alsa-lib ];
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.pkg-config ];
});

    # https://github.com/NixOS/nixpkgs/issues/530702
blender_wrapped = (pkgs.symlinkJoin {
      name = "blender_wrapped";
      paths = [
        (pkgs.pkgsRocm.blender.override {
          waylandSupport = true;
        })
      ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/blender \
          --set LD_PRELOAD "${pkgs.rocmPackages.rocm-comgr}/lib/libamd_comgr.so.3"
      '';
    });
in
{
	environment.systemPackages = with pkgs; [
		lumin
		eww
        # inputs.confetti.packages.${pkgs.system}.default
        blender_wrapped
        quickshell
		fish
        direnv
		lazygit
        rustup
        # Superseded by rustup
		# cargo
		# rustc
        bacon
		gnumake
        just
		gcc
		nasm
		qemu
        gdb
        perf
        jre
		ccls
		asm-lsp
		pkg-config
		wayland
		libxkbcommon
		jq
		unzip
		lsof
        cloc
		usbutils
		ffmpeg
        exiftool
        flac
		yt-dlp
		mpc
		rmpc
		mpd-mpris
        euphonica
		cava
		ripgrep
        bat
		mbuffer
		upower
		(python3.withPackages (python-pkgs: with python-pkgs; [
      		requests
			watchdog
			colour
            hid
            pillow
            python-mpd2
		]))
		vim
        tree-sitter
        qbittorrent
        wget
		nmap
		bluetui
        hyfetch
		macchina
        btop
        swayfx
		swaylock
		hyprlock
        hyprpolkitagent
        hyprpicker
		swayidle
		wayvnc
		slurp
		grim
		wl-clipboard-rs
        wtype
        wev
		wlsunset
		# wayscriber. # its too buggy
        kitty
        ghostty
		brightnessctl
		playerctl
		wiremix
		pulseaudio # for pactl
		pavucontrol
		dua
        fd
        neovide
		firefox
        zathura
		chromium
		hugo
        qmk
		qmk-udev-rules
        screen
        dos2unix
		via
		usbmuxd
		arduino-ide
		arduino-cli
		netcat
        localsend
        socat
		killall
        git
		github-cli
        stow
		bibata-cursors
		obsidian
        obs-studio
		anki-bin
		vesktop
		signal-desktop
		cosmic-files
        yazi
		kdePackages.dolphin
        kdePackages.qtdeclarative
        adwaita-icon-theme
        olympus
        gamemode
        prismlauncher
        # lunarclient
        ckan
        osu-lazer-bin
		libreoffice-fresh
		mpv
        unrar-free
        feh
		krita
        audacity
        miraclecast
        gimp
		gvfs
		sshfs
        cifs-utils
		distrobox
        drm_info
		evil-helix
        wireshark
        bottles
        rocmPackages.rocm-smi
        amdgpu_top
        radeontop
		nerd-fonts.jetbrains-mono
	];


	fonts.packages = with pkgs; [
		nerd-fonts.jetbrains-mono
		noto-fonts-cjk-sans
		noto-fonts
		noto-fonts-color-emoji
        nasin-nanpa
        lexend
	];

	services.udev.packages = with pkgs; [ via ];
	
	programs.neovim = {
		enable = true;
        defaultEditor = true;
	};
    programs.gamemode.enable = true;
	programs.steam = {
		enable = true;
        gamescopeSession.enable = true;
	};
    programs.dconf.enable = true;
    programs.wireshark.enable = true;



    hardware.keyboard.qmk.enable = true;

    # nixpkgs.config.rocmSupport = true;

	programs.nix-ld.enable = true;
	programs.nix-ld.libraries = with pkgs; [
		libX11
		libXcursor
        libxcb
        libXi
        libxkbcommon
		wayland
		libGL
		fontconfig
		fribidi
		freetype
		expat
		harfbuzz
		libgbm
		libdrm
		libgpg-error
		e2fsprogs
		glib
		gmp
		mesa
		libglvnd
		openssl
		ghidra-bin
        libxext
	];
}
