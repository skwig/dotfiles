{
  username,
  ...
}:

{
  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKBYbvBqHC1HbBgrSXPVc3UDqMjCqjr/k1jqQIpnPJR skwig@blackbox"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfbf7RIFcpdW+9ryqeDoRYEeors8vMRj2ILh+UC66xm skwig@smallbox"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPK6B/HcG55FYYlfz8Ok9Z6B1L2MnEZpZqgumq7RJJSI skwig@android"
  ];

  services.openssh = {
    enable = true;
    ports = [ 17937 ];
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
