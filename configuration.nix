# Global configuration file, shared among all systems

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./home.nix
    ./vr.nix
  ];

  nix.settings = {
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
  };

  boot = {
    # graphical decryption splash screen
    initrd.systemd.enable = true;
    kernelParams = [
      "quiet"
      "nouveau.config=NvGspRm=1"
    ];
    kernel.sysctl."kernel.sysrq" = 502; # REISUB
    kernelPackages = pkgs.linuxPackages_xanmod;
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    # don't actually need to boot from nfs, https://github.com/NixOS/nixpkgs/issues/76671
    supportedFilesystems = [ "nfs" ];
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
    extraLocaleSettings.LC_CTYPE = "en_AU.UTF-8";
    extraLocaleSettings.LC_COLLATE = "en_AU.UTF-8";
    inputMethod.type.fcitx5 = {
      enabled = true;
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };
  };

  environment.plasma6.excludePackages = with pkgs.libsForQt5; [
    elisa # do not install Elisa
  ];

  services.pulseaudio.enable = false;

  # TODO re-enable
  #hardware.new-lg4ff.enable = true;
  hardware.flipperzero.enable = true;
  hardware.openrazer = {
    enable = true;
    users = [ "annoyingrains" ];
    keyStatistics = true;
  };
  security.rtkit.enable = true;

  users.groups = {
    openrazer = {
      members = [ "annoyingrains" ];
    };
    plugdev = {
      members = [ "annoyingrains" ];
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    annoyingrains = {
      isNormalUser = true;
      initialHashedPassword = "$y$j9T$BmeHPNCIt5arCWvzXqXNC1$JVAMf3j1FTZtD7m5Iq16qEUspVXZqKYGF835qmU7jy2";
      description = "AnnoyingRains";
      extraGroups = [
        "networkmanager"
        "wheel"
        "wireshark"
        "docker"
        "adbusers"
        "plugdev"
        "openrazer"
      ];
      packages = with pkgs; [
        # using system packages instead
      ];
    };
    luca = {
      isNormalUser = true;
      initialHashedPassword = "$y$j9T$BmeHPNCIt5arCWvzXqXNC1$JVAMf3j1FTZtD7m5Iq16qEUspVXZqKYGF835qmU7jy2";
      description = "Luca Tails";
      extraGroups = [ "networkmanager" ];
      packages = with pkgs; [
        # using home-manager
      ];
    };
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "electron-33.4.11" ];
  };

  programs.obs-studio = {
    enable = true;

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ### standard non-system specific packages go here ###

    ## command line utilities ##
    wget
    nixfmt-rfc-style
    sshfs
    killall
    unzip
    git
    micro
    gnupg
    htop
    nixpkgs-fmt # mainly used in vscode
    pciutils
    ffmpeg
    distrobox
    unrar
    freenect
    kinect-audio-setup
    android-tools
    nfs-utils
    usbutils
    yt-dlp

    #shared folder for VM
    virtiofsd

    # idevice support
    libimobiledevice
    ifuse

    ## graphical apps ##

    # games
    heroic
    lutris
    prismlauncher
    r2modman
    osu-lazer-bin
    bs-manager

    # chat
    discord-canary
    vesktop
    telegram-desktop
    thunderbird

    # emulators
    dolphin-emu
    #(dolphin-emu.overrideAttrs (oldAttrs: {
    #  pname = "dolphin-xr";
    #  src = pkgs.fetchFromGitHub {
    #    owner = "mxmstr";
    #    repo = "dolphin";
    #    rev = "4face6cb1c5ef15c024a72943a147ba34d5ebfb2";
    #    hash = "sha256-WnxbDfbbJYuJNIbHmVo0hdA47Zw+MNa/ka00FkiAE+c=";
    #    fetchSubmodules = true;
    #    leaveDotGit = true;
    #    postFetch = ''
    #      pushd $out
    #      git rev-parse HEAD 2>/dev/null >$out/COMMIT
    #      find $out -name .git -print0 | xargs -0 rm -rf
    #      popd
    #    '';
    #    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.openvr ];
    #  };
    #}))
    # here lies citra and yuzu...
    ryubing
    xemu
    cemu

    # kde apps that should be installed by default
    kdePackages.kate
    kdePackages.plasma-vault
    cryfs # needed for plasma-vault re: https://github.com/NixOS/nixpkgs/issues/273046
    kdePackages.kcalc
    #k3b - broken?
    kdePackages.ktorrent
    kdePackages.qtwebsockets # needed for https://github.com/korapp/plasma-homeassistant

    # windows compatability - wine and proton stuff
    wineWowPackages.stable
    winetricks
    protontricks

    # libreoffice
    libreoffice-qt
    hunspell
    hunspellDicts.en_AU

    # TAFE course
    blender-hip

    # programming
    (vscode-with-extensions.override {
      vscodeExtensions = with inputs.nix-vscode-extensions.extensions.x86_64-linux.vscode-marketplace; [
        ms-vsliveshare.vsliveshare
        #ms-dotnettools.csharp
        njpwerner.autodocstring
        samuelcolvin.jinjahtml
        ms-python.black-formatter
        jongrant.csharpsortusings
        csharpier.csharpier-vscode
        ms-azuretools.vscode-docker
        tamasfe.even-better-toml
        geequlim.godot-tools
        github.vscode-github-actions
        visualstudioexptteam.vscodeintellicode
        visualstudioexptteam.intellicode-api-usage-examples
        # ms-dotnettools.csdevkit # this seems to be broken?
        # ms-dotnettools.vscodeintellicode-csharp # also broken ):
        wholroyd.jinja
        yandeu.five-server
        #ms-python.vscode-pylance
        ms-python.python
        ms-python.debugpy
        qwtel.sqlite-viewer
        jnoortheen.nix-ide
      ];
    })
    (pkgs.python3Full.withPackages (ppkgs: [
      ppkgs.tkinter
      ppkgs.requests
      ppkgs.pyusb
      ppkgs.tqdm
      ppkgs.hidapi
    ]))
    libusb1

    # So I can SSH into an old Apple TV, I wish I was joking
    (pkgs.openssh.overrideAttrs (oldAttrs: {
      # Add the configure flag that previously enabled DSA.
      configureFlags = (oldAttrs.configureFlags or [ ]) ++ [ "--enable-dsa-keys" ];
    }))

    libgpod
    rhythmbox
    hidapi
    jetbrains.pycharm-professional
    jetbrains.rider
    nodejs
    #TODO uncomment when fixed https://github.com/NixOS/nixpkgs/issues/418451
    #unityhub # installed 2022.3.6f1 using the uri: unityhub://2022.3.6f1/b9e6e7e9fa2d

    # other
    gimp3
    polychromatic
    ladybird
    godot
    ungoogled-chromium
    firefoxpwa
    filezilla
    kdePackages.kleopatra
    keepassxc
    qflipper
    mitmproxy
    prusa-slicer
    feishin
    mangohud
    vlc
    fx_cast_bridge
    wireshark
    #cura https://github.com/NixOS/nixpkgs/issues/186570
    nextcloud-client
    yubioath-flutter

    # development (Crank It Up)
    #dotnetCorePackages.sdk_6_0
    xorg.libXi
    #dotnet-runtime
    libglvnd
    udev

    (import (builtins.fetchTarball {
      url = "https://github.com/AnnoyingRain5/Rains-NUR/archive/refs/tags/v2.tar.gz";
      sha256 = "sha256:0g08rc92q9n5vvnr2w51alr1z38nf12c23frzjag25xf3g4qw6p4";
    }) { inherit pkgs; }).discord-krisp-patcher
  ];
  xdg.portal = {
    enable = true;
  };

  programs = {
    steam = {
      enable = true;
      extraCompatPackages = [
        pkgs.proton-ge-bin
        pkgs.steam-play-none
        pkgs.proton-ge-rtsp-bin
      ];
      gamescopeSession = {
        enable = true;
        args = [ "-O DP-1" ];
      };
    };
    partition-manager.enable = true;
    kdeconnect.enable = true;
    virt-manager.enable = true;
    dconf.enable = true; # requires for home-manager gtk
    direnv.enable = true;
    calls.enable = true;
    wireshark.enable = true;
    adb.enable = true;
    nix-ld.enable = true;

    firefox = {
      enable = true;
      package = inputs.flake-firefox-nightly.packages.${pkgs.system}.firefox-nightly-bin;
      nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
    };

    appimage = {
      enable = true;
      package = pkgs.appimage-run.override {
        extraPkgs = pkgs: [
          pkgs.kdePackages.kirigami
          pkgs.kdePackages.kirigami-addons
          pkgs.libsForQt5.kirigami2
          pkgs.qt6.full
          pkgs.qt5.full

        ];
      };
      binfmt = true;
    };

    git = {
      enable = true;
      config = {
        user.name = "AnnoyingRains";
        user.email = "annoyingrain5@gmail.com";
        commit.gpgsign = true;
        user.signingkey = "F42DAC9E42C738BC";
      };
    };

    java = {
      enable = true;
      package = (pkgs.jdk.override { enableJavaFX = true; });
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = lib.mkForce pkgs.pinentry-qt;
    };

  };

  services = {
    desktopManager.plasma6.enable = true;
    openssh.enable = true;
    printing.enable = true;
    # required for yubiauth
    pcscd.enable = true;
    tailscale.enable = true;
    rpcbind.enable = true;
    hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
    };

    # rule 1: 3d printer (?)
    # rule 2: Nintendo Switch (RCM)
    # rule 3: G29 racing wheel
    # rule 4, 5: pimax 5kx
    # rule 6, 7, 8: xbox 360 kinect
    udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0660", TAG+="uaccess"

      SUBSYSTEM=="usb", ATTR{idVendor}=="0955", MODE="0664", GROUP="plugdev"

      SUBSYSTEMS=="hid", KERNELS=="0003:046D:C24F.????", DRIVERS=="logitech", RUN+="/bin/sh -c 'chmod 666 %S%p/../../../range; chmod 777 %S%p/../../../leds/ %S%p/../../../leds/*; chmod 666 %S%p/../../../leds/*/brightness'"

      SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="0101", MODE="666", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl"
      KERNEL=="hidraw*", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="0101", MODE="666", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl"

      SUBSYSTEMS=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02b0" MODE="777", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ad" MODE="777", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ae" MODE="777", TAG+="uaccess"
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
      xkb.layout = "au";
      xkb.variant = "";
    };

    displayManager = {
      sddm.enable = true;
      sddm.wayland.enable = false;
      defaultSession = "plasma";
    };

    flatpak = {
      enable = true;
      remotes = {
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        "nheko-nightlies" =
          "https://raw.githubusercontent.com/Nheko-Reborn/nheko/master/nheko-nightly.flatpakrepo"; # impure flake go BRRR
      };
      packages = [
        "nheko-nightlies:app/im.nheko.Nheko//master"
      ];
    };

    pipewire = {
      enable = true;
      #wireplumber.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      raopOpenFirewall = true;
      extraConfig.pipewire = {
        "10-airplay" = {
          "context.modules" = [
            {
              name = "libpipewire-module-raop-discover";

              # increase the buffer size if you get dropouts/glitches
              args = {
                roap.discover-local = true; # docs are unclear which is correct, seems to work fine tho so... eh
                raop.discover-local = true;
                raop.latency.ms = 500;
              };
            }
          ];
        };
      };
      # If you want to use JACK applications, uncomment this
      jack.enable = true;
    };
  };

  fonts = {
    enableDefaultPackages = true;
    fontconfig.useEmbeddedBitmaps = true; # this is actually stupid - https://wiki.nixos.org/wiki/Fonts#Noto_Color_Emoji_doesn't_render_on_Firefox
    packages = with pkgs; [
      ipafont
      corefonts
      vistafonts
      unifont
      (import (builtins.fetchTarball {
        url = "https://github.com/AnnoyingRain5/Rains-NUR/archive/refs/tags/v2.tar.gz";
        sha256 = "sha256:0g08rc92q9n5vvnr2w51alr1z38nf12c23frzjag25xf3g4qw6p4";
      }) { inherit pkgs; }).avali-scratch
    ];
  };

  virtualisation = {
    waydroid.enable = true;
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    # for development and distrobox
    docker.enable = true;
    docker.rootless.enable = true;
    docker.rootless.setSocketVariable = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment = {
    # force electron apps to run on wayland
    sessionVariables.NIXOS_OZONE_WL = "1";

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
