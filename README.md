# Intune for Linux feat. systemd-nspawn

WARNING: This might not be compliant way of doing things.

## Dependencies

1. `xserver-xorg-core`
2. `systemd` (>= 2??)
3. `systemd-container`
4. `debootstrap`
5. `zstd`
6. `mkosi` (`sudo pip3 install git+https://github.com/systemd/mkosi.git` or see [here](https://github.com/systemd/mkosi))

## Configure

```
cd mkosi/
cp mkosi.default.example mkosi.default
cp mkosi.nspawn.example mkosi.nspawn
vim mkosi.default mkosi.nspawn
```

## Build

```
sudo sudo mkosi build
sudo mkdir -p /etc/systemd/nspawn /var/lib/machines
sudo mv mkosi.output/image.nspawn /etc/systemd/nspawn/corphost.nspawn
sudo mv mkosi.output/image /var/lib/machines/corphost
```

## Use

Boot container:

```
sudo systemd-nspawn -M corphost
```

You will be greeted by prompt - log in using credentials you set up in `mkosi.default`.

After succesful login run `intune-portal` to enroll into Intune and then `microsoft-edge`.

If you restart your desktop environment, Edge will close and you will lose the shell.

To get it back:

```
sudo machinectl shell user@corphost /bin/bash -c 'DISPLAY=:0 microsoft-edge-dev'
```

**NB** You must log in with a password after container boot. Just getting a
shell will not unlock the keyring (happens during PAM auth), so the above
`machinectl shell` command only works to reattach an existing session.

These instructions are tested on Debian (Sid) and NixOS. YMMV.

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
