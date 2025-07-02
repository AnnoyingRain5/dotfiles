{
  config,
  lib,
  nixpkgs,
  inputs,
  outputs,
  pkgs,
  ...
}:
{
  # do something with home-manager here, for instance:
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager.backupFileExtension = "home-manager-bak";
  home-manager.users.annoyingrains = {
    # The home.stateVersion option does not have a default and must be set
    home.stateVersion = "23.11";
    # Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ];

    programs.firefox = {
      enable = true;
      package = inputs.flake-firefox-nightly.packages.${pkgs.system}.firefox-nightly-bin;
      profiles.annoyingrains = {
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          dearrow
          sponsorblock
          clearurls
          plasma-integration
          return-youtube-dislikes
          reddit-moderator-toolbox
          user-agent-string-switcher
          keepassxc-browser
          streetpass-for-mastodon
          pwas-for-firefox
        ];
        settings = {
          "signon.rememberSignons" = false;
        };
      };
    };

    # https://nixos.wiki/wiki/Virt-manager
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };

    # write sshcontrol with my gpg/ssh keygrip.
    # This allows me to ssh using my GPG key
    home.file.".gnupg/sshcontrol" = {
      source = dotfiles/sshcontrol;
    };

    # Configure GPG to work with pcscd
    # https://blog.apdu.fr/posts/2019/06/gnupg-and-pcsc-conflicts/
    home.file.".gnupg/scdaemon.conf" = {
      source = dotfiles/scdaemon.conf;
    };

    xdg.desktopEntries =
      let
        monado = pkgs.monado.overrideAttrs {
          pname = "monado-pimax"; # optional but helps distinguishing between packages

          src = pkgs.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "Coreforge";
            repo = "monado";
            rev = "a82eef73be841aff1324d32dbe9a031c6c0417c8";
            hash = "sha256-Y96L4DU9bJWIoNg1YhpbAkZHnk9RUEslb2Fn0aPF6zQ=";
          };
        };
      in
      {
        wlx-overlay-s = {
          name = "wlx-overlay-s";
          genericName = "VR Overlay";
          exec = "LIBMONADO_PATH=${pkgs.monado}/lib/libmonado.so wlx-overlay-s --openxr";
          terminal = true;
          categories = [ "Application" ];
          mimeType = [ ];
        };
        start-monado = {
          name = "Start Monado";
          genericName = "VR Compositor";
          exec = "systemctl --user start monado";
          terminal = false;
          categories = [ "Application" ];
          mimeType = [ ];
        };
        stop-monado = {
          name = "Stop Monado";
          genericName = "VR Compositor";
          exec = "systemctl --user stop monado";
          terminal = false;
          categories = [ "Application" ];
          mimeType = [ ];
        };
      };

    xdg.configFile."openxr/1/active_runtime.json".text =
      let
        monado = pkgs.monado.overrideAttrs {
          pname = "monado-pimax"; # optional but helps distinguishing between packages

          src = pkgs.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "Coreforge";
            repo = "monado";
            rev = "a82eef73be841aff1324d32dbe9a031c6c0417c8";
            hash = "sha256-Y96L4DU9bJWIoNg1YhpbAkZHnk9RUEslb2Fn0aPF6zQ=";
          };
        };
      in
      ''
        {
          "file_format_version": "1.0.0",
          "runtime": {
              "name": "Monado",
              "library_path": "${pkgs.monado}/lib/libopenxr_monado.so"
          }
        }
      '';

    xdg.configFile."openvr/openvrpaths.vrpath".text =
      let
        opencomposite = pkgs.opencomposite;
        #opencomposite = pkgs.opencomposite.overrideAttrs (
        #finalAttrs: previousAttrs: {
        #  src = pkgs.fetchFromGitLab {
        #    domain = "gitlab.com";
        #    owner = "peelz";
        #   repo = "OpenOVR";
        #    rev = "0ef5dd023fb196bace7c6edc8588b2dedb113da0";
        #    hash = "sha256-WG+51mX5gK/yyUikzXT19H/UVk294QD6HgM9zJNC2b0=";
        #    fetchSubmodules = true;
        #  };
        #  buildInputs = previousAttrs.buildInputs ++ [
        #    pkgs.autoconf
        #    pkgs.automake
        #    pkgs.libtool
        #  ];
        #}
        #);
      in
      ''
        {
          "config" :
          [
            "~/.local/share/Steam/config"
          ],
          "external_drivers" : null,
          "jsonid" : "vrpathreg",
          "log" :
          [
            "~/.local/share/Steam/logs"
          ],
          "runtime" :
          [
            "${opencomposite}/lib/opencomposite"
          ],
          "version" : 1
        }
      '';
  };
}
