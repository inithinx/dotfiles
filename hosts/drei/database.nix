{ config, lib, pkgs, modulesPath, ... }: {
  services.postgresql = {
    enable = true;
    dataDir = "/data/postgresql/";
    ensureDatabases = [ "nextcloud" "gitea" "vaultwarden" ];
    ensureUsers = [
      { name = "nextcloud"; ensureDBOwnership = true; }
      { name = "gitea"; ensureDBOwnership = true; }
      { name = "vaultwarden" ; ensureDBOwnership = true; }
    ];
  };

}
