# Intune for Linux feat. systemd-nspawn

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

## Remarks

After you have working image, you should move it to more stable location:
```
mkdir ~/.corphost
mv mkosi.output/image.nspawn ~/.corphost/corphost.nspawn
mv mkosi.output/image.raw ~/.corphost/corphost.raw
cd ~/.corphost
sudo systemd-nspawn --image=corphost.raw --settings=trusted
```
Name change is necessary to avoid name conflict with running containers while
testing stuff in this repository. Container name will be derived from `--image=`
value without extension and `.nspawn` file with same name will used automatically.
