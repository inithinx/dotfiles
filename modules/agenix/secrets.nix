let
  nithin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBIW0ZZjVc3p80EuCJe3G9wDOAJVLPqIXNvS5lTbShHo";
  users = [ nithin ];
  drei = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMV+Q908j/kDRnUP1tNAXn1MQOQfC9JsNPdXaz+foT1J";
  systems = [ drei ];

in
{
  "secrets/coturn.age".publicKeys = [ nithin drei ];
  "secrets/nc.age".publicKeys = [ nithin drei ];
  "secrets/vw-token.age".publicKeys = [ nithin drei ];
  "secrets/gitea-actions.age".publicKeys = [ nithin drei ];
  "secrets/smtp-from.age".publicKeys = [ nithin drei ];
  "secrets/smtp-user.age".publicKeys = [ nithin drei ];
  "secrets/smtp-pass.age".publicKeys = [ nithin drei ];
  "secrets/smtp-host.age".publicKeys = [ nithin drei ];
  "secrets/domain.age".publicKeys = [ nithin drei ];
  "secrets/personaldomain.age".publicKeys = [ nithin drei ];
  "secrets/cloudflare.age".publicKeys = [ nithin drei ];
}
