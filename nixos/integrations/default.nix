# System-level integrations. SMB/NAS mounts must stay here: they use fileSystems and
# sops secrets at boot; Home Manager cannot manage system mount points.
{
  imports = [
    ./nas-mount.nix
  ];
}
