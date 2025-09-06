{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  hardware.graphics = {
    enable = true;
    package = pkgs-unstable.mesa;
  };
}
