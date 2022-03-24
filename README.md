# Intune for Linux with systemd-nspawn

Works for me on Debian Sid as of 2022-03-24. YMMV.

WARNING: This might not be compliant way of doing things.

## Dependencies

1. `xserver-xorg-core`
2. `systemd` (>= 2??)
3. `systemd-container`
4. `debootstrap`
5. `zstd`
6. `mkosi` (`sudo pip3 install git+https://github.com/systemd/mkosi.git` or see [here](https://github.com/systemd/mkosi))

## Configure

1. In `mkosi.default` modify `Password=` (**required for keyring**) and `[Host]` section (optional).
2. In `mkosi.prepare` modify `HOSTNAME=`.
3. In `mkosi.postinst` modify `UID=`, `GID=`, `USER=` and `HOME=`.
4. `mkosi.nspawn` will probably work as is (you can add your own binds here, e.g. `$HOME/Desktop`).

## Usage

1. Run `sudo mkosi boot` (in repository root) and wait (use `mkosi -f` to "reset" the image).
2. Log in with `$USER` and password (**required for keyring**).
3. Run `intune-portal` and follow the instructions.
4. Run `microsoft-edge` and be brave.

## Notes

After you have working image, you can:
```
mkdir ~/.corphost
mv mkosi.output/* ~/.corphost/
cd ~/.corphost
sudo systemd-nspawn --settings=trusted -bi image.raw
```

## TODO

1. Troubleshooting instructions?
2. Install `libpam-pwquality` to host and bind `/etc/pam.d/common-password` from host?
3. Templates and `Makefile`?
