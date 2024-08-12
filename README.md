# Intune for Linux feat. systemd-nspawn

You want to access corporate resources with
[Edge](https://www.microsoft.com/en-us/edge),
but your distro is not (yet) supported by
[Intune](https://learn.microsoft.com/en-us/mem/intune/user-help/enroll-device-linux)?
No worries, you can run Intune and Edge in
[systemd-nspawn](https://www.freedesktop.org/software/systemd/man/systemd-nspawn.html)
container :partying_face:

I created this on Debian Sid (unstable) using the latest dependencies.
It's unlikely to be compatible with your system.
This is only provided for reference and to potentially be helpful.
Please be aware that there are no warranties, so proceed with caution and review the code before running it.
If you don't understand the code, it's best not to use it.

WARNING: This may not be the compliant way of doing things.

## Dependencies

[`mkosi` v24.3](https://github.com/systemd/mkosi/tree/v24.3),
`apt`,
`bubblewrap`,
`pcscd`,
`pipewire | pulseaudio | pipewire-pulse`,
`sudo`,
`systemd-container`,
`ubuntu-keyring`,
`uidmap`,
`xorg | wayland`,
`zstd`
and something else that slipped my mind.

## Build & Install

```
git clone https://github.com/4nd3r/mkosi-intune
cd mkosi-intune
make
sudo make install
```

## Use

```
sudo machinectl login corphost
```

Begin by running `intune-portal` to register your machine. Once that's
complete, you can use `microsoft-edge` to take deep dive into corporate
resources. Make sure that the Edge profile status shows "*Sync is on*" before
proceeding, as things may not work properly otherwise.

When authenticating for the first time in `intune-portal` and an unknown error
occurs with hints about the *default keyring* in `journalctl --user`, restart
the container. There appears to be an issue with keyring initialization during
the first login. Occasionally, *Gnome Keyring* and *Identity Broker* do not
interact correctly immediately, necessitating a session restart.

## Networking

With `VirtualEthernet=yes` (default), the container gets its own network space,
but it still inherits the host's DNS servers. If you switch networks and the
DNS servers change, the container's DNS might break. However, restarting the
container usually fixes this.

On the other hand, with `VirtualEthernet=no`, the container shares the host's
network. This makes it easier when you move your laptop between different
networks. However, if you use a VPN inside the container, it might introduce
its own DNS servers and domain suffixes, potentially leading to DNS issues.

To use the latter, you need to modify the `mkosi.output/corphost.nspawn` file
after running the `make` command.

### systemd v256 or newer

Since v256, `IPForward=` is deprecated and replaced with the per-link settings.

See https://github.com/systemd/systemd/issues/33004#issuecomment-2131387501 for details.

## Smartcard

Close Edge and...

```
opensc-tool -l
modutil -dbdir sql:$HOME/.pki/nssdb -add opensc-pkcs11 -libfile /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
certutil -d sql:$HOME/.pki/nssdb -A -t CT,c,c -n YourCorporateCA -i YourCorporateCA.cer
```

**NB!** `pcscd` [2.0.1](https://github.com/LudovicRousseau/PCSC/blob/2.0.1/ChangeLog)
enabled polkit by default, which breaks reading smartcard in container for regular user.

Workaround is to edit `/etc/default/pcscd` in host:
```
PCSCD_ARGS='--disable-polkit'
```

Don't forget to restart `pcscd.service`.

## NVIDIA

If you have NVIDIA GPU and things don't work on Xorg,
then you have to install NVIDIA drivers **inside of container**.
Something like `./nvidia-installer -e --no-kernel-modules`
should do the trick.
