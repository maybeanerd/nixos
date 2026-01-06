# XMage Flake

A Nix flake for running XMage (Magic: The Gathering online client) on NixOS.

## Usage

From this directory, you can run XMage with:

```bash
nix run
```

This will:
1. Download the specified XMage version (controlled by the flake input)
2. Extract it to the Nix store
3. Launch the client with proper Java configuration for NixOS

## Updating XMage

To update to a new version:

1. Edit `flake.nix` and change the `version` variable to the desired release
2. Remove the `sha256` line or set it to an empty string
3. Run `nix flake update`
4. Nix will tell you the correct hash; add it back to the file
