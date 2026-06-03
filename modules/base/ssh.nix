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

  users.users.${myvars.user.name}.openssh.authorizedKeys.keys = myvars.user.ssh_authorized_keys;
}
