{ inputs, ... }: {

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz"; 
    packages = with pkgs; [ terminus_font ];
    keyMap = "us";
    #useXkbConfig = true; # use xkb.options in tty.
  };

  # Set up user and his shell.
  users.users.nithin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    initialPassword = "30028060";
    shell = pkgs.zsh;
    home = "/home/nithin";
  };
  programs.zsh = {
    enable = true;
    shellInit = "pfetch";
    vteIntegration = true;
    syntaxHighlighting.enable = true;
    autoenv.enable = true;
    autosuggestions = {
      enable = true;
      async = true;
    };
  };
  programs.starship.enable = true;

  # Programs to be installed system-wide.
  environment.systemPackages =  with pkgs; [ 
    # Bare minimum.
    btop 
    git 
    ripgrep 
    jq 
    pfetch-rs 
    neovim 

    # Shell and some essentials.
    zoxide
    bat
    fzf
    starship
    zellij
    yt-dlp
    docker

    # System utils.
    gptfdisk
    efibootmgr
    power-profiles-daemon
    rustscan

    # Graphical and apps.
    firefox
    xwaylandvideobridge
    gamescope
    steam
    slack
    discord
    amberol
    spot
    jellyfin
    neovide
    alacritty
    # Catppuccin
    catppuccinifier-gui
    catppuccin-gtk
    catppuccin-cursors
    catppuccin-papirus-folders 
  ]; 

  # Set up GNOME
  services.xserver = {
  enable = true;
  displayManager.gdm.enable = true;
  desktopManager.gnome.enable = true;
  };
  # Debloat GNOME
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    ]) ++ (with pkgs.gnome; [
    gnome-music
    gnome-terminal
    epiphany # web browser
    geary # email reader
    gnome-characters
    gnome-font-viewer
    gnome-maps
    gnome-logs
    totem # video player
  ]);

  # Switch to pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Set up printing and avahi for auto-discovery.
  services.printing.enable = true;
  services.avahi = {
  enable = true;
  nssmdns4 = true;
  #openFirewall = true;
  };

  # Set environment variables
  environment.variables = {
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
    MOZ_ENABLE_WAYLAND= 1;
  };

  # Some nice stuff
  programs.direnv.enable = true;
  programs.neovim.vimAlias = true;
  programs.autojump.enable = true;

  # Set up NIX itself. 
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 3d";
  };
  nix.optimise.automatic = true;
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
  };
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  system.stateVersion = "24.05"; # Did you read the comment?
}
