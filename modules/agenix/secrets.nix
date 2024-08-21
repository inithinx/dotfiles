let
  nithin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrJzcb+rSf9P+EMFbLotMomHueAvoIwk1hcibfQfsjt";
  users = [ nithin ];
  drei = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDRERTMAeoQMLapD3eI3eDzJdX68VCsI0foiZJ2UqdOD";
  systems = [ drei ];

in
{
  #"secrets/coturn.age".publicKeys = [ nithin drei ];
  "secrets/nc.age".publicKeys = [ nithin drei ];
  "secrets/vw-token.age".publicKeys = [ nithin drei ];
  #"secrets/gitea-actions.age".publicKeys = [ nithin drei ];
  "secrets/smtp-from.age".publicKeys = [ nithin drei ];
  "secrets/smtp-user.age".publicKeys = [ nithin drei ];
  "secrets/smtp-pass.age".publicKeys = [ nithin drei ];
  "secrets/smtp-host.age".publicKeys = [ nithin drei ];
  "secrets/domain.age".publicKeys = [ nithin drei ];
  "secrets/personaldomain.age".publicKeys = [ nithin drei ];
  "secrets/cloudflare.age".publicKeys = [ nithin drei ];
}
