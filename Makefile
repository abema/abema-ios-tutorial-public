include Config/Makefile/shared.mk

APP_NAME=AbemaTutorial

TEST_SCHEMES = \
	Extension \
	UILogic \
	UseCase

BUILD_DIR=$(PROJECT_ROOT)/build
RESULT_BUNDLE_PATH ?= $(BUILD_DIR)/xcresults/$(subst /,_,$@)_$(shell date +%Y%m%d%H%M%S).xcresult

BUNDLER_VERSION = $(shell tail -n 1 Gemfile.lock | tr -cd "[:digit:]\.")
BUNDLE_EXEC=bundle _$(BUNDLER_VERSION)_ exec

XCODE_OUTPUT_FORMATTER ?= $(XCBEAUTIFY)

PODS_ROOT ?= $(PROJECT_ROOT)/Pods
PODS_PROJECT ?= $(PODS_ROOT)/Pods.xcodeproj
PODS_BUILD_DIR ?= $(PODS_ROOT)/_Build
PODS_REPO_UPDATE_TIMESTAMP := ./Pods/.repo-update-timestamp
PODS_BUILD_TARGETS ?=

default: bootstrap

# Bootstrap

.PHONY: bootstrap
bootstrap: pod-build mockolo

# RubyGems

install-gems: vendor/bundle

vendor/bundle: Gemfile Gemfile.lock
	scripts/install-bundler.sh
	@touch vendor/bundle

# CocoaPods

.PHONY: pod-install
pod-install: install-gems xcodegen $(PODS_REPO_UPDATE_TIMESTAMP)
	@xcodebuild -version > Pods/xcodebuild.version
	$(BUNDLE_EXEC) pod install
	$(MAKE) $(PODS_ROOT)/.gitignore
	@# CocoaPodsがxcodeprojを変更してしまうので再生成する
	$(MAKE) xcodegen

# 直接使用するファイルが存在するディレクトリをignoreしないためのgitignoreを生成
#
# xcconfigとxcfilelistから参照されているファイル名を検索する
# PODS_TARGET_SRCROOTは全てのPodsに定義されているので無視する
$(PODS_ROOT)/.gitignore: FORCE
	@find Pods/Target\ Support\ Files -name '*.xcconfig' -or -name '*.xcfilelist' \
		| xargs -I{} grep -v -E 'PODS_TARGET_SRCROOT =' {} \
		| grep -o -E '\$$\{PODS_ROOT\}/.[a-zA-Z0-9 _-]+' \
		| sort -u \
		| PODS_ROOT= envsubst \
		| xargs -I{} echo !{} \
		> $@

# CocoaPodsでインストールしたPodを事前ビルドする
#
# Usage:
#     make pod-build                            ... 全てのPodを再ビルド
#     make pod-build PODS_BUILD_TARGETS="A B C" ... Pod A, B, Cとその依存Podを再ビルド
.PHONY: pod-build
pod-build: pod-build/iphoneos pod-build/iphonesimulator

.PHONY: pod-build
pod-build/%: pod-install
	xcodebuild build \
		-project $(PODS_PROJECT) \
		-sdk $(notdir $@) \
		$(if $(PODS_BUILD_TARGETS),$(addprefix -target ,$(PODS_BUILD_TARGETS)),-alltargets) \
		-configuration Release \
		ONLY_ACTIVE_ARCH=NO \
		SYMROOT=$(PODS_BUILD_DIR) \
		| $(MAKE) test-output-formatter
	scripts/cocoapods/pod-checksum.rb --update $(PODS_BUILD_TARGETS)

$(PODS_REPO_UPDATE_TIMESTAMP): vendor/bundle Podfile Podfile.lock
	$(BUNDLE_EXEC) pod repo update
	@touch $(PODS_REPO_UPDATE_TIMESTAMP) >> /dev/null || true

# Tools

.PHONY: brew-install
brew-install:
	$(BREW_PREFIX)/bin/brew install rbenv

mockolo: $(MOCKOLO)
ifeq ($(CI),)
	$(MAKE) -C ./Targets/UseCaseInterface mockolo
	$(MAKE) -C ./Targets/Domain mockolo
	$(MAKE) -C ./Targets/UILogicInterface mockolo
else
	@echo Skipping Mockolo on CI
endif

.PHONY: xcodegen
xcodegen: $(XCODEGEN)
	BREW_PREFIX=$(BREW_PREFIX) \
		$(XCODEGEN)

.PHONY: xcodegen-dump
xcodegen-dump: $(XCODEGEN)
	@$(XCODEGEN) dump --type json

# Xcode build commands

.PHONY: build
build:
	xcodebuild build \
		-project $(APP_NAME).xcodeproj \
		-scheme $(APP_NAME) \
		-configuration Debug \
		-destination 'platform=iOS Simulator,name=iPhone 14' \
		-resultBundlePath $(RESULT_BUNDLE_PATH) \
		CODE_SIGNING_ALLOWED=NO \
		COMPILER_INDEX_STORE_ENABLE=NO

.PHONY: test
test: $(addprefix test/,$(TEST_SCHEMES))
test/%: FORCE
	xcodebuild test \
		-project $(APP_NAME).xcodeproj \
		-scheme $(notdir $@) \
		-configuration Debug \
		-destination 'platform=iOS Simulator,name=iPhone 14' \
		-resultBundlePath $(RESULT_BUNDLE_PATH) \
		CODE_SIGNING_ALLOWED=NO \
		COMPILER_INDEX_STORE_ENABLE=NO

# Utils

.PHONY: test-output-formatter
test-output-formatter: $(XCBEAUTIFY)
	$(XCODE_OUTPUT_FORMATTER)

.PHONY: FORCE
FORCE:
