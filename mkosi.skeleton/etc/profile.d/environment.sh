export DISPLAY=:0
export PULSE_SERVER=unix:/run/host_pulse_native
systemctl --user import-environment DISPLAY PULSE_SERVER
