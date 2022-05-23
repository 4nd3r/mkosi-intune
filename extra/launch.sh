#!/usr/bin/env bash
set -eux

CORPHOST_PATH='/var/lib/machines/corphost'

set --
if stat /dev/video*; then  # Do we have at least 1 camera?
	for v in /dev/video*
	do
		set -- "$@" "--bind=$v"
	done
fi

if tmux list-session | grep -q '^corphost:'; then
    echo "Already running, reattaching"
else
    tmux new-session -d -s corphost \
        sudo systemd-nspawn \
            --boot \
            --directory="$CORPHOST_PATH" \
            --bind-ro=/etc/resolv.conf \
            --bind-ro="/run/user/$UID/pulse/native:/run/host_pulse_native" \
            --bind-ro=/tmp/.X11-unix \
            --bind=/dev/dri \
            --bind="$HOME/Desktop" \
            --bind="$HOME/Downloads" \
            "$@" \
            || true
fi

if [ -z "${TMUX:-}" ]; then
    tmux attach -t corphost
else
    tmux switch-client -t corphost
fi
