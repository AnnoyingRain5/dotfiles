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
          owner = "Coreforge";
          repo = "monado";
          rev = "a82eef73be841aff1324d32dbe9a031c6c0417c8";
          hash = "sha256-Y96L4DU9bJWIoNg1YhpbAkZHnk9RUEslb2Fn0aPF6zQ=";
        };
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.libgbinder ];
        propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or [ ]) ++ [ pkgs.libgbinder ];
        enableCuda = true;
        postFixup = ''
          patchelf $out/bin/monado-service --add-rpath ${pkgs.libgbinder}/lib
        '';
        patches = (oldAttrs.patches or [ ]) ++ [
          patches/monado-fix-vive-return.patch
          patches/monado-load-solarxr.patch
          patches/monado-pimax-fix-stage-supported.patch
          patches/monado-solarxr.patch
          patches/monado-waydroid.patch
          patches/monado-xr-meta-body-tracking-full-body.patch
          patches/monado-xrt-device-supported-struct.patch
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
