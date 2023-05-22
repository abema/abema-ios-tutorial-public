.PHONY: default
default: # ターゲットを指定していない時、include元のdefaultターゲットを実行する

# Environment

PROJECT_ROOT := $(shell git rev-parse --show-toplevel)

ifneq ($(shell which brew),)
BREW_PREFIX = $(shell brew --prefix)
endif
ifneq ($(shell which /opt/homebrew/bin/brew),)
BREW_PREFIX = $(shell /opt/homebrew/bin/brew --prefix)
endif
ifneq ($(shell which /usr/local/bin/brew),)
BREW_PREFIX = $(shell /usr/local/bin/brew --prefix)
endif

# Mint

MINT ?= $(BREW_PREFIX)/bin/mint
MINT_PATH = $(PROJECT_ROOT)/.mint/lib
MINT_LINK_PATH = $(PROJECT_ROOT)/.mint/bin

# Default tool paths
XCODEGEN ?= $(MINT_LINK_PATH)/xcodegen
MOCKOLO ?= $(MINT_LINK_PATH)/mockolo
XCBEAUTIFY ?= $(MINT_LINK_PATH)/xcbeautify

# Tools

/usr/local/bin/mint:
	$(BREW_PREFIX)/bin/brew install mint

mint-%: $(MINT_LINK_PATH)/%
	@echo Installed: $?

$(MINT_LINK_PATH)/%: $(MINT) $(PROJECT_ROOT)/Mintfile
	SDKROOT="" \
  MOCKOLO_LIB_SEARCH_PATH="$(shell xcode-select -p)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx" \
	MINT_PATH=$(MINT_PATH) MINT_LINK_PATH=$(MINT_LINK_PATH) \
		$(MINT) install $(notdir $@) \
		--mintfile $(PROJECT_ROOT)/Mintfile
	@touch $@
