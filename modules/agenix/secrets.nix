let
  drei = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDRERTMAeoQMLapD3eI3eDzJdX68VCsI0foiZJ2UqdOD";
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
