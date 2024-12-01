let
  drei = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICL4bv3e1a3VyqgpyPY4d5hFA6voobsiIvhdTnJsKcZa";
  systems = [ drei ];

in
{
  #"secrets/coturn.age".publicKeys = [ drei ];
  "secrets/nc.age".publicKeys = [ drei ];
  "secrets/smtp-from.age".publicKeys = [ drei ];
  "secrets/smtp-user.age".publicKeys = [ drei ];
  "secrets/smtp-pass.age".publicKeys = [ drei ];
  "secrets/smtp-host.age".publicKeys = [ drei ];
  "secrets/domain.age".publicKeys = [ drei ];
  "secrets/personaldomain.age".publicKeys = [ drei ];
  "secrets/cloudflare.age".publicKeys = [ drei ];
}
