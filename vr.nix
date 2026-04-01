{
  pkgs,
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
  ];

  systemd.user.services."monado" = {
    #  postStart = "/bin/sh -c '${pkgs.lighthouse-steamvr}/bin/lighthouse -s on -b C3:13:44:66:06:C6; exit 0;'
    #    /bin/sh -c '${pkgs.lighthouse-steamvr}/bin/lighthouse -s on -b FC:2E:60:79:69:20; exit 0;'";
    #  preStop = "/bin/sh -c '${pkgs.lighthouse-steamvr}/bin/lighthouse -s off -b C3:13:44:66:06:C6; exit 0;'
    #    /bin/sh -c '${pkgs.lighthouse-steamvr}/bin/lighthouse -s off -b FC:2E:60:79:69:20; exit 0;'";

    environment = {
      STEAMVR_LH_ENABLE = "true";
      XRT_COMPOSITOR_COMPUTE = "1";
      #PIMAX_REBOOT = "true";
      #XRT_COMPOSITOR_SCALE_PERCENTAGE = "110";
    };
  };
  #programs.vr.packages.monado64 = lib.mkForce monado64; # Force to prevent conflicts if another module defines this
  #programs.vr.packages.monado32 = lib.mkForce monado32;
}
