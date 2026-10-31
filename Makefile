# Uses FVM when it is installed; override with `make FLUTTER=flutter DART=dart`.
FVM     := $(shell command -v fvm 2>/dev/null)
FLUTTER ?= $(if $(FVM),fvm flutter,flutter)
DART    ?= $(if $(FVM),fvm dart,dart)
FORMAT_DIRS := lib test bin example tool

.PHONY: setup test fmt analyze index check

setup:
	$(if $(FVM),fvm install,)
	$(FLUTTER) pub get
	@if command -v lefthook >/dev/null 2>&1; then lefthook install; else echo "lefthook not found, skipping git hooks"; fi

# Runs `flutter test`, then the daylight-saving tests under a zone that has them.
test:
	@echo "== flutter test"; $(FLUTTER) test
	@echo "== flutter test (TZ=America/New_York)"
	@TZ=America/New_York $(FLUTTER) test test/extensions/datetime_dst_test.dart

fmt:
	$(DART) format $(FORMAT_DIRS)

analyze:
	@echo "== flutter analyze"; $(FLUTTER) analyze --no-pub
	@echo "== dart analyze (tool)"; $(DART) analyze --fatal-infos tool

# Regenerates the AGENTS.md index block, doc/index.txt and the per-declaration
# docs in doc/ from the `///` comments.
index:
	$(DART) run tool/agent_index.dart
	$(DART) run tool/component_docs.dart

# Fails when a generated file is stale.
check:
	$(DART) format --output=none --set-exit-if-changed $(FORMAT_DIRS)
	$(DART) run tool/agent_index.dart --check
	$(DART) run tool/component_docs.dart --check
	$(MAKE) analyze
	$(MAKE) test
