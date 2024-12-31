{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.proxy;

  # Script to generate nginx configs at runtime
  nginxConfigScript = pkgs.writeShellScript "generate-nginx-config" ''
    # Read domains from agenix secret files
    MAIN_DOMAIN=$(cat ${config.age.secrets.domain.path})
    PERSONAL_DOMAIN=$(cat ${config.age.secrets.personaldomain.path})

    # Create nginx config directory if it doesn't exist
    mkdir -p /etc/nginx/sites-enabled

    # Function to create a virtual host config
    create_vhost() {
      local subdomain=$1
      local port=$2
      cat > "/etc/nginx/sites-enabled/$subdomain.conf" << EOF
    server {
      listen 443 ssl http2;
      server_name $subdomain.$MAIN_DOMAIN;

      ssl_certificate /var/lib/acme/$MAIN_DOMAIN/fullchain.pem;
      ssl_certificate_key /var/lib/acme/$MAIN_DOMAIN/key.pem;

      location / {
        proxy_pass http://127.0.0.1:$port/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
      }
    }
    EOF
    }

    # Generate media stack configs if enabled
    ${optionalString (config.mediastack.enable or false) ''
      create_vhost "sonarr" "8989"
      create_vhost "radarr" "7878"
      create_vhost "prowlarr" "9696"
      create_vhost "jellyfin" "8096"
      create_vhost "media" "8096"
      create_vhost "jellyseerr" "5055"
      create_vhost "request" "5055"
      create_vhost "deluge" "8112"
      create_vhost "flare" "8191"
    ''}

    # Create catch-all redirect config
    cat > "/etc/nginx/sites-enabled/catch-all.conf" << EOF
    server {
      listen 443 ssl http2;
      server_name *.$MAIN_DOMAIN;

      ssl_certificate /var/lib/acme/$MAIN_DOMAIN/fullchain.pem;
      ssl_certificate_key /var/lib/acme/$MAIN_DOMAIN/key.pem;

      return 301 https://$PERSONAL_DOMAIN\$request_uri;
    }
    EOF

    # Test nginx config
    nginx -t && systemctl reload nginx
  '';
in
{
  options.proxy = {
    enable = mkEnableOption "Proxy service";
  };

  config = mkIf cfg.enable {
    # Automatically enable if mediastack is enabled
    proxy.enable = mkDefault (config.mediastack.enable or false);

    # Nginx user setup
    users.users.nginx.extraGroups = [ "acme" ];

    # Nginx service configuration
    services.nginx = {
      enable = true;
      package = pkgs.nginxQuic;

      # Security and optimization settings
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

      # Use include directive for dynamic configs
      appendConfig = ''
        include /etc/nginx/sites-enabled/*.conf;
      '';
    };

    # Systemd service to generate nginx configs
    systemd.services.nginx-config-gen = {
      description = "Generate Nginx configurations";
      wantedBy = [ "nginx.service" ];
      before = [ "nginx.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = nginxConfigScript;
      };
      # Ensure the service runs when secrets change
      reloadTriggers = [
        config.age.secrets.domain.path
        config.age.secrets.personaldomain.path
      ];
    };
  };
}
