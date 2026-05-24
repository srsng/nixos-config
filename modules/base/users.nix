{
  lib,
  pkgs,
  myvars,
  ...
}:
{
  # TODO
  # programs.ssh = myvars.networking.ssh;

  users.users.${myvars.user.name} = {
    description = myvars.user.fullname;
    isNormalUser = true;
    extraGroups = [
      myvars.user.name
      "networkmanager"
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = myvars.user.ssh_authorized_keys;
    shell = pkgs.${lib.toLower myvars.user.shell};
  };

  # shell
  programs.${lib.toLower myvars.user.shell}.enable = true;
}
