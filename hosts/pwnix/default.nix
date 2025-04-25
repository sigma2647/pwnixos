{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/intel/default.nix
    ../../modules/nvidia-optimus/default.nix
    ../../modules/podman/default.nix
    ../../modules/neo4j/default.nix
    ../../modules/logitech/default.nix
    ../../modules/waydroid/default.nix
  ];
  config.modules = {
    intel.enable = true; # Enable intel graphics
    nvidia-optimus.enable = false; # Enable Nvidia Optimus for laptoms with hybrid GPUs
    podman.enable = true;
    neo4j.enable = true; # Enable neo4j for Bloodhound - Disabled in systemd by default
    logitech.enable = true; # Enable logitech wireless for mices or keyboards.
    waydroid.enable = true; # Enable Waydroid & adb for Android mobile pentesting.
  };

  nix.settings.substituters = lib.mkForce [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    # 把官方源放在最后
    "https://cache.nixos.org"
  ];

}
