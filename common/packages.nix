
{ neovim-nightly-overlay, pkgs, rustPlatform, ...}:

let 
lumin = pkgs.rustPlatform.buildRustPackage {
	pname = "lumin";
	version = "git";

	src = pkgs.fetchFromGitHub {
		owner = "Kn4ughty";
		repo = "lumin";
		rev = "main";
		hash = "sha256-cCA3DLSOtvxGFKiYBVrgYeLZkjLWlpR5ogm2xHQ6bxw=";
	};

	cargoHash = "sha256-VG1y4vMyTPpiqa8MYQcarC8ILXzv6f9NQsZqf2EOG4M=";

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
		mbuffer
		upower
		(python3.withPackages (python-pkgs: with python-pkgs; [
      		requests
			watchdog
			colour
            hid
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
        osu-lazer-bin
		libreoffice-fresh
		mpv
		krita
        gimp
		gvfs
		sshfs
		distrobox
		evil-helix
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
		package = neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
	};
	programs.steam = {
		enable = true;
	};
    programs.dconf.enable = true;

    hardware.keyboard.qmk.enable = true;

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
