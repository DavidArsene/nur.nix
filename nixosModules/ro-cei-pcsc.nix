{ self, pkgs, ... }:

#!
#! Pentru suport Firefox/Chrome:
#!
#! https://wiki.archlinux.org/title/Smartcards#Configuration
#!
#! Module Name: "idplug" # de exemplu
#! Module filename: "/run/current-system/sw/lib/libidplug-pkcs11.so"
#!
#! Tot acest filename poate fi folosit pentru `pkcs11-tool` din `opensc`:
#! $ pkcs11-tool --module /run/current-system/sw/lib/libidplug-pkcs11.so -L -O
#!

{
  services.pcscd = {
    enable = true;
    extraArgs = [
      "--info"
      "--reader-name-no-serial"
      "--reader-name-no-interface"
    ];
  };

  # FIXME: uses hardcoded opensc-pkcs11.so
  # security.pam.p11.enable = true;
  # security.pam.p11.control = "sufficient";

  environment.systemPackages = with pkgs; [
    self.packages.idplugmanager-ro-cei
    nss_latest.tools # modutil
    opensc
    pcsc-tools # pcsc_scan
    # piv-agent
  ];

  # programs.gnupg.agent.enable = true;
  # programs.gnupg.agent.enableSSHSupport = true;

  security.pki.certificates = [
    ''
      RO CEI MAI Root-CA
      ==========
      -----BEGIN CERTIFICATE-----
      MIICYTCCAeegAwIBAgIRAMlKVxTGtPR4lPwMMyKafXwwCgYIKoZIzj0EAwMwYTEL
      MAkGA1UEBhMCUk8xJjAkBgNVBAoMHU1pbmlzdGVydWwgQWZhY2VyaWxvciBJbnRl
      cm5lMQ0wCwYDVQQLDARER0VQMRswGQYDVQQDDBJSTyBDRUkgTUFJIFJvb3QtQ0Ew
      HhcNMjQxMDIzMTEzNzQ1WhcNNDUwNDIzMTIwNzQ1WjBhMQswCQYDVQQGEwJSTzEm
      MCQGA1UECgwdTWluaXN0ZXJ1bCBBZmFjZXJpbG9yIEludGVybmUxDTALBgNVBAsM
      BERHRVAxGzAZBgNVBAMMElJPIENFSSBNQUkgUm9vdC1DQTB2MBAGByqGSM49AgEG
      BSuBBAAiA2IABKOFqrjI4nel7u6VJ3BwZNv9u7z0Zzx0aup3CStin4/bi0bnLiI4
      KX/RbAhYyBq7qg6caKar0BkYSw8n5PEFXe1NYiKaLVDRVgIYjEvQ6WgRRnt38Df/
      2XjresDyOldfn6NjMGEwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYw
      HwYDVR0jBBgwFoAU/xexHf5T1/raPRy8KvwmcNp7P7MwHQYDVR0OBBYEFP8XsR3+
      U9f62j0cvCr8JnDaez+zMAoGCCqGSM49BAMDA2gAMGUCMQC9rxn00nzINiuit8Ut
      wnutb3Wyi/0QrxWf5znbJbyQMriVEmvkIrlCfGf/MmtCLbMCMGA90hm3VBPeHftg
      ++ZRIeQtMQ9tRNWGe7/hwn3t0mu8CWeDB7GJHHRTaSsaBG7XYg==
      -----END CERTIFICATE-----
    ''
  ];
}
