{
  config,
  pkgs,
  inputs,
  lib,
  user,
  hostName,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  # Remove unecessary preinstalled packages
  environment.defaultPackages = lib.mkForce [];

  environment.sessionVariables = {GTK_USE_PORTAL = "1";};

  services.printing.enable = true;

  programs.zsh.enable = true;

  programs.wireshark.enable = true;

  environment.etc.openvpn.source = "${pkgs.update-resolv-conf}/libexec/openvpn";

  # Laptop-specific packages (the other ones are installed in `packages.nix`)
  environment.systemPackages = with pkgs; [
    acpi
    tlp
    git
    pciutils
    greetd.tuigreet
    virt-manager
    glib-networking
  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --greeting 'Welcome to PwNixOS!' --cmd Hyprland";
        user = "${user}";
      };
    };
  };

  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = lib.mkForce [];

  programs.ssh.startAgent = true;

  programs.nix-ld.enable = true;

  services.hardware.bolt.enable = true;

  virtualisation.libvirtd.enable = true; # For VMs using virt-manager.

  # Install fonts
  fonts = {
    packages = with pkgs; [
      jetbrains-mono
      roboto
      openmoji-color
      nerd-fonts.fira-code
      nerd-fonts.fantasque-sans-mono
    ];

    fontconfig = {
      hinting.autohint = true;
      defaultFonts = {
        emoji = ["OpenMoji Color"];
      };
    };
  };

  # Wayland stuff: enable XDG integration
  xdg = {
    icons.enable = true;
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };
  };

  xdg.portal.config.common.default = "*";

  # DBUS

  programs.dconf.enable = true;
  services.dbus.packages = with pkgs; [dconf];
  services.dbus.enable = true;

  services.gvfs = {
    enable = true;
    package = lib.mkForce pkgs.gnome.gvfs;
  };

  # Firmware Updater
  services.fwupd.enable = true;

  # Nix settings, auto cleanup and enable flakes
  nix = {
    settings.auto-optimise-store = true;
    settings.allowed-users = ["${user}"];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    settings.substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        # "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org"

        # "https://mirrors.ustc.edu.cn/nix-channels/store"  # 中科大
        # "https://mirrors.cernet.edu.cn/nix-channels/store" # mirrorz
        # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"  # 清华
        # "https://mirror.sjtu.edu.cn/nix-channels/store"  # 上海交大 
        # "https://mirrors.bfsu.edu.cn/nix-channels/store"  # 北外
        # "https://nix-community.cachix.org"
      ];
      settings.trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      settings.trusted-users = ["root" "sigma" "lawrence"];
    };

  };

  # Boot settings: clean /tmp/, latest kernel and enable bootloader
  boot = {
    tmp.cleanOnBoot = true;
    loader = {
      systemd-boot.enable = true;
      systemd-boot.editor = false;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
  };

  # Set up locales (timezone and keyboard layout)
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set up user and enable sudo
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = ["input" "wheel" "networkmanager" "libvirtd" "wireshark"];
    # initialHashedPassword = "$6$wqCHereET3WM6UIA$XeJIgGkmO2/zAkktN2JCx5hLNS3kSj6seVQBdSWoMeJ5MOrIha6B/HiDjHI4oKDKYhYVwjgQFqGpncU6OI7Ud/"; # password: d3fault
    shell = pkgs.zsh;
  };

  # Set up networking and secure it
  networking = {
    networkmanager.enable = true;
    hostName = "${hostName}";
    firewall.enable = false; # This one is necessary to expose ports to the netwok. Usefull for smbserver, responder, http.server, ...
    extraHosts = ''
    ''; # For adding hosts.
  };

  # Set environment variables
  environment.variables = {
    NIXOS_CONFIG_DIR = "$HOME/.config/nixos/";
    NIXPKGS_ALLOW_INSECURE = "1";
    XDG_DATA_HOME = "$HOME/.local/share";
    GTK_RC_FILES = "$HOME/.local/share/gtk-1.0/gtkrc";
    GTK2_RC_FILES = "$HOME/.local/share/gtk-2.0/gtkrc";
    MOZ_ENABLE_WAYLAND = "1";
    EDITOR = "nvim";
    DIRENV_LOG_FORMAT = "";
    ANKI_WAYLAND = "1";
    DISABLE_QT5_COMPAT = "0";
    LIBSEAT_BACKEND = "logind";
    GTK_USE_PORTAL = "1";
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  environment.localBinInPath = true;
  # Security
  security = {
    sudo.enable = true;
    # Extra security
    protectKernelImage = true;
    pam.services.hyprlock = {};
  };

  # Enable Bluetooth
  hardware = {
    bluetooth.enable = true;
  };

  # Kerberos
  security.krb5.enable = true;

  services.blueman.enable = true;

  # Do not touch
  system.stateVersion = "24.05";
}
