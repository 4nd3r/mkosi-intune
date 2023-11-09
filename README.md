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

[`mkosi` v19](https://github.com/systemd/mkosi) (as of 2023-11-09 this has not been released yet) and
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

By default, the image is built for X. If you want to build an image with
Wayland support, use `make wl` instead (**work in progress**). During the build
process, you will be prompted for a compliant password.

## Use

```
$ sudo machinectl login corphost
```

Begin by running `intune-portal` to register your machine. Once that's
complete, you can use `microsoft-edge` to take deep dive into corporate
resources. Make sure that the Edge profile status shows "*Sync is on*" before
proceeding, as things may not work properly otherwise.

## Networking

`VirtualEthernet=no` is used, which means that container has access to host
network. This simplifies life if you are moving your laptop between different
networks. YMMV.

## Smartcard

Close Edge and...

```
$ opensc-tool -l
$ modutil -dbdir sql:$HOME/.pki/nssdb -add opensc-pkcs11 -libfile /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
$ certutil -d sql:$HOME/.pki/nssdb -A -t CT,c,c -n YourCorporateCA -i YourCorporateCA.cer
```
