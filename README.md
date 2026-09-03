# nixos

the nixos config for my PC, laptops, and whatever else I can find

## General Config Overview
The unified flake provides a `mkSystem` function. The hostname is automatically derived from the attribute name. It accepts:
- `username`: The primary user's username
- `isWorkDevice`: If `true`, work-only apps and no personal/sops (default: `false`, i.e. personal device)

## General Commands
- `rb`: Alias for rebuilding the current system
- `fu`: Alias for updating the flake

# Adding New Machines
  
## 1. Add Configuration to flake.nix

Edit `flake.nix` and add a new configuration. The hostname is automatically derived from the attribute name:

```nix
darwinConfigurations = nixpkgs.lib.mapAttrs mkSystem {
  "new-hostname" = {
    username = "your-username";
    # isWorkDevice = true;  # only for work machines (no personal apps/sops)
  };
};

# Or for NixOS:
nixosConfigurations = nixpkgs.lib.mapAttrs mkSystem {
  "new-hostname" = {
    username = "your-username";
  };
};
```

## 2. Set Up

### On macOS (Darwin)

Set the path to your repository and create symlinks:

```bash
# Set repository path
NIXOS_REPO="/path/to/your/nixos/repo"

# Create Darwin symlinks
sudo ln -sf "$NIXOS_REPO/flake.nix" /etc/nix-darwin/flake.nix
sudo ln -sf "$NIXOS_REPO/flake.lock" /etc/nix-darwin/flake.lock
```


#### First-time nix-darwin activation

  ```bash
  # First time use
  sudo -H nix run nix-darwin/master#darwin-rebuild \
    --extra-experimental-features 'nix-command flakes' \
    -- switch --flake .#your-darwin-hostname

  # Or use the alias (after first build)
  rb
  ```

### On NixOS

Set the path and create symlinks:

```bash
# Set repository path and this host's name (must match flake.nix nixosConfigurations key)
export NIXOS_REPO="/path/to/your/nixos/repo"
export HOSTNAME="nixos"   # e.g. nixos, laptop, etc.

# Create NixOS configuration symlinks
sudo ln -sf "$NIXOS_REPO/flake.nix" /etc/nixos/flake.nix
sudo ln -sf "$NIXOS_REPO/flake.lock" /etc/nixos/flake.lock
```

Each NixOS host has its own hardware config at `nixos/hardware/<hostname>.nix`. Generate it once (or after hardware changes) and write it into the repo.

```bash
# Generate hardware config into the repo (recommended: single copy, no drift)
sudo nixos-generate-config --show-hardware-config > "$NIXOS_REPO/nixos/hardware/$HOSTNAME.nix"

# During installation from chroot/mounted system:
sudo nixos-generate-config --root /mnt
# then copy or symlink the generated hardware-configuration.nix into the repo:
sudo cp /mnt/etc/nixos/hardware-configuration.nix "$NIXOS_REPO/nixos/hardware/$HOSTNAME.nix"
```

Then build and switch:

```bash
# First time use (from the repo directory)
cd "$NIXOS_REPO"
sudo nixos-rebuild switch --flake --experimental-features 'flakes'

# Or use the alias (after first build)
rb
```
