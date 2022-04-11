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
   Alternatively, run `sudo mkosi build` to just build the image and launch as per instructions below.
3. Log in with `INTUNE_USER=` and `Password=` (**required for keyring**) set in `mkosi.default`.
4. Run `intune-portal` and follow the instructions.
5. Run `microsoft-edge` and good luck!

## Remarks

After you have working image, you should move it to more stable location:
```
sudo mkdir -p /etc/systemd/nspawn /var/lib/machines
sudo mv mkosi.output/image.nspawn /etc/systemd/nspawn/corphost.nspawn
sudo mv mkosi.output/image /var/lib/machines/corphost
sudo systemd-nspawn -M corphost
```

If you restart your desktop environment, Edge closes and you will lose the shell. To get it back:
```sh
$ sudo machinectl shell user@corphost /bin/bash -c "DISPLAY=:0 microsoft-edge-dev"
```

NB! Initially, you need to log in with a password - just getting a shell
probably won't unlock the keyring (unlocking the keyring happens during PAM
auth), so the above `machinectl shell` command only works to reattach to an
existing session.

These instructions are working and tested on Debian and NixOS.

## Troubleshooting

### Keyring

Due to unknown reasons sometimes `gnome-keyring-daemon` doesn't start correctly and
it's not possible sign in to Intune. To verify check if `~/.local/share/keyrings/`
contains  files `login.keyring` and `user.keystore`. These files must be created
automatically by `gnome-keyring-daemon` when you start signing in to `intune-portal`.
Logging out of container and back in should help... YMMV.

### Edge

Before you open any corporate resources, always check first if Edge profile
status is "*Sync is on*". Otherwise you will be greeted with login window.
Close tab, take a breath and try again.
