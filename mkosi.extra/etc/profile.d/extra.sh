export DISPLAY=:0
export PATH="/opt/microsoft/intune/bin:/opt/microsoft/microsoft-azurevpnclient:$PATH"
systemctl --user import-environment DISPLAY PATH

_pulseaudio_socket=/run/host-pulseaudio

if [ -S "$_pulseaudio_socket" ]
then
    export PULSE_SERVER="unix:$_pulseaudio_socket"
    systemctl --user import-environment PULSE_SERVER
fi

_pipewire_socket=/run/host-pipewire

if [ -S "$_pipewire_socket" ]
then
    export PIPEWIRE_REMOTE="$_pipewire_socket"
    systemctl --user import-environment PIPEWIRE_REMOTE
fi

_wayland_socket=/run/host-wayland

if [ -S "$_wayland_socket" ]
then
    export WAYLAND_DISPLAY="$_wayland_socket"
    systemctl --user import-environment WAYLAND_DISPLAY
fi

if ! systemctl -q --user is-active intune-agent.timer
then
    systemctl --user start intune-agent.timer
fi
