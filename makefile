BIN ?= ee
PREFIX ?= /usr/local

install:
	@echo 'Installing echo-eval.'
	cp './ee.sh' '$(PREFIX)/bin/$(BIN)'
	@echo 'Done installing echo-eval.'

uninstall:
	@echo 'Uninstalling echo-eval.'
	rm -f '$(PREFIX)/bin/$(BIN)'
	@echo 'Done uninstalling echo-eval.'

.PHONY: install uninstall
