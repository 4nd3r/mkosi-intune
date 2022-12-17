# Intune for Linux feat. systemd-nspawn

You want to access corporate resources with
[Edge](https://www.microsoft.com/en-us/edge),
but your distro is not (yet) supported by
[Intune](https://learn.microsoft.com/en-us/mem/intune/fundamentals/)?
No worries, you can run Intune and Edge in
[systemd-nspawn](https://www.freedesktop.org/software/systemd/man/systemd-nspawn.html)
container :partying_face:

Tested only on Debian Sid with bleeding edge dependencies. Many assumptions are
made, which might not be compatible with your system. No warranties, be careful
and review the code before you run it :wink:

WARNING: This might not be compliant way of doing things.


## Dependencies

`debootstrap`,
[`mkosi`](https://github.com/systemd/mkosi),
`pulseaudio | pipewire-pulse`,
`sudo`,
`systemd-container`,
`xorg`,
`zstd`,
...

Only **X**, for Wayland see [@glima](https://github.com/glima)'s [fork](https://github.com/glima/mkosi-intune).


## Install

```
$ git clone https://github.com/4nd3r/mkosi-intune
$ cd mkosi-intune
$ make
```


## Use

```
$ sudo machinectl start corp$HOSTNAME
$ sudo machinectl login corp$HOSTNAME
```

Initial password is `hello` and you **must** change it, restart the container
and only then run `intune-portal`. Otherwise keyring initialization might fail.
Additionally you **must** always login to the container (e.g. after system
reboot) to unlock the keyring.

Run `microsoft-edge` to take deep dive into corporate resources, but first
check if Edge profile status is "*Sync is on*" or you will be greeted with SSO
login and/or recommendation to install Intune and register your device.


## Networking

For internet connectivity in the container you might have to do the following in your host:

```
$ sudo mkdir -p /etc/systemd/network/80-container-ve.network.d
$ sudo tee /etc/systemd/network/80-container-ve.network.d/nat.conf << EOF
[Network]
IPMasquerade=both
EOF
$ sudo systemctl daemon-reload
$ sudo machinectl stop ...
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
