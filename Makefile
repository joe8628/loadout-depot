INSTALL_DIR := $(HOME)/.local/bin
BINARY      := payload-depot
SOURCE      := $(CURDIR)/payload-depot

.PHONY: install uninstall test

install:
	@mkdir -p "$(INSTALL_DIR)"
	@ln -sf "$(SOURCE)" "$(INSTALL_DIR)/$(BINARY)"
	@echo "Installed: $(INSTALL_DIR)/$(BINARY) → $(SOURCE)"
	@echo "Make sure $(INSTALL_DIR) is on your PATH."

uninstall:
	@rm -f "$(INSTALL_DIR)/$(BINARY)"
	@echo "Removed: $(INSTALL_DIR)/$(BINARY)"

test:
	@bash tests/test_cli.sh
	@bash tests/test_install.sh
	@bash tests/test_hooks.sh
