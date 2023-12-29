.PHONY: x wl build uidcheck clean install uninstall reinstall

NAME?=corphost

_UID=$(shell id -u)
_USER=$(USER)
_GID=$(shell id -g)
_GROUP=$(shell id -gn)
_HOME=$(HOME)

_CACHE_DIR=mkosi.cache
_OUTPUT_DIR=mkosi.output
_MACHINES_DIR=/var/lib/machines
_NSPAWN_DIR=/etc/systemd/nspawn
_SERVICE_DIR=/etc/systemd/system/systemd-nspawn@$(NAME).service.d

_IMAGE_SRC=$(_OUTPUT_DIR)/$(NAME).tar
_NSPAWN_SRC=$(_OUTPUT_DIR)/$(NAME).nspawn
_SERVICE_SRC=$(_OUTPUT_DIR)/$(NAME).service

_NSPAWN_DST=$(_NSPAWN_DIR)/$(NAME).nspawn
_SERVICE_DST=$(_SERVICE_DIR)/drop-in.conf

x: _PROFILE=x
x: build

wl: _PROFILE=wl
wl: build

build:
	mkdir -p $(_OUTPUT_DIR)
	if [ ! -e $(_CACHE_DIR) ]; then mkdir $(_CACHE_DIR); fi
	NAME="$(NAME)" _UID="$(_UID)" _USER="$(_USER)" _GID="$(_GID)" _GROUP="$(_GROUP)" _HOME="$(_HOME)" mkosi --profile $(_PROFILE) --image-id $(NAME) -f

uidcheck:
	@if [ "$(_UID)" != 0 ]; then echo 'use sudo'; exit 1; fi

clean: uidcheck
	rm -rf $(_OUTPUT_DIR)
	if [ ! -L $(_CACHE_DIR) ]; then rm -rf $(_CACHE_DIR); fi

install: uidcheck
	mkdir -p $(_MACHINES_DIR) $(_NSPAWN_DIR)
	machinectl import-tar $(_IMAGE_SRC) $(NAME)
	if [ -f $(_NSPAWN_SRC) ]; then cp $(_NSPAWN_SRC) $(_NSPAWN_DST); fi
	if [ -f $(_SERVICE_SRC) ]; then mkdir -p $(_SERVICE_DIR); cp $(_SERVICE_SRC) $(_SERVICE_DST); fi
	systemctl daemon-reload
	machinectl start $(NAME)

uninstall: uidcheck
	if machinectl status $(NAME) > /dev/null 2>&1; then machinectl terminate $(NAME); sleep 3; fi
	if machinectl image-status $(NAME) > /dev/null 2>&1; then machinectl remove $(NAME); fi
	rm -rf $(_NSPAWN_DST) $(_SERVICE_DIR)
	rmdir --ignore-fail-on-non-empty $(_MACHINES_DIR) $(_NSPAWN_DIR)
	systemctl daemon-reload

reinstall: uninstall install
