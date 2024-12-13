{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{

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
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    #extraGroups = [ "wheel" "acme" "render" "video" ]; # Enable ‘sudo’ for the user.
    #initialPassword = "30028060";
    hashedPassword = "$6$PNGk/swUJ0h./tHi$AKLpLyVpEAPxDXNDnpHe45.mCeYgt0yhnklvJ6xSgISW2AoV1WFRW9TXce79V1OpujRf3JpR1JF0HXugp.HEW1";
  };
  programs.bash.shellInit = "pfetch";

  environment.systemPackages = with pkgs; [
    inputs.agenix.packages."x86_64-linux".default
    htop-vim
    git
    ripgrep
    jq
    pfetch-rs
    neovim
    tree
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  fileSystems."/persist".neededForBoot = true;

  # Set up a network bridge on the host
  networking = {
    bridges = {
      br0 = {
        interfaces = [ "enp7s0" ];
        rstp = false;
      };
    };
    # Disable DHCP on the physical interface since it's now part of the bridge, then enable dhcp for bridge.
    interfaces.enp7s0.useDHCP = false;
    interfaces.br0.useDHCP = true;
  };

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
