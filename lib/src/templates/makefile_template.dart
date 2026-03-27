const makefileTemplate = r'''
BUILD_FLAGS = --obfuscate --split-debug-info=build/debug-info

.PHONY: help clean get build-runner lint format test \
        run-dev run-stg run-prod \
        apk-dev apk-stg apk-prod \
        bundle-prod ipa-dev ipa-stg ipa-prod \
        gen-l10n gen-splash gen-icons

# ──────────────────────────── Help ────────────────────────────
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-24s\033[0m %s\n", $$1, $$2}'

# ──────────────────────────── Setup ───────────────────────────
clean: ## Clean and re-fetch dependencies
	flutter clean && flutter pub get

get: ## Get dependencies
	flutter pub get

build-runner: get ## Run build_runner (code gen)
	dart run build_runner build --delete-conflicting-outputs

# ──────────────────────────── Quality ─────────────────────────
lint: ## Run dart analyze
	dart analyze lib

format: ## Format all Dart files
	dart format lib test

test: ## Run all tests
	flutter test

# ──────────────────────────── Run ─────────────────────────────
run-dev: ## Run development flavor
	flutter run --flavor development -t lib/main_development.dart

run-stg: ## Run staging flavor
	flutter run --flavor staging -t lib/main_staging.dart

run-prod: ## Run production flavor
	flutter run --flavor production -t lib/main_production.dart

# ──────────────────────────── Android ─────────────────────────
apk-dev: ## Build APK (development)
	flutter build apk --flavor development -t lib/main_development.dart $(BUILD_FLAGS)

apk-stg: ## Build APK (staging)
	flutter build apk --flavor staging -t lib/main_staging.dart $(BUILD_FLAGS)

apk-prod: ## Build APK (production)
	flutter build apk --flavor production -t lib/main_production.dart $(BUILD_FLAGS)

bundle-prod: ## Build App Bundle (production)
	flutter build appbundle --flavor production -t lib/main_production.dart $(BUILD_FLAGS)

# ──────────────────────────── iOS ─────────────────────────────
ipa-dev: ## Build IPA (development)
	flutter build ipa --flavor development -t lib/main_development.dart $(BUILD_FLAGS)

ipa-stg: ## Build IPA (staging)
	flutter build ipa --flavor staging -t lib/main_staging.dart $(BUILD_FLAGS)

ipa-prod: ## Build IPA (production)
	flutter build ipa --flavor production -t lib/main_production.dart $(BUILD_FLAGS)

# ──────────────────────────── Code Gen ────────────────────────
gen-l10n: ## Generate localizations
	flutter gen-l10n

gen-splash: ## Generate native splash
	dart run flutter_native_splash:create

gen-icons: ## Generate launcher icons
	dart run flutter_launcher_icons
''';
