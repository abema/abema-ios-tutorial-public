# Mint

MINT ?= /usr/local/bin/mint
MINT_PATH = ./.mint/lib
MINT_LINK_PATH = ./.mint/bin

# Default tool paths
XCODEGEN ?= $(MINT_LINK_PATH)/xcodegen

# Bootstrap

.PHONY: bootstrap
bootstrap: cocoapods/bootstrap

# Third-party libraries installation

.PHONY: carthage/bootstrap
carthage/bootstrap:
	carthage bootstrap --platform iOS --cache-builds

.PHONY: carthage/update
carthage/update:
	carthage update --platform ios

.PHONY: cocoapods/bootstrap
cocoapods/bootstrap: gem-install xcodegen
	bundle exec pod install

# Tools

.PHONY: brew-install
brew-install:
	brew install carthage rbenv swiftlint xcodegen

.PHONY: gem-install
gem-install:
	bundle install

/usr/local/bin/mint:
	brew install mint

.PHONY: xcodegen
xcodegen: $(XCODEGEN)
	$(RM) -r ./*.xcodeproj
	$(XCODEGEN)

$(MINT_LINK_PATH)/xcodegen: $(MINT) Mintfile
	MINT_PATH=$(MINT_PATH) MINT_LINK_PATH=$(MINT_LINK_PATH) \
		$(MINT) install xcodegen

# Xcode build commands

.PHONY: build
build:
	xcodebuild build \
		-workspace AbemaTutorial.xcworkspace \
		-scheme AbemaTutorial \
		-configuration Debug \
		-destination 'platform=iOS Simulator,name=iPhone 11' \
		CODE_SIGNING_ALLOWED=NO \
		COMPILER_INDEX_STORE_ENABLE=NO

.PHONY: test
test:
	xcodebuild test \
		-workspace AbemaTutorial.xcworkspace \
		-scheme AbemaTutorial \
		-configuration Debug \
		-destination 'platform=iOS Simulator,name=iPhone 11' \
		CODE_SIGNING_ALLOWED=NO \
		COMPILER_INDEX_STORE_ENABLE=NO
