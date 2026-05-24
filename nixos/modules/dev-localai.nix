{
  lib,
  pkgs,
  pkgs-unstable,
  pkgs-cuttingedge,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    oterm
  ];

  services.open-webui = {
    enable = true;
    package = pkgs-unstable.open-webui;
    environment = {
      ENABLE_TITLE_GENERATION = "False";
      ENABLE_TAGS_GENERATION = "False";
      ENABLE_FOLLOW_UP_GENERATION = "False";
      ENABLE_AUTOCOMPLETE_GENERATION = "False";
    };
  };

  # disable autostart. Start manually by `systemctl start/stop open-webui.service`
  systemd.services.open-webui.wantedBy = lib.mkForce [ ];

  services.ollama = {
    enable = true;
    package = pkgs-cuttingedge.ollama-rocm;
  };

  # ollama create qwen3.5:2b-8k -f <(printf "FROM qwen3.5:2b\nPARAMETER num_ctx 8192\n")
  # ollama create qwen3.5:4b-8k -f <(printf "FROM qwen3.5:4b\nPARAMETER num_ctx 8192\n")
  # ollama create qwen3.5:9b-16k -f <(printf "FROM qwen3.5:9b\nPARAMETER num_ctx 16384\n")
}
