# Intune for Linux feat. systemd-nspawn

Tested only on Debian Sid with bleeding edge dependencies.

No warranties, be careful, review before you run :wink:

WARNING: This might not be compliant way of doing things.


## Dependencies

`debootstrap`,
`mkosi`,
`pulseaudio | pipewire-pulse`,
`sudo`,
`systemd-container`,
`xorg`,
`zstd`
and many more.


## Install

```
$ git clone https://github.com/4nd3r/mkosi-intune
$ cd mkosi-intune
$ make
```

Running `make` without arguments will build the image with `mkosi`, install it
to standard `systemd-nspawn` locations, enables container startup on boot and
starts the container.


## Use

```
$ machinectl
$ sudo machinectl login ...
```

Initial password is `hello` and you **must** change it, restart (container) and
only then run `intune-portal`. Otherwise keyring initialization might fail.
You **must** always login to container to unlock the keyring.

On login `microsft-edge` user service starts. This way you don't have to keep
terminal open. Service will automatically restart in 3 seconds if you quit Edge
or it crashes.

Before you open corporate resources, first check if Edge profile status is
"*Sync is on*". Otherwise you will be greeted with login window.
