# nixos

the nixos config for my PC, laptops, and whatever else I can find

## Usage

The unified flake provides a `mkSystem` function. The hostname is automatically derived from the attribute name. It accepts:
- `username`: The primary user's username
- `platform`: Either `"darwin"` or `"nixos"`
- `includePersonal`: Include personal apps (default: `true`)

## Adding New Machines

### 1. Add Configuration to flake.nix

Edit `flake.nix` and add a new configuration. The hostname is automatically derived from the attribute name:

```nix
darwinConfigurations = nixpkgs.lib.mapAttrs mkSystem {
  "new-hostname" = {
    username = "your-username";
    platform = "darwin";
    includePersonal = true;
  };
};

# Or for NixOS:
nixosConfigurations = nixpkgs.lib.mapAttrs mkSystem {
  "new-hostname" = {
    username = "your-username";
    platform = "nixos";
    includePersonal = true;
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

#### First-time setup on macOS (Darwin)

- **One-time Homebrew install (required for `darwin/homebrew`)**

  The `darwin/homebrew` module expects Homebrew to already be installed. Do this **once per machine** as your normal user (no `sudo`):

  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

- **First-time nix-darwin activation**

  Once Homebrew is installed:

  ```bash
  # First time use (from this repo)
  cd /path/to/your/nixos/repo
  sudo -H nix run nix-darwin/master#darwin-rebuild \
    --extra-experimental-features 'nix-command flakes' \
    -- switch --flake .#your-darwin-hostname

  # Or use the alias (after first build)
  rb
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
