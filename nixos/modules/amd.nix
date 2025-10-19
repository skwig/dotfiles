{
  config,
  pkgs,
  pkgs-pr,
  ...
}:

{
  hardware.graphics = {
    enable = true;
    package = pkgs-pr.mesa;
  };
}
