{
  config,
  pkgs,
  lib,
  ...
}:

{
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
          rev = "2b6bb0c96b48a99a3376313e9d91f75646afe6a3";
          hash = "sha256-ux/krES6Q/KDTSBhBA4+vqIBp2gK1Buu+FYhghyRGy8=";
        };
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.libgbinder ];
        propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or [ ]) ++ [ pkgs.libgbinder ];
        enableCuda = true;
        postFixup = ''
          patchelf $out/bin/monado-service --add-rpath ${pkgs.libgbinder}/lib
        '';
        patches = (oldAttrs.patches or [ ]) ++ [
          #patches/monado-load-solarxr.patch
          #patches/monado-solarxr.patch
          patches/monado-waydroid.patch
          patches/monado_beamng_patch.patch
        ];
      })
    );
  };

  environment.systemPackages = with pkgs; [
    pkgsi686Linux.opencomposite
    xrizer
    opencomposite
    lighthouse-steamvr
    wlx-overlay-s
    wayvr-dashboard
    slimevr
  ];

  systemd.user.services."monado" = {
    postStart = "/bin/sh -c '${pkgs.lighthouse-steamvr}/bin/lighthouse -s on -b C3:13:44:66:06:C6; exit 0;'
      /bin/sh -c '${pkgs.lighthouse-steamvr}/bin/lighthouse -s on -b FC:2E:60:79:69:20; exit 0;'";
    preStop = "/bin/sh -c '${pkgs.lighthouse-steamvr}/bin/lighthouse -s off -b C3:13:44:66:06:C6; exit 0;'
      /bin/sh -c '${pkgs.lighthouse-steamvr}/bin/lighthouse -s off -b FC:2E:60:79:69:20; exit 0;'";

    environment = {
      STEAMVR_LH_ENABLE = "true";
      XRT_COMPOSITOR_COMPUTE = "1";
      #XRT_COMPOSITOR_SCALE_PERCENTAGE = "110";
    };
  };

  #programs.vr.packages.monado64 = lib.mkForce monado64; # Force to prevent conflicts if another module defines this
  #programs.vr.packages.monado32 = lib.mkForce monado32;
}
