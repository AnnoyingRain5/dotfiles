{
  inputs,
  pkgs,
  lib,
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
      package =
        inputs.flake-firefox-nightly.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin;
      nativeMessagingHosts = with pkgs; [
        firefoxpwa
      ];
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
        monado = pkgs.monado.overrideAttrs (oldAttrs: {
          pname = "monado-pimax"; # optional but helps distinguishing between packages
          src = pkgs.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "AnnoyingRain5";
            repo = "monado";
            rev = "b347eded0f2c012103754c7533651d7b6083131c";
            hash = "sha256-/47Hm+kWXCMKEA1W/SioYk92uB0k1tusk1FudsVJJMQ=";
          };
          nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.libgbinder ];
          propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or [ ]) ++ [ pkgs.libgbinder ];
          postFixup = ''
            patchelf $out/bin/monado-service --add-rpath ${pkgs.libgbinder}/lib
          '';
          cmakeFlags = [
            (lib.cmakeFeature "GIT_DESC" "Pimax-Fork")
          ];
          patches = (oldAttrs.patches or [ ]) ++ [
            #patches/monado-waydroid.patch
          ];
        });
      in
      {
        wlx-overlay-s = {
          name = "wlx-overlay-s";
          genericName = "VR Overlay";
          exec = "LIBMONADO_PATH=${monado}/lib/libmonado.so wayvr --openxr";
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
        monado = pkgs.monado.overrideAttrs (oldAttrs: {
          pname = "monado-pimax"; # optional but helps distinguishing between packages
          src = pkgs.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "AnnoyingRain5";
            repo = "monado";
            rev = "b347eded0f2c012103754c7533651d7b6083131c";
            hash = "sha256-/47Hm+kWXCMKEA1W/SioYk92uB0k1tusk1FudsVJJMQ=";
          };
          nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.libgbinder ];
          propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or [ ]) ++ [ pkgs.libgbinder ];
          postFixup = ''
            patchelf $out/bin/monado-service --add-rpath ${pkgs.libgbinder}/lib
          '';
          cmakeFlags = [
            (lib.cmakeFeature "GIT_DESC" "Pimax-Fork")
          ];
          patches = (oldAttrs.patches or [ ]) ++ [
            #patches/monado-waydroid.patch
          ];
        });
      in
      ''
        {
          "file_format_version": "1.0.0",
          "runtime": {
              "name": "Monado",
              "library_path": "${monado}/lib/libopenxr_monado.so",
              "MND_libmonado_path": "${monado}/lib/libmonado.so"
          }
        }
      '';
    xdg.configFile."openxr/1/active_runtime.i686.json".source =
      let
        p = pkgs.pkgsi686Linux;
        pkg = pkgs.pkgsi686Linux.monado.overrideAttrs (prev: {
          pname = "monado-server-lib";
          nativeBuildInputs = with p; [
            cmake
            git
            glslang
            pkg-config
            python3
          ];
          buildInputs = with p; [
            boost
            eigen
            glm
            libdrm
            nlohmann_json
            openxr-loader
            udev
            vulkan-headers
            vulkan-loader
            hidapi
          ];
          cmakeFlags = [
            (lib.cmakeBool "XRT_MODULE_MONADO_CLI" false)
            (lib.cmakeBool "XRT_MODULE_MONADO_GUI" false)
            (lib.cmakeBool "XRT_MODULE_COMPOSITOR" true)
            (lib.cmakeFeature "GIT_DESC" "Pimax-Fork")
            (lib.cmakeBool "XRT_OPENXR_INSTALL_ABSOLUTE_RUNTIME_PATH" true)
          ];
          src = pkgs.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "AnnoyingRain5";
            repo = "monado";
            rev = "b347eded0f2c012103754c7533651d7b6083131c";
            hash = "sha256-/47Hm+kWXCMKEA1W/SioYk92uB0k1tusk1FudsVJJMQ=";
          };
        });
      in
      "${pkg}/share/openxr/1/openxr_monado.json";

    xdg.configFile."openvr/openvrpaths.vrpath".text = ''
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
          "/run/current-system/sw/lib/xrizer"
        ],
        "version" : 1
      }
    '';
  };
}
