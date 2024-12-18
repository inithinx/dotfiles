{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  services.minecraft-server = {
    enable = true;
    eula = true;
    package = pkgs.papermc;
    #jvmOpts = "";
    declarative = true;
    whitelist = true;
    dataDir = "/data/minecraft";
    serverProperties = {
      allow-flight = false;
      difficulty = "normal";
      enable-command-block = false;
      force-gamemode = false;
      gamemode = "survival";
      hardcore = false;
      player-idle-timeout = 300;
      pvp = true;
      view-distance = 16;
      allow-nether = true;
      simulation-distance = 16;
      spawn-animals = true;
      spawn-monsters = true;
      spawn-npcs = true;
      spawn-protection = 16;
      generate-structures = true;
      level-name = "world";
      enforce-whitelist = true;
      white-list = true;
      broadcast-console-to-ops = true;
      broadcast-rcon-to-ops = true;
      function-permission-level = 2;
      op-permission-level = 4;
      enable-status = true;
      enforce-secure-profile = false;
      hide-online-players = false;
      max-players = 5;
      motd = "BrainDead Minecraft Server";
      online-mode = true;
      prevent-proxy-connections = false;
      server-port = 25565;
      enable-query = true;
      "query.port" = 25565;
      enable-rcon = true;
      "rcon.password" = "minecraft";
      "rcon.port" = "25575";
      require-resource-pack = false;
      entity-broadcast-range-percentage = 100;
      log-ips = false;
      max-chained-neighbor-updates = 1000000;
      max-tick-time = 60000;
      max-world-size = 29999984;
      network-compression-threshold = 256;
      rate-limit = 0;
      sync-chunk-writes = true;
      use-native-transport = true;
    };
  };

}
