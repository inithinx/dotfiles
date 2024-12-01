{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.coturn = {
    enable = true;
    lt-cred-mech = true;
    static-auth-secret-file = config.age.secrets.coturn.path;
    realm = "cloud.nanosec.dev";
    no-tcp-relay = true;
    extraConfig = "
      cipher-list=\"HIGH\"
      no-loopback-peers
      no-multicast-peers
    ";
    secure-stun = true;
    cert = "/var/lib/acme/${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}/fullchain.pem";
    pkey = "/var/lib/acme/${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}/key.pem";
    min-port = 49152;
    max-port = 49999;
  };
}
