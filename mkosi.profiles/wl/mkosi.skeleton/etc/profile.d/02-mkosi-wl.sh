export WAYLAND_DISPLAY=/run/host_wayland_0
export PIPEWIRE_REMOTE=/run/host_pipewire_0

systemctl --user import-environment WAYLAND_DISPLAY PIPEWIRE_REMOTE
