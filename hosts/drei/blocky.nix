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
    };
  };

}
