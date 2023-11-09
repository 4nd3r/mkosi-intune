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

For X, X-Wayland or optionally Wayland.

NB: It is primarily tested on X, but (pure) Wayland support is there
for Microsoft Edge, if the host has a Wayland session and active
socket present.  That is useful when the host itself is on Wayland,
and anything X in the container image would mean XWayland translation
on the host (with probably blurry images as a result).

If that you want to use Wayland, please uncomment the lines in this repo
prefixed with `#WAYLAND:` in `mkosi.finalize` and `mkosi.skeleton/etc/profile.d/mkosi.sh`:

```
sed -i 's/#WAYLAND: //g' mkosi.finalize mkosi.skeleton/etc/profile.d/mkosi.sh
```

Only then continue to build.

Note: Inside the container, invoke Edge for Wayland with the `edge` alias or directly with

```
$ microsoft-edge --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=WebRTCPipeWireCapturer
```

Sharing screen has been seen to work for browser tabs, but is still very unstable
--use at your own risk.
If Edge on Wayland crashes on screen sharing, make sure that it can't access the
host X server (maybe you forgot to run `xhost -` after using the Intune portal?).
A test can be done [here](https://webrtc.github.io/samples/src/content/getusermedia/getdisplaymedia/).

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

Initial password is `hello` and you **must** change it, both with `passwd` and
with `seahorse` for the GNOME session keyring (right click), restart the container
and only then run `intune-portal`. Otherwise keyring initialization might fail.
Additionally you **must** always login to the container (e.g. after host
reboot) to unlock the keyring.

Run `microsoft-edge` to take deep dive into corporate resources, but first
check if Edge profile status is "*Sync is on*" or you will be greeted with SSO
login and/or recommendation to install Intune and register your device.

Note: Intune is a bit fragile and sometimes it helps to click "Refresh" to become
compliant. When it looks like one is logged out, it helps to restart the systemd
services and run Edge/the portal again.
There are both system and user services:
```
systemctl restart --user microsoft-identity-broker.service
systemctl restart --user intune-agent.service
systemctl restart microsoft-identity-device-broker.service

```

Note: When using the Wayland variant, first run `xhost +` on your host before running
`intune-portal` (because the `XAUTHORITY` info isn't forwarded). Afterwards, run
`xhost -` to revert to original permissions.

## Cameras

By default, no video cameras are passed into the container.
Change the `mkosi.finalize` file to pass a particular video device in on container start.
After installation, edit `/etc/systemd/nspawn/corphost.nspawn`.

Note that the device must be present then or the nspawn won't start the container.
Afterwards you could create the device as written [here](https://askubuntu.com/a/1068341)
(or try your luck with `machinectl bind ... /dev/video0 --mkdir`).
You can test you camera [here](https://webrtc.github.io/samples/src/content/devices/input-output/).

## Networking

`VirtualEthernet=no` is used, which means that container has access to host
network. This simplifies life if you are moving your laptop between different
networks. YMMV.

## VPN

You can use `gp-saml-gui` to set up the internal VPN. As with Intune, you may
need to do a retry to get it running.

Here an example setup:
```
apt install openconnect gp-saml-gui
cat $HOME/.gpssl.conf:
openssl_conf = openssl_init
[openssl_init]
ssl_conf = ssl_sect
[ssl_sect]
system_default = system_default_sect
[system_default_sect]
Options = UnsafeLegacyRenegotiation

# You may now start it with your gateway:
# OPENSSL_CONF=$HOME/.gpssl.conf gp-saml-gui --clientos Windows --sudo-openconnect --gateway GATEWAY -- -b
```

## Smartcard

Close Edge and...

```
$ opensc-tool -l
$ modutil -dbdir sql:$HOME/.pki/nssdb -add opensc-pkcs11 -libfile /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
$ certutil -d sql:$HOME/.pki/nssdb -A -t CT,c,c -n YourCorporateCA -i YourCorporateCA.cer
```
