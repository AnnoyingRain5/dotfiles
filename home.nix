{ config, lib, nixpkgs, inputs, outputs, pkgs, ... }: {
  # do something with home-manager here, for instance:
  imports = [ inputs.home-manager.nixosModules.home-manager ];

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
        ];
      };
    };

    programs.vscode = {
      enable = true;
      extensions = with inputs.nix-vscode-extensions.extensions.x86_64-linux.vscode-marketplace; [
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
        #ms-dotnettools.vscodeintellicode-csharp # also broken ):
        wholroyd.jinja
        yandeu.five-server
        ms-python.vscode-pylance
        ms-python.python
        qwtel.sqlite-viewer
        jnoortheen.nix-ide
      ];
    };
    gtk = {
      enable = true;
      theme = {
        package = pkgs.gnome.gnome-themes-extra;
        name = "Breeze";
      };
    };

    # write sshcontrol with my gpg/ssh keygrip.
    # This allows me to ssh using my GPG key
    home.file.".gnupg/sshcontrol" = {
      source = dotfiles/sshcontrol;
    };

  };
}
