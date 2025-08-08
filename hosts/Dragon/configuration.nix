{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
    ./nvidia.nix
  ];
  networking.hostName = "Dragon";

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings.general.ControllerMode = "bredr";

  nixpkgs.overlays = [
    (self: super: {
      blender =
        (super.blender.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ [ ../../dotfiles/blender-xr.patch ];
        })).override
          { cudaSupport = true; };
    })
    inputs.nvidia-patch.overlays.default
  ];

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot.kernelPatches = [
    {
      name = "pimax headset support";
      patch = ../../patches/pimax.patch;
    }
  ];

  services.xserver.xrandrHeads = [
    {
      monitorConfig = ''Option "Rotate" "left"'';
      output = "DP-2";
    }
  ];

  specialisation = {
    nvk.configuration = {
      services.xserver.videoDrivers = [
        "nouveau"
        "modesetting"
        "fbdev"
      ];
      boot.kernelParams = [
        "nouveau.config=NvGspRm=1"
        "module_blacklist=nvidia"
      ];
    };
  };

  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIDNTCCAh2gAwIBAgIUF5C66htyqRLjF9uA2ucLYzU9cFgwDQYJKoZIhvcNAQEL
      BQAwKDESMBAGA1UEAwwJbWl0bXByb3h5MRIwEAYDVQQKDAltaXRtcHJveHkwHhcN
      MjUwMTE0MTIzNDU4WhcNMzUwMTE0MTIzNDU4WjAoMRIwEAYDVQQDDAltaXRtcHJv
      eHkxEjAQBgNVBAoMCW1pdG1wcm94eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
      AQoCggEBALev0fMWy9zzXM5WkcSe7ncJ5CPAP0xSaBMLVYBmVrfdMQEn5+umiM3q
      j4hi6UAwu1O6QIYFgxIk6cmi08hk0bkefvAK3oi+dQ3vd0oEgyeRFnFqc/18kv4V
      7r8ZkfO6cehB97itTQyRrdi1IMxNUUEouXYBmd9XDxv6KhhCVsoeT6Y4oD/K10Ea
      qhxZrKrfmNhlK2iBJGO8T/u0kk9a8AUPSH7FC/qiGCAyftoMnyivwtUx+iZOjOaL
      qp2bEvUL6fp3TqNE/ZoQHBwJaC3KgN3MpURKaaqMxNpSkzXYeVbFjEVAfLHoJ+Ay
      gCmgbeKXNlb5SnuPNvq74UOm1o0U9v0CAwEAAaNXMFUwDwYDVR0TAQH/BAUwAwEB
      /zATBgNVHSUEDDAKBggrBgEFBQcDATAOBgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYE
      FLE/TyFkZdWmq6vhKMJnL21OpdwbMA0GCSqGSIb3DQEBCwUAA4IBAQAcxHY/j9aY
      mtrLiz9eG/S6A0gs7TR+jQ8ydrSuFDlLTb0pp0yI987q8XMYuOMyOgHnoa8xRqiE
      Az55+ot5pqP+4qiQToPE4NGirSURsgr8JRhfqbgRt/XBUOCTL2EOsmMA9f5quIW8
      wHF7VTVr2/GmpbapznQf5KC2S6tkyzn6jRVublZvbx5F/LEYRGJ977Gk5333EX0o
      Blr7N4ue06Fx34PaJaG5cUXSNvlH9yjyT8wkiPB79XlJXQZRUVo+J9BURSaXqjHV
      4wal8CjHGyX/gYfiLUjLST6ZV2H1Qg9n++k4mtfLl/MZY+ynNMVkq9BNw5SJJZ0h
      +UzWcEUvrdIV
      -----END CERTIFICATE-----
    ''
  ];

}
