# Restart Audio Services

For some reason, pipewire sometimes breaks. To restart it, run:

```bash
systemctl --user restart pipewire pipewire-pulse wireplumber
```

This is a workaround until the underlying issue is fixed.