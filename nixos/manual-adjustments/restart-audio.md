# Restart Audio Services

> Info: as of now, we are not using pipewire since the following workaround doesnt work reliably.

For some reason, pipewire sometimes breaks. To restart it, run:

```bash
systemctl --user restart pipewire pipewire-pulse wireplumber
```

This is a workaround until the underlying issue is fixed.