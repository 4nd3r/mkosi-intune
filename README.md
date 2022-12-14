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

[`mkosi` v18](https://github.com/systemd/mkosi/releases/tag/v18) and
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

For X, X-Wayland or Wayland.

NB: It is primarily tested on X, but (pure) Wayland support is there
for Microsoft Edge, if the host has a Wayland session and active
socket present.  That is useful when the host itself is on Wayland,
and anything X in the container image would mean XWayland translation
on the host (with probably blurry images as a result). If that is your
use case, please invoke Edge with

```
$ microsoft-edge --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=WebRTCPipeWireCapturer
```

if you want the Wayland path. Sharing screen has been seen to work for
browser tabs, but is still very unstable--use at your own risk.

## Build & Install

```
$ git clone https://github.com/4nd3r/mkosi-intune
$ cd mkosi-intune
$ make
$ sudo make install
```

## Use

```
$ sudo machinectl login corphost
```

Initial password is `hello` and you **must** change it, restart the container
and only then run `intune-portal`. Otherwise keyring initialization might fail.
Additionally you **must** always login to the container (e.g. after host
reboot) to unlock the keyring.

Run `microsoft-edge` to take deep dive into corporate resources, but first
check if Edge profile status is "*Sync is on*" or you will be greeted with SSO
login and/or recommendation to install Intune and register your device.

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
