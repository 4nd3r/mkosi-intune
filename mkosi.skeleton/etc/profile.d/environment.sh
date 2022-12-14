export DISPLAY=:0
export PATH="/opt/microsoft/intune/bin:$PATH"
export PULSE_SERVER=unix:/run/host_pulse_native
export WAYLAND_DISPLAY=/run/host_wayland_0
systemctl --user import-environment DISPLAY PATH PULSE_SERVER
