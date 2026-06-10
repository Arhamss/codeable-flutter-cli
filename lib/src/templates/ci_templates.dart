const prQualityGateWorkflowTemplate = r'''
name: PR Quality Gate

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

on:
  pull_request:
    branches: [develop, dev, development]
    paths:
      - "lib/**"
      - "test/**"
      - "pubspec.yaml"
      - "analysis_options.yaml"
      - "scripts/**"
      - ".github/workflows/pr_quality_gate.yaml"
  push:
    branches: [develop, dev, development]
    paths:
      - "lib/**"
      - "test/**"
      - "pubspec.yaml"

jobs:
  semantic-pr:
    if: github.event_name == 'pull_request'
    permissions:
      pull-requests: read
    uses: VeryGoodOpenSource/very_good_workflows/.github/workflows/semantic_pull_request.yml@v1

  flutter-checks:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.41.x"
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Check formatting
        run: dart format --set-exit-if-changed lib/

      - name: Run analyzer
        run: flutter analyze --fatal-infos

  code-quality:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Fetch base branch
        if: github.event_name == 'pull_request'
        run: git fetch origin ${{ github.base_ref }}

      - name: Run code quality checks
        env:
          BASE_REF: origin/${{ github.base_ref || 'develop' }}
        run: |
          chmod +x scripts/code_quality_check.sh
          ./scripts/code_quality_check.sh

  build-check:
    runs-on: ubuntu-latest
    needs: [flutter-checks]
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.41.x"
          cache: true

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: "temurin"
          java-version: "17"

      - name: Install dependencies
        run: flutter pub get

      - name: Run code generation
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Generate localizations
        run: flutter gen-l10n

      - name: Build APK (development, debug)
        run: flutter build apk --flavor development --target lib/main_development.dart --debug
''';

const prTemplateContent = '''
## Description

<!--- Describe your changes in detail -->

## Type of Change

<!--- Put an `x` in all the boxes that apply: -->

- [ ] New feature (non-breaking change which adds functionality)
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Code refactor
- [ ] Build configuration change
- [ ] Documentation
- [ ] Chore
- [ ] Test

## Checklist

- [ ] Code follows project architecture (Clean Architecture + Cubit)
- [ ] No `setState()`, no `_buildXyz()`, no private widgets in views
- [ ] Custom components used (CustomButton, CustomConfirmationDialog, ToastHelper, etc.)
- [ ] `flutter analyze` passes with zero issues
- [ ] Ran `./scripts/code_quality_check.sh` locally
''';

const dependabotTemplate = '''
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
  - package-ecosystem: "pub"
    directory: "/"
    schedule:
      interval: "weekly"
''';
