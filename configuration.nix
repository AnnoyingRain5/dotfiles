# Global configuration file, shared among all systems

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ ./home.nix ];
  # Bootloader.
  boot.loader = {
    grub = {
  	  enable = true;
  	  devices = [ "nodev" ];
      efiSupport = true;
  	  useOSProber = true;
    };
    efi = {
  	  canTouchEfiVariables = true;
  	  efiSysMountPoint = "/boot";
    };
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa # do not install Elisa
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "au";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # enable dconf, this is required for home-manager gtk config
  programs.dconf.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.annoyingrains = {
    isNormalUser = true;
    initialHashedPassword = "$y$j9T$BmeHPNCIt5arCWvzXqXNC1$JVAMf3j1FTZtD7m5Iq16qEUspVXZqKYGF835qmU7jy2";
    description = "AnnoyingRains";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      # using system packages instead
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ### standard non-system specific packages go here ###

    ## command line utilities ##
    wget
    git
    micro
    gnupg
    htop
    nixpkgs-fmt # mainly used in vscode
    pciutils

    ## graphical apps ##

    # games
    lutris
    prismlauncher
    r2modman

    # chat
    discord-canary

    # emulators
    dolphin-emu
    citra
    yuzu

    # kde apps that should be installed by default
    kate
    plasma-vault
    cryfs # needed for plasma-vault re: https://github.com/NixOS/nixpkgs/issues/273046
    
    # windows compatability - wine and proton stuff
    wineWowPackages.stable
    winetricks
    protontricks

    # libreoffice
    libreoffice-qt
    hunspell
    hunspellDicts.en_AU

    # other
    firefox
    filezilla
    kleopatra
    vscode
    vlc
    obs-studio
  ];
  xdg.portal = {
    enable = true;
  };

  programs.steam.enable = true;

  services.monado.enable = true;
  services.monado.defaultRuntime = true;

  services.flatpak.enable = true;
  services.flatpak.remotes = {
    "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    "nheko-nightlies" = "https://raw.githubusercontent.com/Nheko-Reborn/nheko/master/nheko-nightly.flatpakrepo"; # impure flake go BRRR
  };
  services.flatpak.packages = [
    "nheko-nightlies:app/im.nheko.Nheko//master"
  ];


  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0" # this is bad, but required for r2modman
  ];

  # for some reason, KDE partition manager needs to be enabled like this?
  programs.partition-manager.enable = true;

  programs.git = {
    enable = true;
    config = {
      user.name = "AnnoyingRains";
      user.email = "annoyingrain5@gmail.com";
    };
  };

  # add japanese font that does not look like pixelart
  fonts.packages = with pkgs; [
    ipafont
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.interactiveShellInit = ''
    alias nano=micro
    unset SSH_AGENT_PID
    if [ "''${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
      export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    fi
    export GPG_TTY=$(tty)
    gpg-connect-agent updatestartuptty /bye >/dev/null
  '';
}
