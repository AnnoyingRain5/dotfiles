{ config, lib, nixpkgs, inputs, outputs, pkgs, ... }: {
  # do something with home-manager here, for instance:
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager.backupFileExtension = ".home-manager.bak";
  home-manager.users.annoyingrains = {
    /* The home.stateVersion option does not have a default and must be set */
    home.stateVersion = "23.11";
    /* Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ]; */

    programs.firefox = {
      enable = true;
      profiles.annoyingrains = {
        extensions = with config.nur.repos.rycee.firefox-addons; [
          ublock-origin
          dearrow
          sponsorblock
          clearurls
          plasma-integration
          return-youtube-dislikes
          reddit-moderator-toolbox
          user-agent-string-switcher
          keepassxc-browser
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

    xdg.desktopEntries = {
      wlx-overlay-s = {
        name = "wlx-overlay-s";
        genericName = "VR Overlay";
        exec = "LIBMONADO_PATH=${pkgs.monado}/lib/libmonado.so wlx-overlay-s --openxr";
        terminal = true;
        categories = [ "Application" ];
        mimeType = [ ];
      };
    };

    xdg.configFile."openxr/1/active_runtime.json".text = ''
      {
        "file_format_version": "1.0.0",
        "runtime": {
            "name": "Monado",
            "library_path": "${pkgs.monado}/lib/libopenxr_monado.so"
        }
      }
    '';

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
          "${pkgs.opencomposite}/lib/opencomposite"
        ],
        "version" : 1
      }
    '';

  };
}
