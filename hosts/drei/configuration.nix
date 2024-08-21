{ config, lib, pkgs, ... }: {

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz"; 
    packages = with pkgs; [ terminus_font ];
    #keyMap = "us";
    #useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable sound.
  hardware.pulseaudio.enable = false;

  users.users.nithin = {
    isNormalUser = true;
    #extraGroups = [ "wheel" "acme" "nextcloud" ]; # Enable ‘sudo’ for the user.
    extraGroups = [ "wheel" "acme" "render" "video" ]; # Enable ‘sudo’ for the user.
    initialPassword = "30028060";
  };
  programs.bash.shellInit = "pfetch";

  environment.systemPackages =  with pkgs; [ htop-vim git mcrcon ripgrep jq pfetch-rs neovim docker  ]; 

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  fileSystems."/persist".neededForBoot = true;

  # Housekeeping
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 3d";
  };
  nix.optimise.automatic = true;
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
  };
  
  environment.variables = {
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };
  services.tailscale.enable = true;
  services.logrotate.enable = true;
  # OpenSSH 
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PrintLastLog = "no";
    #openFirewall = true;
  };

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  system.stateVersion = "24.05"; # Did you read the comment?
}
