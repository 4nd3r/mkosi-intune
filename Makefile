.PHONY: make build force-build clean install uninstall

NAME?=$(shell hostname | sed 's/^/corp/')

make: build install

build:
	sudo mkosi build

force-build:
	sudo mkosi --force build

clean:
	sudo mkosi clean
	sudo find ./mkosi.cache/ ./mkosi.output/ -mindepth 1 -not -name .gitignore -delete

install:
	sudo mkdir -p /etc/systemd/nspawn /var/lib/machines
	sudo rm -rf /var/lib/machines/${NAME}
	sudo mv ./mkosi.output/ubuntu~jammy/image /var/lib/machines/${NAME}
	sudo mv ./mkosi.output/image.nspawn /etc/systemd/nspawn/${NAME}.nspawn
	sudo mkdir /etc/systemd/system/systemd-nspawn@${NAME}.service.d
	sudo mv ./mkosi.output/service.conf /etc/systemd/system/systemd-nspawn@${NAME}.service.d/drop-in.conf
	sudo systemctl daemon-reload

uninstall:
	sudo rm -rf /etc/systemd/nspawn/${NAME}.nspawn /var/lib/machines/${NAME} /etc/systemd/system/systemd-nspawn@${NAME}.service.d
	sudo rmdir --ignore-fail-on-non-empty /etc/systemd/nspawn /var/lib/machines
