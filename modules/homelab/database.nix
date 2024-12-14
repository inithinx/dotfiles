{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  services.postgresql = {
    enable = true;
    dataDir = "/data/postgresql/";
    ensureDatabases = [
      "nextcloud"
      "secvault"
    ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
      {
        name = "secvault";
        ensureDBOwnership = true;
      }
    ];
  };

}
