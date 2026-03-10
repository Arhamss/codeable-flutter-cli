# Changelog

## 1.0.17

- Auto-install [codeable Claude plugin](https://github.com/gocodeable/codeable-claude-plugin) in generated projects via `.claude/settings.json`
- New projects get all 34 commands, 13 skills, 9 agents, and 2 hooks from the plugin automatically — no manual setup needed
- Removed inline `.claude/commands/` files (localize, fix-rtl, add-api, add-cubit-state) — the plugin now provides these and 30 more

## 1.0.16

- Added `pageTransitionsTheme` to `ThemeData` with `FadeForwardsPageTransitionsBuilder` for smooth Android page transitions

## 1.0.15

- `feature` command no longer auto-prompts for role selection when multiple role directories exist
- Role selection is now opt-in: use `--role <name>` to specify a role directly, or `--pick-role` (`-R`) to interactively choose from existing role directories
- Without `--role` or `--pick-role`, features are created directly in `lib/features/`
- Added `Localization` static service (`lib/l10n/localization_service.dart`) for accessing localized strings without `BuildContext`
- `Localization.keyName` works anywhere (validators, formatters, models); `context.l10n.keyName` remains preferred in widgets
- `l10n.dart` barrel file now exports `localization_service.dart` so a single import gives access to both `context.l10n` and `Localization`
- `AppView` builder auto-updates the `Localization` service on every locale change
- Added `/localize` Claude Code slash command (`.claude/commands/localize.md`) that auto-localizes an entire feature directory
- Fixed all remaining `EdgeInsets.only(left/right)` and `EdgeInsets.fromLTRB` in templates to use `EdgeInsetsDirectional` for proper RTL support
- Added `/fix-rtl` Claude Code command to migrate `EdgeInsets` to `EdgeInsetsDirectional` in existing projects
- Added `/add-api` Claude Code command to wire up a new API endpoint end-to-end through all architecture layers
- Added `/add-cubit-state` Claude Code command to add new state fields and cubit methods to existing features
- Updated CLAUDE.md and .cursorrules templates with localization pattern documentation

## 1.0.14

- Chucker Flutter network inspector is now only active in the development flavor (disabled in staging and production)

## 1.0.13

- Suppressed Java 8 source/target deprecation warnings globally via root `build.gradle.kts`
- Disabled automatic signing in iOS (ProvisioningStyle = Manual) so Xcode doesn't pre-select a team

## 1.0.12

- Added `change-app-name` command to update app display name across Android, iOS, l10n, and constants
- Updated all dependency versions to latest (Firebase 4.x, GoRouter 17.x, get_it 9.x, etc.)
- Fixed staging/development flavors using PascalCase instead of app display name
- Moved `update` command documentation near Installation in README

## 1.0.11

- Added `--app-name` option to `create` command for setting the app display name separately from the project name
- Toast helper now uses custom SVG icons (success, error, info) instead of Material Icons
- Removed `showWarningToast` from toast helper
- `CustomSocialAuthButton.iconPath` is now required
- Login screen includes emblem logo and social auth icons out of the box
- Bundled all SVG assets (search, filter, dropdown, tick, star, social auth, emblem, codeable logo)
- Cleaned up `AssetPaths` — removed unused entries, fixed duplicate `errorIcon`
- README code blocks split for easier copying

## 1.0.8

- Flavor display names now use suffix format: `MyApp [DEV]`, `MyApp [STG]`
- Added `kotlin-stdlib:2.2.10` dependency to Android build.gradle.kts
- Suppressed Java 8 source/target deprecation warnings from dependencies
- Removed home screen navigation from splash (logs auth token only)

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
