if ! systemctl -q --user is-enabled microsoft-edge.service
then
    systemctl -q --user enable microsoft-edge.service
fi

if ! systemctl -q --user is-active microsoft-edge.service
then
    systemctl -q --user start microsoft-edge.service
fi
