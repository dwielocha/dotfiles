# My NixOS config

Based on epic ZaneyOS config [https://gitlab.com/Zaney/zaneyos](https://gitlab.com/Zaney/zaneyos)

### Update system
```bash
nix flake update
```

### Rebuild system

```bash
sudo nixos-rebuild switch --flake .#pc
```

