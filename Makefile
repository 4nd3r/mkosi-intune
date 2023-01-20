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
	sudo mv ./mkosi.output/image.nspawn /etc/systemd/nspawn/${NAME}.nspawn
	sudo rm -rf /var/lib/machines/${NAME}
	sudo mv ./mkosi.output/ubuntu~jammy/image /var/lib/machines/${NAME}

uninstall:
	sudo rm -rf /etc/systemd/nspawn/${NAME}.nspawn /var/lib/machines/${NAME}
	sudo rmdir --ignore-fail-on-non-empty /etc/systemd/nspawn /var/lib/machines
