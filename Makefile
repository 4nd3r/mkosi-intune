.PHONY: build image nspawn service install uninstall reinstall

NAME?=corphost
PROFILE?=jammy

build: image nspawn service

image:
	./make.sh image $(NAME) $(PROFILE)

nspawn:
	./make.sh nspawn $(NAME)

service:
	./make.sh service $(NAME)

install:
	./make.sh install $(NAME)

uninstall:
	./make.sh uninstall $(NAME)

reinstall: uninstall install
