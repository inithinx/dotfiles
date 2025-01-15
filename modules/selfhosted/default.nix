# modules/selfhosted/default.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  # Helper function to generate email addresses
  makeEmail = user: domain: "${user}@${domain}";
in {
  options.selfhosted = {
    enable = mkEnableOption "Enable selfhosted services stack";

    domain = mkOption {
      type = types.str;
      description = "Main domain for services";
    };

    adminEmail = mkOption {
      type = types.str;
      description = "Admin email address";
      default = makeEmail "admin" config.selfhosted.domain;
    };

    nextcloud = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Nextcloud";
      };

      subdomain = mkOption {
        type = types.str;
        default = "cloud";
        description = "Subdomain for Nextcloud";
      };
    };

    collabora = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Collabora Online";
      };

      subdomain = mkOption {
        type = types.str;
        default = "office";
        description = "Subdomain for Collabora";
      };
    };

    mail = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable mail server";
      };

      brevo = {
        user = mkOption {
          type = types.str;
          description = "Brevo SMTP username";
        };

        passwordFile = mkOption {
          type = types.path;
          description = "Path to file containing Brevo SMTP password";
        };
      };
    };
  };

  config = mkIf config.selfhosted.enable {
    # PostgreSQL configuration
    services.postgresql = {
      enable = true;
      dataDir = "/data/postgresql";
      ensureDatabases = [
        "nextcloud"
        "secvault"
      ];
      ensureUsers = [
        {
          name = "nextcloud";
          ensureDBOwnership = true;
        }
      ];
    };

    # Nextcloud configuration
    services.nextcloud = mkIf config.selfhosted.nextcloud.enable {
      enable = true;
      package = pkgs.nextcloud30;
      hostName = "${config.selfhosted.nextcloud.subdomain}.${config.selfhosted.domain}";
      home = "/data/nextcloud";
      config = {
        adminpassFile = config.age.secrets.nc.path;
        dbtype = "pgsql";
        dbuser = "nextcloud";
        dbname = "nextcloud";
        adminuser = "nithin";
        overwriteProtocol = "https";
        defaultPhoneRegion = "IN";
      };
      configureRedis = true;
      maxUploadSize = "1G";
      https = true;
      notify_push.enable = true; # Enable push notifications
      database.createLocally = true;
      poolSettings = {
        "pm" = "ondemand";
        "pm.max_children" = 32;
        "pm.process_idle_timeout" = "10s";
        "pm.max_requests" = 500;
      };
      appstoreEnable = true;
      autoUpdateApps.enable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit
          contacts
          calendar
          deck
          previewgenerator
          spreed
          ;
      };
      phpOptions."opcache.interned_strings_buffer" = "23";
      extraAppsEnable = true;
      settings = {
        enabledPreviewProviders = [
          "OC\\Preview\\BMP"
          "OC\\Preview\\GIF"
          "OC\\Preview\\JPEG"
          "OC\\Preview\\Krita"
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\MP3"
          "OC\\Preview\\OpenDocument"
          "OC\\Preview\\PNG"
          "OC\\Preview\\TXT"
          "OC\\Preview\\XBitmap"
          "OC\\Preview\\HEIC"
        ];
        logLevel = 0;
      };
    };

    # Collabora Online configuration
    services.collabora-online = mkIf config.selfhosted.collabora.enable {
      enable = true;
      port = 9980;
      extraArgs = [
        "--o:ssl.enable=false"
        "--o:ssl.termination=true"
      ];
      settings = {
        allowed_languages = "en";
        admin_console.enable = true;
      };
      aliasGroups.nextcloud = {
        host = "${config.selfhosted.nextcloud.subdomain}.${config.selfhosted.domain}";
        aliases = ["nextcloud\\.${config.selfhosted.domain}"];
      };
    };

    # Maddy mail server configuration
    services.maddy = mkIf config.selfhosted.mail.enable {
      enable = true;
      hostname = config.selfhosted.domain;
      primaryDomain = config.selfhosted.domain;
      # Use ACME certs from the proxy module
      tls = {
        loader = "file";
        certificates = [
          {
            cert = "/var/lib/acme/${config.selfhosted.domain}/fullchain.pem";
            key = "/var/lib/acme/${config.selfhosted.domain}/key.pem";
          }
        ];
      };
      config = ''
        send.smarthost {
          targets tcp://smtp-relay.brevo.com:587
          auth plain ${config.selfhosted.mail.brevo.user} {env:BREVO_PASSWORD}
          debug no
        }

        smtp tcp://0.0.0.0:25 {
          debug no
          filter {
            check_source_hostname
            check_source_mx
            check_dkim
            check_spf
            check_dmarc
          }
          dmarc yes
          delivery_target &local_mailboxes
        }

        submission tcp://0.0.0.0:587 {
          debug no
          auth &local_authdb
          filter {
            dkim
          }
          delivery_target &send.smarthost
        }

        imap tcp://0.0.0.0:143 {
          debug no
          auth &local_authdb
        }

        imaps tcp://0.0.0.0:993 {
          debug no
          auth &local_authdb
        }

        local_mailboxes {
          table sql_table {
            driver sqlite3
            dsn /var/lib/maddy/users.db
            init_tables yes
          }
        }

        local_authdb sql {
          driver sqlite3
          dsn /var/lib/maddy/users.db
          init_tables yes
        }
      '';
      environment = {
        BREVO_PASSWORD = "#${config.selfhosted.mail.brevo.passwordFile}"; # Read password at runtime
      };
    };

    # Integration between Nextcloud and mail
    services.nextcloud.settings =
      mkIf (config.selfhosted.nextcloud.enable && config.selfhosted.mail.enable)
      {
        mail_from_address = "nextcloud";
        mail_domain = config.selfhosted.domain;
        mail_smtpmode = "smtp";
        mail_smtphost = "localhost";
        mail_smtpport = 587;
      };

    # Ensure required directories exist and have correct permissions
    systemd.tmpfiles.rules = [
      "d /data/postgresql 0750 postgres postgres -"
      "d /data/nextcloud 0750 nextcloud nextcloud -"
      "d /var/lib/maddy 0750 maddy maddy -"
    ];
  };
}
