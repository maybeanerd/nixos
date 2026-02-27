# Shared NAS (SMB) configuration. Used by NixOS system mounts and home-manager (e.g. Darwin user mounts).
# Mount base paths can differ per platform (e.g. /mnt/nas on NixOS, ~/mnt/nas on Darwin).
{
  server = "cube03";
  shares = [
    "audiobookshelfAudiobooks"
    "immichExternalLibrary"
    "jellyfinMedia"
    "PiNAS"
  ];
  mountBase = {
    nixos = "/mnt/nas";
    darwin = "mnt/nas";
  };
}
