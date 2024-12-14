{ inputs, pkgs, ... }:
{

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
    extraGroups = [
      "wheel"
      "docker"
      "adbusers"
    ]; # Enable ‘sudo’ for the user.
    hashedPassword = "$6$cvd6yB4606VxeEz1$CVl0bir4UeSd70E.Elaj5zQDFaIM3xrrmbPoMQvCO2KAh1WE9WKic2gGI3b/tP0Ywv4Z32pWQoGaj.WHlB9xq1";
    shell = pkgs.zsh;
    home = "/home/nithin";
  };
  programs.zsh = {
    enable = true;
    shellInit = "pfetch";
    vteIntegration = true;
    syntaxHighlighting.enable = true;
    autosuggestions = {
      enable = true;
    };
    shellAliases = {
      cd = "zoxide";
      cat = "bat --color=auto";
      grep = "grep --color=auto";
      v = "nvim";
    };
  };
  #programs.starship.enable = true;

  # Programs to be installed system-wide.
  programs.neovim.vimAlias = true;
  environment.systemPackages = with pkgs; [
    # Bare minimum.
    htop-vim
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
    go
    flutter
    tailwindcss
    gnumake
    templ

    # System utils.
    gptfdisk
    efibootmgr
    power-profiles-daemon

    # Graphical and apps.
    brave
    spotify
    jellyfin
  ];

  # Android stuff
  programs.adb.enable = true;
  services.udev.packages = [
    pkgs.android-udev-rules
  ];

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
  };

  services.tailscale.enable = true;
  services.logrotate.enable = true;
  services.power-profiles-daemon.enable = true;

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
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  system.stateVersion = "24.11"; # Did you read the comment?
}
