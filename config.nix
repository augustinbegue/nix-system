{ config, pkgs, ... }:

{
  # Hardware / Boot config
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.enableAllFirmware = true;
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp1s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  ## Bluetooth ##
  # Enable bluetooth support
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;

  ## Sound ##
  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;

    # Enable bluetooth for pulseaudio 
    # configFile = pkgs.writeText "default.pa" ''
    #   load-module module-bluetooth-policy
    #   load-module module-bluetooth-discover
    #   ## module fails to load with 
    #   ##   module-bluez5-device.c: Failed to get device path from module arguments
    #   ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
    #   # load-module module-bluez5-device
    #   # load-module module-bluez5-discover
    # '';

    extraModules = [ 
      pkgs.pulseaudio-modules-bt
    ];
    package = pkgs.pulseaudioFull;
  };

  ## Networking ##
  # Network Manager
  networking.networkmanager.enable = true;
  # Connect to a WiFi: nmcli device wifi connect <SSID> password <PASS>

  ## SSH ##
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  ## OneDrive ##
  services.onedrive.enable = true;

  ## ZSH / OH MY ZSH ##
  # Enable zsh
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  # Package completion
  environment.pathsToLink = [ "/share/zsh" ];
  programs.zsh.promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";

  ## Graphical Interface ##
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    libinput.enable = true;

    videoDrivers = [ "amdgpu" ];

    desktopManager = {
      xterm.enable = true;
    };

    displayManager = {
      defaultSession = "none+i3";
      lightdm.enable = true;
    };

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      extraPackages = with pkgs; [
        i3lock
      ];
    };
  };

  # Enable OpenGL for 32 bits programs
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  # OpenGL packages for AMD GPUs
  hardware.opengl.extraPackages = with pkgs; [
    amdvlk
    rocm-opencl-icd
    rocm-opencl-runtime
  ];

  # Backlight control
  programs.light.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };
  users.users.abegue = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    openssh.authorizedKeys.keys = [
      # Desktop - WSL Arch
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOj0bhewnRSUbAM2AstdZFMk2VM53MDrEW7P1M2RK8I abegue@DESKTOP-76FKIPG"
    ];
  };

  ## PACKAGES ##
  nixpkgs.config = {
    allowUnfree = true;
    pulseaudio = true;
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Dev
    git
    nodejs
    # Terminal
    alacritty
    # Browsers
    google-chrome
    firefox
    discord
    discord-canary
    # System
    nixpkgs-fmt
    lsof
    clinfo
    lm_sensors
    # Utilities
    pavucontrol
    flameshot
    feh
    neofetch
    wget
    bpytop
    nnn
    # Media
    spotify
  ];

  # Install fonts from NerdFonts
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "CascadiaCode" ]; })
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      22
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

