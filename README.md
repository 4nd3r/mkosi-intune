# Intune for Linux feat. systemd-nspawn

You want to access corporate resources with
[Edge](https://www.microsoft.com/en-us/edge),
but your distro is not (yet) supported by
[Intune](https://learn.microsoft.com/en-us/mem/intune/user-help/enroll-device-linux)?
No worries, you can run Intune and Edge in
[systemd-nspawn](https://www.freedesktop.org/software/systemd/man/systemd-nspawn.html)
container :partying_face:

This is built on Debian Sid (unstable) with bleeding edge dependencies. Most
probably **this is not compatible with your system**. Everything here is
provided only for reference and with hope that it might be helpful. No
warranties, be careful and review the code before you run it. **If you don't
understand the code, then you shouldn't use it.**

Minimum version of Debian which can be used is Bookworm (current testing).

WARNING: This might not be compliant way of doing things.

## Dependencies

[`mkosi`](https://github.com/systemd/mkosi) and
`apt`,
`bubblewrap`,
`debootstrap`,
`pcscd`,
`pulseaudio | pipewire-pulse`,
`sudo`,
`systemd-container`,
`uidmap`,
`xorg`,
`zstd`,
...

Only **X**, for Wayland see [@glima](https://github.com/glima)'s [fork](https://github.com/glima/mkosi-intune).

Upstream `mkosi` is expected, but since it is fast moving target, things can break.

As of **2023-04-10** last known good commit of `mkosi` is [c38240db2c3c6cc864c15d520b73808070a7f363](https://github.com/systemd/mkosi/commit/c38240db2c3c6cc864c15d520b73808070a7f363).

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

Networking configurations could be very different and therefore cases here
can be taken only as generic guidance.

Out-of-box systemd-nspawn expects you to use `systemd-networkd` and ideally `systemd-resolved`.
This reduces bit of troubles when setting up container. Systemd ships with `/usr/lib/systemd/network/80-container-ve.network`
for host side and `/usr/lib/systemd/network/80-container-host0.network` for container side network configuration.
Although it still requires setting up minimal masquerading rule from user side.

Example with `nftables`:
```
$ nft add table nat
$ nft 'add chain nat postrouting { type nat hook postrouting priority 100 ; }'
$ nft add rule nat postrouting oifname "ve-corphost" masquerade
```

If you are using firewall (which is reasonable thing to do), then you have to allow traffic from `ve-*` interfaces.

For example, in case of `nftables`:

```
$ sudo cat /etc/nftables.conf
...
table inet filter {
    chain input {
        ...
        iifname ve-* accept
...
```

Alternatively you can add `VirtualEthernet=no` to your corporate access
container's `.nspawn` file, but with this you might run into problems if you
have more nspawn containers running.

See [`man systemd.nspawn`](https://www.freedesktop.org/software/systemd/man/systemd.nspawn.html) for details.

## Smartcard

Close Edge and...

```
$ opensc-tool -l
$ modutil -dbdir sql:$HOME/.pki/nssdb -add opensc-pkcs11 -libfile /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
$ certutil -d sql:$HOME/.pki/nssdb -A -t CT,c,c -n YourCorporateCA -i YourCorporateCA.cer
```
