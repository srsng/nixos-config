{ config, pkgs, myvars, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false; # disable password login
      KbdInteractiveAuthentication = true;
      AllowAgentForwarding = true;
      PermitRootLogin = "no";
    };
  };

  users.users.${myvars.user.name}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkNlkpg2Q3RemNZH1KtPPRd7zExMJUoKvRFQFtoHBpK srsnng@hotmail.com"
  ];
}
