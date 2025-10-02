{ pkgs, ... }:

{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  environment.systemPackages = with pkgs; [
    overskride
    blueberry
    blueman
  ];

  # Disallows mic+audio combo on BT headset,
  # making it not get grabbed and switching to a lower quality output
  services.pipewire.wireplumber.extraConfig."10-bluez" = {
    "monitor.bluez.properties" = {
      "bluez5.roles" = [
        "a2dp_sink"
        "a2dp_source"
      ];
    };
  };
}
