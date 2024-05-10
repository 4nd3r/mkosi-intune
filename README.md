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

[`mkosi` v22](https://github.com/systemd/mkosi/tree/v22) and
`apt`,
`bubblewrap`,
`pcscd`,
`pulseaudio | pipewire-pulse`,
`sudo`,
`systemd-container`,
`ubuntu-keyring`,
`uidmap`,
`xorg`,
`zstd`,
...

## Build & Install

```
$ git clone https://github.com/4nd3r/mkosi-intune
$ cd mkosi-intune
$ make
$ sudo make install
```

By default, the image is built for X. If you want to build an image
with Wayland support, use `make wl` instead. During the build process,
you will be prompted for a compliant password.

## Use

```
$ sudo machinectl login corphost
```

Begin by running `intune-portal` to register your machine. Once that's
complete, you can use `microsoft-edge` to take deep dive into corporate
resources. Make sure that the Edge profile status shows "*Sync is on*" before
proceeding, as things may not work properly otherwise.

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

## Smartcard

Close Edge and...

```
$ opensc-tool -l
$ modutil -dbdir sql:$HOME/.pki/nssdb -add opensc-pkcs11 -libfile /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
$ certutil -d sql:$HOME/.pki/nssdb -A -t CT,c,c -n YourCorporateCA -i YourCorporateCA.cer
```

**NB!** `pcscd` [2.0.1](https://github.com/LudovicRousseau/PCSC/blob/2.0.1/ChangeLog)
enabled polkit by default, which breaks reading smartcard in container for regular user.

This is the workaround I use in host:
```
$ cat /etc/default/pcscd
PCSCD_ARGS='--disable-polkit'
```

Don't forget to restart `pcscd.service`.

## NVIDIA

If you have NVIDIA GPU and things don't work on Xorg,
then you have to install NVIDIA drivers **inside of container**.
Something like `./nvidia-installer -e --no-kernel-modules`
should do the trick.
