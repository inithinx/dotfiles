{
  config,
  lib,
  pkgs,
  inputs ? {},
  ...
}:
with lib; let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in {
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
        #systemd.enable = true;
        verbose = false;
      };
      loader = {
        timeout = 0;
        systemd-boot = {
          enable = true;
          consoleMode = "max";
        };
        efi.canTouchEfiVariables = true;
      };
      #plymouth = {
      #  enable = true;
      #  theme = "bgrt";
      #};
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
        substituters = ["https://nix-community.cachix.org"];
        trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
        trusted-users = ["${config.base.username}"];
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
      registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
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
        allowedTCPPorts = [22];
        allowedUDPPorts = [];
      };
      networkmanager.enable = true;
      interfaces.enp7s0.useDHCP = true;
      interfaces.br0.useDHCP = true;
    };

    # Console configuration
    console = {
      earlySetup = true;
      font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz";
      packages = with pkgs; [terminus_font];
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
          cat = "bat --color=auto --style=plain --paging=never";
          grep = "grep --color=auto";
          v = "nvim";
        };
      };

      starship = {
        enable = true;
        settings = {
          format = ''
            [](surface0)$os$username[](bg:peach fg:surface0)$directory[](fg:peach bg:green)$git_branch$git_status[](fg:green bg:teal)$c$rust$golang$nodejs$php$java$kotlin$haskell$python[](fg:teal bg:blue)$docker_context[](fg:blue bg:purple)$time[ ](fg:purple)$line_break$character'';

          palette = "catppuccin_mocha";

          palettes = {
            catppuccin_mocha = {
              rosewater = "#f5e0dc";
              flamingo = "#f2cdcd";
              pink = "#f5c2e7";
              orange = "#cba6f7";
              red = "#f38ba8";
              maroon = "#eba0ac";
              peach = "#fab387";
              yellow = "#f9e2af";
              green = "#a6e3a1";
              teal = "#94e2d5";
              sky = "#89dceb";
              sapphire = "#74c7ec";
              blue = "#89b4fa";
              lavender = "#b4befe";
              text = "#cdd6f4";
              subtext1 = "#bac2de";
              subtext0 = "#a6adc8";
              overlay2 = "#9399b2";
              overlay1 = "#7f849c";
              overlay0 = "#6c7086";
              surface2 = "#585b70";
              surface1 = "#45475a";
              surface0 = "#313244";
              base = "#1e1e2e";
              mantle = "#181825";
              crust = "#11111b";
            };
          };

          os = {
            disabled = false;
            style = "bg:surface0 fg:text";
            symbols = {
              Windows = "󰍲";
              Ubuntu = "󰕈";
              SUSE = "";
              Raspbian = "󰐿";
              Mint = "󰣭";
              Macos = "";
              Manjaro = "";
              Linux = "󰌽";
              Gentoo = "󰣨";
              Fedora = "󰣛";
              Alpine = "";
              Amazon = "";
              Android = "";
              Arch = "󰣇";
              Artix = "󰣇";
              CentOS = "";
              Debian = "󰣚";
              Redhat = "󱄛";
              RedHatEnterprise = "󱄛";
            };
          };

          username = {
            show_always = true;
            style_user = "bg:surface0 fg:text";
            style_root = "bg:surface0 fg:text";
            format = "[ $user ]($style)";
          };

          directory = {
            style = "fg:mantle bg:peach";
            format = "[ $path ]($style)";
            truncation_length = 3;
            truncation_symbol = "…/";
            substitutions = {
              Documents = "󰈙 ";
              Downloads = " ";
              Music = "󰝚 ";
              Pictures = " ";
              Developer = "󰲋 ";
            };
          };

          git_branch = {
            symbol = "";
            style = "bg:teal";
            format = "[[ $symbol $branch ](fg:base bg:green)]($style)";
          };

          git_status = {
            style = "bg:teal";
            format = "[[($all_status$ahead_behind )](fg:base bg:green)]($style)";
          };

          nodejs = {
            symbol = "";
            style = "bg:teal";
            format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
          };

          c = {
            symbol = " ";
            style = "bg:teal";
            format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
          };

          rust = {
            symbol = "";
            style = "bg:teal";
            format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
          };

          golang = {
            symbol = "";
            style = "bg:teal";
            format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
          };

          php = {
            symbol = "";
            style = "bg:teal";
            format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
          };

          java = {
            symbol = " ";
            style = "bg:teal";
            format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
          };

          kotlin = {
            symbol = "";
            style = "bg:teal";
            format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
          };

          haskell = {
            symbol = "";
            style = "bg:teal";
            format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
          };

          python = {
            symbol = "";
            style = "bg:teal";
            format = "[[ $symbol( $version) ](fg:base bg:teal)]($style)";
          };

          docker_context = {
            symbol = "";
            style = "bg:mantle";
            format = "[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)";
          };

          time = {
            disabled = false;
            time_format = "%R";
            style = "bg:peach";
            format = "[[  $time ](fg:mantle bg:purple)]($style)";
          };

          line_break.disabled = false;

          character = {
            disabled = false;
            success_symbol = "[](bold fg:green)";
            error_symbol = "[](bold fg:red)";
            vimcmd_symbol = "[](bold fg:creen)";
            vimcmd_replace_one_symbol = "[](bold fg:purple)";
            vimcmd_replace_symbol = "[](bold fg:purple)";
            vimcmd_visual_symbol = "[](bold fg:lavender)";
          };
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
