# Intune for Linux feat. systemd-nspawn

WARNING: This might not be compliant way of doing things.

## Dependencies

1. `xserver-xorg-core`
2. `systemd` (>= 2??)
3. `systemd-container`
4. `debootstrap`
5. `zstd`
6. `mkosi` (`sudo pip3 install git+https://github.com/systemd/mkosi.git` or see [here](https://github.com/systemd/mkosi))

## Usage

1. Modify `Password=` (**required for keyring**) and `Environment=` in `mkosi.default`.
2. Run `sudo mkosi boot` (in repository root). Use `sudo mkosi -f boot` to rebuild the image.
3. Log in with `INTUNE_USER=` and `Password=` (**required for keyring**) set in `mkosi.default`.
4. Run `intune-portal` and follow the instructions.
5. Run `microsoft-edge` and good luck!

## Remarks

After you have working image, you should move it to more stable location:
```
sudo mkdir /etc/systemd/nspawn /var/lib/machines
sudo mv mkosi.output/image.nspawn /etc/systemd/nspawn/corphost.nspawn
sudo mv mkosi.output/image /var/lib/machines/corphost
sudo systemd-nspawn -M corphost
```

## Troubleshooting

Due to unknown reasons sometimes `gnome-keyring-daemon` doesn't start correctly and
it's not possible sign in to Intune. To verify check if `~/.local/share/keyrings/`
contains  files `login.keyring` and `user.keystore`. These files must be created
automatically by `gnome-keyring-daemon` when you start signing in to `intune-portal`.
Logging out of container and back in should help... YMMV.
