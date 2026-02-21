# Changelog

## 1.0.7

- Added shell navigation scaffolding (StatefulShellRoute, AppNavigation, NavItem model) — commented out with placeholder values for easy activation
- Added bundled `arrow_left_icon.svg` for app bar back button
- iOS flavor builds fully configured (xcschemes, 27 build configurations, per-flavor bundle IDs and app names)
- Per-flavor app icons for iOS (AppIcon-dev, AppIcon-stg) and Android (development/staging source sets)
- Bundled BBBPoppins (headings) and SFProRounded (body) fonts with updated text styles
- Run configurations moved to `.idea/runConfigurations/` with `buildFlavor` option for Android Studio
- Fixed app crash from MainActivity namespace mismatch (`_relocateMainActivity`)
- Added `UIApplicationSceneManifest` and `ITSAppUsesNonExemptEncryption` to Info.plist
- Firebase packages kept active in pubspec (initialization remains commented out in DI)
- Centered app bar title by default, no leading image when back button is hidden

## 1.0.6

- Fixed `--version` flag to report correct version
- Keystore now uses `<project_name>-keystore.jks` filename and `<project_name>-alias`
- Keystore password set to `android` by default

## 1.0.5

- Fixed repository and issue tracker URLs to point to the correct GitHub repo
- Shortened package description to meet pub.dev guidelines (60-180 characters)
- Added example file for pub.dev documentation score

## 1.0.4

- All Codeable links now point to [gocodeable.com](https://gocodeable.com/)
- Added custom Codeable logo to README badge

## 1.0.2

- Revamped README with Table of Contents, FAQ, contributors section, and improved formatting
- Updated project structure docs (removed deprecated guards directory)
- Updated feature command docs to reflect auto-wiring behavior

## 1.0.1

- `feature` command now auto-wires everything: registers cubit in `app_page.dart`, adds route to `go_router`, and adds route constants
- Generated feature screens include `customAppBar` and `BlocBuilder` out of the box
- Repository implementations now include both `ApiService` and `AppPreferences` (cache)
- Removed deprecated `legacyCustomAppBar` from templates
- Removed unnecessary `.gitkeep` from feature widgets folder

## 1.0.0

- Initial release
- `create` command: Scaffold a complete Flutter project with Clean Architecture, BLoC/Cubit, Dio, Hive, GoRouter, and multi-flavor builds
- `feature` command: Generate feature modules with data/domain/presentation layers
- `rename` command: Rename the project across all files and configurations
- `change-id` command: Update the app/bundle identifier
- `sample` command: Add sample features with pre-built UI components
- 30+ production-ready reusable UI components
- Firebase setup with per-flavor configuration
- Android keystore generation
- AI-assisted development config (CLAUDE.md, .cursorrules)
- Localization support with ARB files
