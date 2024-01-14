{ inputs, config, pkgs, username, hostname, gitUsername, theLocale, theTimezone, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # needed for keychron k2
    extraModprobeConfig = ''
      options hid_apple fnmode=2
    '';
    kernelModules = [ "hid-apple" ];
  };

  # Networking
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

  # Timezone
  time.timeZone = theTimezone;

  # Locale
  i18n = {
    defaultLocale = theLocale;
    extraLocaleSettings = {
      LC_ADDRESS = theLocale;
      LC_IDENTIFICATION = theLocale;
      LC_MEASUREMENT = theLocale;
      LC_MONETARY = theLocale;
      LC_NAME = theLocale;
      LC_NUMERIC = theLocale;
      LC_PAPER = theLocale;
      LC_TELEPHONE = theLocale;
      LC_TIME = theLocale;
    };
  };

  # User account
  users.users."${username}" = {
    homeMode = "755";
    isNormalUser = true;
    description = gitUsername;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    curl
    htop
    git
    nodejs_20
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Steam Configuration
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Nvidia & OpenGL
  hardware = {
    bluetooth.enable = true;
    nvidia = {
      open = false;
      nvidiaSettings = true;
      powerManagement.enable = true;
      # powerManagement.finegrained = false;
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    enableNvidiaPatches = true;
  };

  # Some programs need SUID wrappers, can be configured further or are started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:
  services.openssh.enable = true;
  services.fstrim.enable = true;
  services.xserver = {
    enable = true;
    layout = "pl";
    xkbVariant = "";
    libinput.enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };

  # Configure console keymap
  console.keyMap = "pl2";

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  hardware.pulseaudio.enable = false;
  sound.enable = true;
  security.rtkit.enable = true;

  programs.thunar.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  system.stateVersion = "23.11";
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Set Environment Variables
  environment.variables = {
    NIXOS_OZONE_WL = "1";
    PATH = [
      "\${HOME}/.local/bin"
      "\${HOME}/.cargo/bin"
      "\$/usr/local/bin"
    ];
    NIXPKGS_ALLOW_UNFREE = "1";
    SCRIPTDIR = "\${HOME}/.local/share/scriptdeps";
    STARSHIP_CONFIG = "\${HOME}/.config/starship/starship.toml";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    GDK_BACKEND = "wayland";
    CLUTTER_BACKEND = "wayland";
    SDL_VIDEODRIVER = "x11";
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
