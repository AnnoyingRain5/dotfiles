# Global configuration file, shared among all systems

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports = [ ./home.nix ];


  boot = {
    # graphical decryption splash screen
    initrd.systemd.enable = true;
    kernelParams = [ "quiet" ];
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    plymouth = {
      enable = true;
      theme = "breeze";
    };

    loader = {
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

  };

  networking = {
    networkmanager.enable = true;

    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    firewall.enable = false;

    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_AU.UTF-8";
    extraLocaleSettings.LC_ALL = "en_AU.UTF-8";
    inputMethod = {
      enabled = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
        ];
      };
    };
  };

  environment.plasma6.excludePackages = with pkgs.libsForQt5;
    [
      elisa # do not install Elisa
    ];

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

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
    ffmpeg

    #shared folder for VM
    virtiofsd

    # idevice support
    libimobiledevice
    ifuse

    ## graphical apps ##

    # games
    lutris
    prismlauncher
    r2modman
    osu-lazer-bin

    # chat
    discord-canary
    telegram-desktop

    # emulators
    dolphin-emu
    # here lies citra and yuzu...
    ryujinx
    xemu
    cemu

    # kde apps that should be installed by default
    kate
    plasma-vault
    cryfs # needed for plasma-vault re: https://github.com/NixOS/nixpkgs/issues/273046
    kcalc
    k3b
    ktorrent

    # windows compatability - wine and proton stuff
    wineWowPackages.stable
    winetricks
    protontricks

    # libreoffice
    libreoffice-qt
    hunspell
    hunspellDicts.en_AU

    # TAFE course
    teams-for-linux
    python3
    jetbrains.pycharm-community
    blender

    # programming
    (vscode-with-extensions.override {
      vscodeExtensions = with inputs.nix-vscode-extensions.extensions.x86_64-linux.vscode-marketplace; [
        ms-dotnettools.csharp
        njpwerner.autodocstring
        samuelcolvin.jinjahtml
        ms-python.black-formatter
        jongrant.csharpsortusings
        csharpier.csharpier-vscode
        ms-azuretools.vscode-docker
        tamasfe.even-better-toml
        github.vscode-github-actions
        visualstudioexptteam.vscodeintellicode
        visualstudioexptteam.intellicode-api-usage-examples
        # ms-dotnettools.csdevkit # this seems to be broken?
        # ms-dotnettools.vscodeintellicode-csharp # also broken ):
        wholroyd.jinja
        yandeu.five-server
        ms-python.vscode-pylance
        ms-python.python
        qwtel.sqlite-viewer
        jnoortheen.nix-ide
      ];
    }
    )
    jetbrains.rider
    unityhub # installed 2022.3.6f1 using the uri: unityhub://2022.3.6f1/b9e6e7e9fa2d

    # other
    firefox
    filezilla
    kleopatra
    keepassxc
    feishin
    vlc
    obs-studio
    cura
    nextcloud-client
    yubioath-flutter

    # development (Crank It Up)
    dotnetCorePackages.sdk_6_0
    xorg.libXi
    dotnet-runtime
    libglvnd
    udev

    (import
      (builtins.fetchTarball {
        url = "https://github.com/AnnoyingRain5/Rains-NUR/archive/refs/tags/v2.tar.gz";
        sha256 = "sha256:0g08rc92q9n5vvnr2w51alr1z38nf12c23frzjag25xf3g4qw6p4";
      })
      { inherit pkgs; }).discord-krisp-patcher
  ];
  xdg.portal = {
    enable = true;
  };

  programs = {
    steam.enable = true;
    partition-manager.enable = true;
    kdeconnect.enable = true;
    virt-manager.enable = true;
    dconf.enable = true; # requires for home-manager gtk
    direnv.enable = true;

    git = {
      enable = true;
      config = {
        user.name = "AnnoyingRains";
        user.email = "annoyingrain5@gmail.com";
        commit.gpgsign = true;
        user.signingkey = "F42DAC9E42C738BC";
      };
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = lib.mkForce pkgs.pinentry-qt;
    };

  };

  services = {
    desktopManager.plasma6.enable = true;
    # openssh.enable = true;
    printing.enable = true;
    # required for yubiauth
    pcscd.enable = true;

    # rule 1: 3d printer (?)
    # rule 2: Nintendo Switch (RCM)
    udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0660", TAG+="uaccess"

      SUBSYSTEM=="usb", ATTR{idVendor}=="0955", MODE="0664", GROUP="plugdev"
    '';

    # enable Avahi, adds IPP Everywhere support for printing
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };
    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      displayManager.defaultSession = "plasma";
      xkb.layout = "au";
      xkb.variant = "";
    };

    flatpak = {
      enable = true;
      remotes = {
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        "nheko-nightlies" = "https://raw.githubusercontent.com/Nheko-Reborn/nheko/master/nheko-nightly.flatpakrepo"; # impure flake go BRRR
      };
      packages = [
        "nheko-nightlies:app/im.nheko.Nheko//master"
        "flathub:app/dev.slimevr.SlimeVR/x86_64/stable"
      ];
    };

    pipewire = {
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

    monado = {
      enable = true;
      defaultRuntime = true;
    };

  };

  # add japanese font that does not look like pixelart
  fonts.packages = with pkgs; [
    ipafont
    (import
      (builtins.fetchTarball {
        url = "https://github.com/AnnoyingRain5/Rains-NUR/archive/refs/tags/v2.tar.gz";
        sha256 = "sha256:0zxm2kz92h8qcrrjlg7q3ppci237z1hy4w6y97al6i8x6i131iyy";
      })
      { inherit pkgs; }).avali-scratch
  ];

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1"; # force electron apps to run on wayland
    interactiveShellInit = ''
      alias nano=micro
      unset SSH_AGENT_PID
      if [ "''${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
        export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
      fi
      export GPG_TTY=$(tty)
      gpg-connect-agent updatestartuptty /bye >/dev/null
    '';
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
