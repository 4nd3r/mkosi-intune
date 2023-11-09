export DISPLAY=:0
export PATH="/opt/microsoft/intune/bin:$PATH"
export PULSE_SERVER=unix:/run/host_pulse_native
export WAYLAND_DISPLAY=/run/host_wayland_0
export PIPEWIRE_REMOTE=/run/host_pipewire_0

alias edge='microsoft-edge-stable --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=WebRTCPipeWireCapturer'
systemctl --user import-environment DISPLAY PATH PULSE_SERVER WAYLAND_DISPLAY PIPEWIRE_REMOTE

if ! systemctl -q --user is-active intune-agent.timer
then
    systemctl --user start intune-agent.timer
fi
