
{ pkgs, rustPlatform, ...}:

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

in
{
	environment.systemPackages = with pkgs; [
		lumin
		eww
		fish
        direnv
		lazygit
		cargo
		rustc
		gnumake
		gcc
		nasm
		qemu
        gdb
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
		]))
		vim
        tree-sitter
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
		anki-bin
		vesktop
		signal-desktop
		cosmic-files
		kdePackages.dolphin
        olympus
        ckan
        osu-lazer-bin
		libreoffice-fresh
		mpv
		krita
        pkgsRocm.blender
        audacity
        gimp
		gvfs
		sshfs
		distrobox
		evil-helix
        wireshark
        rocmPackages.rocm-smi
        radeontop
		nerd-fonts.jetbrains-mono
	];


	fonts.packages = with pkgs; [
		nerd-fonts.jetbrains-mono
		noto-fonts-cjk-sans
		noto-fonts
		noto-fonts-color-emoji
	];

	services.udev.packages = with pkgs; [ via ];
	
	programs.neovim = {
		enable = true;
        defaultEditor = true;
	};
	programs.steam = {
		enable = true;
	};
    programs.dconf.enable = true;
    programs.wireshark.enable = true;

    hardware.keyboard.qmk.enable = true;

    nixpkgs.config.rocmSupport = true;

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
	];
}
