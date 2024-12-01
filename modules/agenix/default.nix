{
  pkgs,
  lib,
  inputs,
  agenix,
  ...
}:
{

  age.secretsMountPoint = "/persist/agenix/generations";
  age.secretsDir = "/persist/agenix/secrets";
  age.identityPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets = {
    #coturn = {
    #  file = ./secrets/coturn.age;
    #  owner = "turnserver";
    #  group = "turnserver";
    #};
    #nc = {
    #  file = ./secrets/nc.age;
    #owner = "nextcloud";
    #group = "nextcloud";
    #};
    #vw-token = {
    #  file = ./secrets/vw-token.age;
    #  owner = "";
    #  group = "";
    #};
    #gitea-actions = {
    #  file = ./secrets/gitea-actions.age;
    #  owner = "gitea-runner";
    #  group = "gitea-runner";
    #};
    #smtp-from = {
    #  file = ./secrets/smtp-from.age;
    #  owner = "";
    #  group = "";
    #};
    #smtp-user = {
    #  file = ./secrets/smtp-user.age;
    #  owner = "";
    #  group = "";
    #};

    #smtp-pass = {
    #  file = ./secrets/smtp-pass.age;
    #  owner = "";
    #  group = "";
    #};
    #smtp-host = {
    #  file = ./secrets/smtp-host.age;
    #  owner = "";
    #  group = "";
    #};
    domain = {
      file = ./secrets/domain.age;
      owner = "";
      group = "";
    };
    personaldomain = {
      file = ./secrets/personaldomain.age;
      owner = "";
      group = "";
    };
    cloudflare = {
      file = ./secrets/cloudflare.age;
      owner = "";
      group = "";
    };
  };
}
