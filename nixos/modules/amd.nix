{
  config,
  pkgs,
  pkgs-unstable,
  pkgs-pr,
  ...
}:

{
  hardware.graphics = {
    enable = true;
    package = pkgs-pr.mesa;
  };
}
