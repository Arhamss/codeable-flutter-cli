# Changelog

## 1.0.30

### Bug Fixes
- `change-id`: iOS bundle identifier update now preserves flavor suffixes (`.dev`, `.stg`, etc.) across Debug/Release/Profile configurations instead of collapsing every flavor to the same new id. The command detects the current base bundle id (shortest Runner entry) and rebases it on the new id while keeping the per-flavor suffix and the `.RunnerTests` suffix intact.

## 1.0.29

### IDE & Build Configuration
- Fixed `.idea/runConfigurations` — removed leading newline from XML templates that prevented Android Studio/IntelliJ from parsing run configurations for development, staging, and production flavors
- Added `Makefile` to generated projects with `--obfuscate --split-debug-info=build/debug-info` flags on all release builds (APK, App Bundle, IPA for all flavors)
- Makefile includes `make help`, run/build/clean/lint/format/test targets, and code generation commands (`gen-l10n`, `gen-splash`, `gen-icons`)

### New CLI Command: `bottom-sheet`
- Added `codeable_cli bottom-sheet <name> --feature <path> --type <type>` command
- Generates a bottom sheet widget inside an existing feature's `presentation/widgets/` directory
- Four types: `action` (list of actions), `confirmation` (confirm/cancel), `form` (with inputs), `custom` (empty template)
- Auto-discovers features via interactive picker when `--feature` is not provided
- Uses the project's `CustomBottomSheet` core widget

### Project Structure Improvements
- Added `.gitkeep` to `firebase/{development,staging,production}/` directories so they're tracked by git
- `/env/` folder is gitignored — `.env.development`, `.env.staging`, `.env.production` files are created locally but not committed
- `.idea/runConfigurations/` is whitelisted in `.gitignore` so development, staging, and production run configs are committed and available on clone

## 1.0.27

### New Core Widgets
- Added `FormBuilder` widget — drives button disabled state reactively from `TextEditingController` list using `ListenableBuilder` + `Listenable.merge` (no setState, no cubit needed for form validity)
- Default validation: all fields non-empty. Custom validation via optional `validator` callback
- Added `CustomOtpField` widget — single hidden TextField approach for zero keyboard flicker, auto-paste support, blinking cursor, configurable length/size/colors/haptics
- Added `form_builder.dart` and `otp_input_field.dart` to core widgets export barrel

### CustomTextField Fixes
- Removed hidden `errorStyle` (`TextStyle(height: 0, fontSize: 0)`) that suppressed Flutter's native validation error messages
- Removed custom `ValueListenableBuilder` error display below the field
- Validation now uses Flutter's native `Form` + `TextFormField` system — error messages appear automatically when `_formKey.currentState!.validate()` is called

## 1.0.26

### Envied-Based Secret Management
- Replaced `ApiEnvironment` enum with `envied`-based `AppEnv` pattern
- Per-flavor `.env` files in gitignored `env/` folder (`env/.env.development`, `env/.env.staging`, `env/.env.production`)
- Per-flavor env dart files in `lib/config/env/` with `@Envied` annotations and XOR obfuscation for API keys
- `AppEnv` resolver class picks the correct env based on current flavor
- Added `envied` to dependencies and `envied_generator` to dev_dependencies

### Build Security & Obfuscation
- Added `Makefile` with `--obfuscate --split-debug-info=build/debug-info` for all release build targets
- Android release builds now use `shrinkResources true` and `proguard-android-optimize.txt`
- Consistent build commands: `make apk-prod`, `make bundle-prod`, `make ipa-prod`

### Template Updates
- `Endpoints` and `SocketService` templates now use `AppEnv` instead of `ApiEnvironment`
- Updated README template with envied setup documentation
- Updated AI config templates (CLAUDE.md, .cursorrules) with new env pattern

## 1.0.25

### Centralized `execute()` Error Handling
- Added `execute()` helper function to `RepositoryResponse` template for unified error handling in repositories
- Repository implementation templates now use `execute()` pattern — no manual try-catch needed
- Callbacks return `T` directly; `execute()` wraps the result in `RepositoryResponse<T>`
- `execute()` catches `AppApiException` for expected errors and logs unexpected errors via `AppLogger`

### ApiService Logging
- Replaced `debugPrint` with `AppLogger.error` in `ApiService._handleRequest` and `_handleDioError`
- Removed `flutter/material.dart` import from ApiService (was only needed for `debugPrint`)
- Added `logger_helper.dart` import to ApiService template

### AI Config
- Updated CLAUDE.md and .cursorrules templates with `execute()` pattern documentation

### New Utility Helpers
- Added `haptic_helper.dart` — semantic haptic feedback (success, error, tap, toggle, destructive)
- Added `url_helper.dart` — launch maps with coordinates (iOS/Android), launch websites
- Added `responsive_helper.dart` — device type detection, responsive values, font/padding/spacing scaling, context extensions
- Added `image_conversion_helper.dart` — convert XFile images to base64 data URIs
- Added `phone_number_parser.dart` — parse international phone numbers into country code + national number
- Added `extract_file_from_url_helper.dart` — extract filename from URL
- Added `price_formatter.dart` — format price (strips .00, keeps decimals otherwise)

## 1.0.23

### Error Handling
- Network errors (no WiFi, DNS failure, timeout) now show user-friendly messages instead of raw Dio/SocketException text
- `ApiService._handleDioError()` maps `DioExceptionType` to clean messages (connection timeout, no internet, cancelled)
- Backend error messages pass through unchanged — only system-level errors are sanitized
- Repository pattern enforced: only catch `AppApiException`, no generic `catch (e)` blocks
- Cubits no longer have try-catch — error handling belongs exclusively in the repository layer

### Resilient List Parsing
- List parsing in `fromJson` now uses safe pattern: `whereType<Map<String, dynamic>>()` + per-item try/catch
- If 1 item in a list of 100 has bad data, the other 99 parse successfully — no more full-list crashes
- Updated `ResponseDataParser`, AI config templates, and all model generation instructions

### Claude Plugin
- Updated error-handling and dio-patterns skills with new patterns
- Updated add-api, add-model, add-pagination, and add-cache commands with safe list parsing

## 1.0.22

### WebSocket Support
- Added `SocketService` with auto-reconnect, token-based auth, room join/leave, and typed broadcast streams (`lib/core/socket_service/`)
- Added `SocketStatus` enum (`disconnected`, `connecting`, `connected`, `reconnecting`, `error`)
- `SocketService` auto-registered as singleton in DI via `AppModule._setupSocketService()`
- Added `socketUrl` field to `ApiEnvironment` — per-flavor WebSocket URLs configured out of the box
- Added `web_socket_channel: ^3.0.3` to generated pubspec dependencies

### Logger Upgrade
- Replaced basic `PrettyPrinter` with custom `_AppLogPrinter` — emoji level indicators, ANSI color codes, timestamps, and tree-style stack traces
- Log levels: TRACE, DEBUG, INFO, WARN, ERROR, FATAL with distinct colors
- Automatic filtering: `DevelopmentFilter` in debug, `ProductionFilter` in release

### AI Config
- CLAUDE.md and .cursorrules now document WebSocket and logging patterns
- Added `websocket-patterns` skill to [Codeable Claude Plugin](https://github.com/gocodeable/codeable-flutter-cli-claude-plugin)

## 1.0.21

### Branding
- PNG banner with raw GitHub URL for pub.dev rendering (SVGs not supported on pub.dev)

## 1.0.20

### Branding
- Added branded banner SVG matching Codeable design system (dark purple gradient, logo, lime accent pills)

## 1.0.19

### Fixes
- Plugin marketplace source now uses HTTPS URL instead of SSH — plugin installs on any machine without SSH key setup
- Updated plugin version to 1.1.1

## 1.0.18

### New CLI Commands
- Added `doctor` command — checks project health (cubit registration, route wiring, import consistency, localization key parity across ARB files)
- Added `remove-feature` command — safely removes a feature and unwires its cubit, routes, and imports (inverse of `feature`)
- Added `add-locale` command — adds a new language/locale ARB file with TODO placeholders from the English reference

### Branding
- Updated README with Codeable branding (lime/purple badge strip, dynamic pub.dev version badge, wordmark footer with dark/light mode)
- Added Codeable wordmark SVG assets

### New Claude Plugin Skills (10 skill templates)
- `add-model` — Generate data models with fromJson/toJson/copyWith/Equatable
- `add-pagination` — Wire paginated API calls using PaginationModel in cubit state with PaginatedListView
- `add-form` — Generate validated form screens with CustomTextField, FieldValidators, and cubit submission
- `add-di` — Register services/repositories in GetIt dependency injection
- `add-hive-model` — Generate Hive TypeAdapter models with auto TypeId assignment
- `add-test` — Generate cubit and repository unit tests with mocktail and bloc_test
- `add-bottom-nav` — Wire bottom navigation with GoRouter ShellRoute
- `add-interceptor` — Add custom Dio interceptors to ApiService
- `implement-screen` — Build screens from description/Figma using core widgets and project patterns
- `add-firebase-config` — Configure Firebase for all 3 flavors using `flutterfire configure`

## 1.0.17

- Auto-install [Codeable Flutter CLI Claude Plugin](https://github.com/gocodeable/codeable-flutter-cli-claude-plugin) in generated projects via `.claude/settings.json`
- New projects get all commands, skills, agents, and hooks from the plugin automatically — no manual setup needed
- Removed inline `.claude/commands/` files (localize, fix-rtl, add-api, add-cubit-state) — the plugin now provides these and more

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
