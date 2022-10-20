.PHONY: make build clean install uninstall

HOSTNAME:=$(shell hostname | sed 's/^/corp/')

make: build install

build:
	sudo mkosi build

clean:
	sudo mkosi clean

install:
	sudo mkdir -p /etc/systemd/nspawn
	sudo mv mkosi.output/image.nspawn /etc/systemd/nspawn/${HOSTNAME}.nspawn
	sudo mkdir -p /var/lib/machines
	sudo rm -rf /var/lib/machines/${HOSTNAME}
	sudo mv mkosi.output/image /var/lib/machines/${HOSTNAME}

uninstall:
	sudo rm -rf /etc/systemd/nspawn/${HOSTNAME}.nspawn /var/lib/machines/${HOSTNAME}
	sudo rmdir --ignore-fail-on-non-empty /etc/systemd/nspawn /var/lib/machines
