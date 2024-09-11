#!/bin/sh -e

_action="$1"
_name="$2"

if [ -z "$_action" ] || [ -z "$_name" ]
then
    exit 1
fi

_output_dst='mkosi.output'
_image_src="$_output_dst/$_name.tar"
_nspawn_src="$_output_dst/$_name.nspawn"
_nspawn_dst="/etc/systemd/nspawn/$_name.nspawn"
_service_src="$_output_dst/$_name.service"
_service_dst="/etc/systemd/system/systemd-nspawn@$_name.service.d/extra.conf"

export _UID="$( id -u )"
export _USER="$USER"
export _GID="$( id -g )"
export _GROUP="$( id -gn )"
export _HOME="$HOME"

_nspawn()
{
    echo '[Files]'

    for _ in \
        'Bind=/dev/dri' \
        "Bind=$_HOME/.kube" \
        "Bind=$_HOME/Desktop" \
        "Bind=$_HOME/Downloads" \
        "Bind=$_HOME/Repos" \
        "BindReadOnly=$_HOME/.tmux.conf" \
        "BindReadOnly=$_HOME/Documents" \
        'BindReadOnly=/run/pcscd/pcscd.comm' \
        "BindReadOnly=/run/user/$_UID/pipewire-0:/run/host-pipewire" \
        "BindReadOnly=/run/user/$_UID/pulse/native:/run/host-pulseaudio" \
        "BindReadOnly=/run/user/$_UID/wayland-0:/run/host-wayland" \
        'BindReadOnly=/tmp/.X11-unix'
    do
        if [ -e "$( echo "$_" | cut -d= -f2 | sed 's/:.*//' )" ]
        then
            echo "$_"
        fi
    done

    echo ''
    echo '[Network]'
    echo '# If you want to give container access to host networking, then'
    echo '# set this to "no" and uncomment Capability and ResolvConf below.'
    echo 'VirtualEthernet=yes'

    echo ''
    echo '[Exec]'
    echo 'PrivateUsers=no'
    echo '#Capability=CAP_NET_ADMIN'
    echo '#ResolvConf=bind-host'
}

_service()
{
    echo '[Service]'

    printf "ExecStartPost=-/usr/bin/find /dev -maxdepth 1 -regex '%s' -exec machinectl bind %s {} --mkdir \\;\n" \
        '/dev/\\(hidraw\\|video\\)[0-9]+' \
        "$_name"

    echo 'Restart=on-failure'
    echo 'RestartSec=3'
    echo 'DevicePolicy=auto'
    echo 'DeviceAllow='
}

case "$_action" in
    image)
        if [ -z "$3" ]
        then
            exit 1
        fi
        rm -rf "$_output_dst"
        mkdir "$_output_dst"
        mkosi -f --image-id "$_name" --profile "$3"
    ;;
    nspawn)
        _nspawn > "$_nspawn_src"
    ;;
    service)
        _service > "$_service_src"
    ;;
    install)
        if [ "$_UID" != '0' ]; then echo 'got root?' >&2; exit 1; fi
        importctl -m import-tar "$_image_src" "$_name"
        install -D -m 644 "$_nspawn_src" "$_nspawn_dst"
        install -D -m 644 "$_service_src" "$_service_dst"
        systemctl daemon-reload
        machinectl start "$_name"
    ;;
    uninstall)
        if [ "$_UID" != '0' ]; then echo 'got root?' >&2; exit 1; fi
        if machinectl status "$_name" > /dev/null 2>&1; then machinectl terminate "$_name"; sleep 3; fi
        if machinectl image-status "$_name" > /dev/null 2>&1; then machinectl remove "$_name"; fi
        rm -f "$_nspawn_dst"
        rm -rf "$( dirname "$_service_dst" )"
        systemctl daemon-reload
    ;;
esac
