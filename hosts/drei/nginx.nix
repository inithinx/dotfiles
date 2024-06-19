{ config, lib, pkgs, modulesPath, ... }: {

#################
###### SSL ######
#################

  security.acme = {
    acceptTerms = true;
    defaults.email = "inithin683@gmail.com";
    certs."${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = {
      domain = "*.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets.cloudflare.path;
      };
  };

###################
###### Nginx ######
###################
  #users.users.nginx.isNormalUser = false;
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;
    # Hosts and user setup
    user = "nithin";
    group = "users";
    # Hardening
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    virtualHosts = {
      "deluge.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = {
        forceSSL = true;
        useACMEHost = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
        locations."/".proxyPass = "http://127.0.0.1:8112/";
      };
      "git.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = {
        forceSSL = true;
        useACMEHost = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
        locations."/".proxyPass = "http://127.0.0.1:3001";
      };
      "cloud.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = {
        forceSSL = true;
        useACMEHost = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
	      locations = { 
          "/".proxyWebsockets = true;
          # uh, equals what?
          #"~ ^\/nextcloud\/(?:index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|oc[ms]-provider\/.+|.+\/richdocumentscode\/proxy)\.php(?:$|\/)" = {};
          "~ ^(?:index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|oc[ms]-provider\/.+|.+\/richdocumentscode\/proxy)\.php(?:$|\/)" = {};
          };
      };
      "sonarr.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = {
        forceSSL = true;
        useACMEHost = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
        locations."/".proxyPass = "http://127.0.0.1:8989/";
      };
      "radarr.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = {
        forceSSL = true;
        useACMEHost = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
        locations."/".proxyPass = "http://127.0.0.1:7878/";
      };
      "prowlarr.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = {
        forceSSL = true;
        useACMEHost = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
        locations."/".proxyPass = "http://127.0.0.1:9696/";
      };
      "jellyfin.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = {
        forceSSL = true;
        useACMEHost = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
        locations."/".proxyPass = "http://127.0.0.1:8096/";
      };
      "media.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = {
        forceSSL = true;
        useACMEHost = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
        locations."/".proxyPass = "http://127.0.0.1:8096/";
        locations."/".proxyWebsockets = true;
      };
      "jellyseerr.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = {
        forceSSL = true;
        useACMEHost = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
        locations."/".proxyPass = "http://127.0.0.1:5055/";
      };
      "request.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = {
        forceSSL = true;
        useACMEHost = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
        locations."/".proxyPass = "http://127.0.0.1:5055/";
      };
      "flare.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = {
        forceSSL = true;
        useACMEHost = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
        locations."/".proxyPass = "http://127.0.0.1:8191/";
      };
      "vault.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = {
        forceSSL = true;
        useACMEHost = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
        locations."/".proxyPass = "http://127.0.0.1:8812/";
      };
      "*.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = {
        forceSSL = true;
        useACMEHost = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
        globalRedirect = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.personaldomain.path)}";
      };
    };
  };
}
