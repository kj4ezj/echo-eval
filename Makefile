BIN ?= ee
PREFIX ?= /usr/local
VERSION = $(shell git describe --tags --exact-match 2>/dev/null || git rev-parse HEAD)

install:
	@echo 'Installing echo-eval.'
	cat './ee.sh' | sed 's_kj4ezj/ee_kj4ezj/ee/tree/$(VERSION)_' > '$(PREFIX)/bin/$(BIN)'
	chmod +x '$(PREFIX)/bin/$(BIN)'
	@echo 'Done installing echo-eval as "$(PREFIX)/bin/$(BIN)".'

uninstall:
	@echo 'Uninstalling echo-eval.'
	rm -f '$(PREFIX)/bin/$(BIN)'
	@echo 'Done uninstalling echo-eval.'

.PHONY: install uninstall
