{
  pkgs,
  inputs,
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
    package = inputs.rainspkgs.packages.x86_64-linux.monado-pimax;
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
