{ config, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false; # disable password login
      KbdInteractiveAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  users.users.srsnn.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkNlkpg2Q3RemNZH1KtPPRd7zExMJUoKvRFQFtoHBpK srsnng@hotmail.com"
  ];
}
