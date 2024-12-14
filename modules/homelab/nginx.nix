{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{

  #################
  ###### SSL ######
  #################

  security.acme = {
    # staging env, use this when testing stuff.
    #defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    acceptTerms = true;
    defaults.email = "inithin683@gmail.com";
    #defaults.group  = "acme";
    certs."${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = {
      domain = "*.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
      extraDomainNames = [
        "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}"
      ];
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets.cloudflare.path;
      #group = "acme";
    };
  };

  ###################
  ###### Nginx ######
  ###################
  #users.users.nginx.isNormalUser = false;
  users.users.nginx.extraGroups = [ "acme" ];
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;
    # Hosts and user setup
    #user = "nithin";
    #group = "users";
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
      "*.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = {
        forceSSL = true;
        useACMEHost = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
        globalRedirect = "${lib.strings.removeSuffix "\n" (
          builtins.readFile config.age.secrets.personaldomain.path
        )}";
      };
    };
  };
}
