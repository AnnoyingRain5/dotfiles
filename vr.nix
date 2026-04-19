{
  pkgs,
  lib,
  ...
}:

{
  services.wivrn = {
    enable = true;
  };
  services.monado = {
    enable = true;
    defaultRuntime = true;
    highPriority = true;

    package = (
      pkgs.monado.overrideAttrs (oldAttrs: {
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
        cmakeFlags = [
          (lib.cmakeFeature "GIT_DESC" "Pimax-Fork")
        ];
        postFixup = ''
          patchelf $out/bin/monado-service --add-rpath ${pkgs.libgbinder}/lib
        '';
        patches = (oldAttrs.patches or [ ]) ++ [
          #patches/monado-waydroid.patch
        ];
      })
    );
  };

  environment.systemPackages = with pkgs; [
    xrizer
    lighthouse-steamvr
    wayvr
    slimevr
    kaon
    # 32-bit support
    pkgsi686Linux.xrizer
  ];

  systemd.user.services."monado" = {
    environment = {
      STEAMVR_LH_ENABLE = "true";
      XRT_COMPOSITOR_COMPUTE = "1";
      PIMAX_CHECK_INIT = "true";
      #XRT_COMPOSITOR_SCALE_PERCENTAGE = "110";
    };
  };
}
