{
  username,
  ...
}:

{
  home-manager.users.${username} =
    { config, ... }:
    {
      home.enableNixpkgsReleaseCheck = false;
      services.wayvnc = {
        enable = true;
        autoStart = true;
        settings = {
          address = "localhost";
          port = 17938;
        };
      };
    };
}
