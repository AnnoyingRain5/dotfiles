{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  firefoxProfile = ".mozilla/firefox/annoyingrains";
  chromeDir = "${firefoxProfile}/chrome";
  themeDir = "${chromeDir}/firefox-sweet-theme";
  firefoxSweetTheme = pkgs.fetchFromGitHub {
    owner = "EliverLara";
    repo = "firefox-sweet-theme";
    rev = "d5fdc331c75717b3be9716904cd93271b1b2df58";
    sha256 = "sha256-kefWWhDtbBhmIQPFOTXY5/2xGLqvswHvJEVK/c6+ywE="; # Replace with actual hash
  };
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  home-manager.users.annoyingrains = {

    home.file = {
      "${themeDir}".source = firefoxSweetTheme; # Copy the entire theme
      "${chromeDir}/userChrome.css".text = "@import \"firefox-sweet-theme/userChrome.css\";\n"; # Create the import file
      # Do not symlink user.js; use the programs.firefox.profiles.<name>.settings option instead
    };

    qt.kvantum = {
      enable = true;
      themes = with pkgs; [
        (sweet-nova.overrideAttrs (oldAttrs: {
          postInstall = ''
            rm $out/share/aurorae/themes/Sweet-Dark/*.svg
            sed -i 's/Shadow=false/Shadow=true/' $out/share/aurorae/themes/Sweet-Dark/Sweet-Darkrc
          '';
        }))
      ];
      settings = {
        "general" = {
          "theme" = "Sweet";
        };
      };
    };
  };
}
