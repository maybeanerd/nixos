# nixos

the nixos config for my PC, laptops, and whatever else I can find

## Usage

The unified flake provides a `mkSystem` function. The hostname is automatically derived from the attribute name. It accepts:
- `username`: The primary user's username
- `platform`: Either `"darwin"` or `"nixos"`
- `includePersonal`: Include personal apps (default: `true`)
- `includeDevelopment`: Include development tools (default: `true`)

### macOS (Darwin)

```bash
# Build and switch to the new configuration
sudo darwin-rebuild switch --flake .#IUGMQ7JVJV62M2

# Or use the alias (after first build)
rb
```

### NixOS

```bash
# Build and switch to the new configuration
sudo nixos-rebuild switch --flake .#nixos

# Or use the alias (after first build)
rb
```

## Adding New Machines

### 1. Add Configuration to flake.nix

Edit `flake.nix` and add a new configuration. The hostname is automatically derived from the attribute name:

```nix
darwinConfigurations = nixpkgs.lib.mapAttrs mkSystem {
  "new-hostname" = {
    username = "your-username";
    platform = "darwin";
    includePersonal = true;
    includeDevelopment = true;
  };
};

# Or for NixOS:
nixosConfigurations = nixpkgs.lib.mapAttrs mkSystem {
  "new-hostname" = {
    username = "your-username";
    platform = "nixos";
    includePersonal = true;
    includeDevelopment = true;
  };
};
```

### 2. Set Up Symlinks

#### On macOS (Darwin)

Set the path to your repository and create symlinks:

```bash
# Set repository path
NIXOS_REPO="/path/to/your/nixos/repo"

# Create Darwin symlinks
sudo ln -sf "$NIXOS_REPO/flake.nix" /etc/nix-darwin/flake.nix
sudo ln -sf "$NIXOS_REPO/flake.lock" /etc/nix-darwin/flake.lock
```

#### On NixOS

Set the path and create symlinks:

```bash
# Set repository path
NIXOS_REPO="/path/to/your/nixos/repo"

# Create NixOS configuration symlinks
sudo ln -sf "$NIXOS_REPO/flake.nix" /etc/nixos/flake.nix
sudo ln -sf "$NIXOS_REPO/flake.lock" /etc/nixos/flake.lock

# Link hardware configuration (generated during NixOS installation)
sudo ln -sf "$NIXOS_REPO/nixos/hardware-configuration.nix" /etc/nixos/hardware-configuration.nix
```

**Note:** For NixOS, you should first generate the hardware configuration. The setup currently only supports a single shared one, though. In any case, you can do so by running:

```bash
# Generate hardware configuration for your system
sudo nixos-generate-config --root /mnt  # During installation
# OR
sudo nixos-generate-config --show-hardware-config > "$NIXOS_REPO/nixos/hardware-configuration.nix"
```
