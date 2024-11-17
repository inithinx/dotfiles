{ config, lib, pkgs, modulesPath, ... }: {

  services.blocky = {
    enable = true;
    settings = {
      port = 53; # Port for incoming DNS Queries.
      upstream.default = [ "https://one.one.one.one/dns-query" ];
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [ "1.1.1.4" "1.0.0.4" ];
      };
      blocking = {
        blackLists = {
          #Adblocking
    	    hagezi = ["https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/pro.plus.txt"]; 
        };
        clientGroupsBlock = { default = [ "hagezi" ]; };
      };
      customDNS = {
        customTTL = "3h";
        filterUnmappedTypes = false;
        mapping = {
          "sonarr.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = "10.0.0.3";
          "radarr.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = "10.0.0.3";
          "prowlarr.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = "10.0.0.3";
          "deluge.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = "10.0.0.3";
          "jellyfin.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = "10.0.0.3";
          "jellyseerr.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = "10.0.0.3";
          "flare.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}" = "10.0.0.3";
        };
      };
    };
  };

}
