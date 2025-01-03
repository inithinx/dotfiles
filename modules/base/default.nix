{
  config,
  lib,
  pkgs,
  inputs ? { },
  ...
}:
with lib;
let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in
{
  imports = [
    inputs.disko.nixosModules.default
    inputs.self.nixosModules.secureboot
    inputs.self.nixosModules.impermanence
  ];
  options.base = {
    enable = mkEnableOption "Enable base system configuration";

    hostname = mkOption {
      type = types.str;
      description = "System hostname";
      example = "citadel";
    };

    username = mkOption {
      type = types.str;
      description = "Primary user username";
      example = "john";
    };

    hashedPassword = mkOption {
      type = types.str;
      description = "Hashed password for the primary user";
      example = "";
    };
  };

  config = mkIf config.base.enable {
    boot = {
      kernelPackages = pkgs.linuxPackages_zen;
      consoleLogLevel = 0;
      kernelParams = [
        "quiet"
        "splash"
        "page_alloc.shuffle=1" # Memory management performance
      ];
      initrd = {
        systemd.enable = true;
        verbose = false;
      };
      loader = {
        timeout = 0;
        systemd-boot = {
          enable = true;
          consoleMode = "max";
          extraInstallCommands = ''
            if [ ! -d "/persist/etc/secureboot/keys" ]; then
              sbctl create-keys
            fi
          '';
        };
        efi.canTouchEfiVariables = true;
      };
      plymouth = {
        enable = true;
        theme = "bgrt";
      };
    };

    # System hardening
    security = {
      sudo = {
        wheelNeedsPassword = true;
        execWheelOnly = true;
      };
      rtkit.enable = true;
      polkit.enable = true;
      protectKernelImage = true;
      forcePageTableIsolation = true;
    };

    # SSD optimizations
    services.udev.extraRules = ''
      # Set scheduler for NVMe
      ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
      # Set scheduler for SSD and eMMC
      ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    '';

    nixpkgs = {
      config = {
        allowUnfree = true;
      };
      hostPlatform = lib.mkDefault "x86_64-linux";
    };

    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 3d";
      };
      settings = {
        trusted-users = [ "${config.base.username}" ];
        experimental-features = [
          "nix-command"
          "flakes"
          "recursive-nix"
        ];
        flake-registry = "";
        auto-optimise-store = true;
        # Garbage collection settings

        keep-outputs = true;
        keep-derivations = true;
      };

      channel.enable = false;
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
      optimise.automatic = true;
    };

    # Enable system auto-upgrade
    system.autoUpgrade = {
      enable = true;
      allowReboot = true;
    };

    # Network configuration
    networking = {
      hostName = config.base.hostname;
      firewall = {
        enable = true;
        allowPing = true;
        allowedTCPPorts = [ 22 ];
        allowedUDPPorts = [ ];
      };
      networkmanager.enable = true;
    };

    # Console configuration
    console = {
      earlySetup = true;
      font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz";
      packages = with pkgs; [ terminus_font ];
      keyMap = "us";
    };

    # User configuration
    users.users.${config.base.username} = {
      isNormalUser = true;
      hashedPassword = config.base.hashedPassword;
      shell = pkgs.zsh;
      home = "/home/${config.base.username}";
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "audio"
        "input"
        "docker"
        "libvirtd"
      ];
    };

    # Program configurations
    programs = {
      zsh = {
        enable = true;
        shellInit = "pfetch";
        vteIntegration = true;
        syntaxHighlighting.enable = true;
        autosuggestions.enable = true;
        shellAliases = {
          cat = "bat --color=auto";
          grep = "grep --color=auto";
          v = "nvim";
        };
      };
      neovim.vimAlias = true;
      dconf.enable = true;
      command-not-found.enable = true;
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };

    # System packages
    environment = {
      systemPackages = with pkgs; [
        # Basic system utilities
        wget
        curl
        git
        htop
        neovim
        ripgrep
        fd
        file
        which
        tree
        psmisc
        zip
        unzip
        lsof
        usbutils
        pciutils
        dig
        ethtool
        zoxide
        bat
        pfetch

        # System monitoring
        bottom
        iotop
        lm_sensors
        smartmontools

        # Network utilities
        mtr
        iperf
        nmap

        # System utilities
        parted
        gptfdisk
        cryptsetup
        sbctl
      ];

      variables = {
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
      };
    };

    # Locale and timezone
    i18n = {
      defaultLocale = "en_US.UTF-8";
      supportedLocales = [
        "en_US.UTF-8/UTF-8"
      ];
    };
    time.timeZone = "Asia/Kolkata";

    # Core services
    services = {
      fstrim.enable = true;
      tailscale.enable = true;
      logrotate.enable = true;
      timesyncd.enable = true;
      smartd.enable = true; # Disk health monitoring

      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PrintLastLog = false;
          PasswordAuthentication = true;
          X11Forwarding = false;
          KbdInteractiveAuthentication = false;
          PermitEmptyPasswords = false;
        };
      };
    };
    # Enable systemd-ooomd
    systemd.oomd = {
      enable = true;
      enableSystemSlice = true;
      enableUserSlices = true;
    };

    # Memory and storage optimization
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
      priority = 10;
    };

    # Hardware configuration
    hardware = {
      enableRedistributableFirmware = true;
      enableAllFirmware = true;
      graphics.enable = true;
    };

    # TODO CHECK ALL OPTIONS BEFORE CHANGING
    system.stateVersion = "24.11";
  };
}
