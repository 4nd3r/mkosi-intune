export DISPLAY=:0
export PATH="/opt/microsoft/intune/bin:/opt/microsoft/microsoft-azurevpnclient:$PATH"
export PULSE_SERVER=unix:/run/host_pulse_native

systemctl --user import-environment DISPLAY PATH PULSE_SERVER

if ! systemctl -q --user is-active intune-agent.timer
then
    systemctl --user start intune-agent.timer
fi
