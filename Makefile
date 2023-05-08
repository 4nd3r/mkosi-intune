.PHONY: build uidcheck clean install uninstall

_HOST?=corphost
_UID?=$(shell id -u)
_USER?=$(USER)
_GID?=$(shell id -g)
_GROUP?=$(shell id -gn)
_HOME?=$(HOME)

build:
	mkdir -p mkosi.cache mkosi.output mkosi.workspace
	_UID="$(_UID)" _USER="$(_USER)" _GID="$(_GID)" _GROUP="$(_GROUP)" _HOME="$(_HOME)" mkosi -f build

uidcheck:
	@if [ "$(_UID)" != 0 ]; then echo 'use sudo'; exit 1; fi

clean: uidcheck
	rm -rf mkosi.cache mkosi.output mkosi.workspace

install: uidcheck
	mkdir -p /etc/systemd/nspawn /var/lib/machines
	machinectl import-tar mkosi.output/image.tar $(_HOST)
	cp mkosi.output/image.nspawn /etc/systemd/nspawn/$(_HOST).nspawn
	mkdir /etc/systemd/system/systemd-nspawn@$(_HOST).service.d
	cp mkosi.output/image.service /etc/systemd/system/systemd-nspawn@$(_HOST).service.d/drop-in.conf
	machinectl start $(_HOST)

uninstall: uidcheck
	if machinectl status $(_HOST) > /dev/null 2>&1; then machinectl terminate $(_HOST); sleep 3; fi
	if machinectl image-status $(_HOST) > /dev/null 2>&1; then machinectl remove $(_HOST); fi
	rm -rf /etc/systemd/nspawn/$(_HOST).nspawn /etc/systemd/system/systemd-nspawn@$(_HOST).service.d
	rmdir --ignore-fail-on-non-empty /etc/systemd/nspawn /var/lib/machines
