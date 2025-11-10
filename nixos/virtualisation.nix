{ pkgs, ... }: {
  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      package = pkgs.qemu_kvm;
      ovmf = {
        enable = true;
        packages = [pkgs.OVMFFull.fd];
      };
      swtpm.enable = true;
    };
  };
  virtualisation.spiceUSBRedirection.enable = true;


  # Allow VM management
  users.groups.libvirtd.members = [ "basti" ];
  users.groups.kvm.members = [ "basti" ];
}