# Changelog

## 1.0.39

### Semantic AppColors Palette
- **Reworked** the generated `AppColors` template into a clean, semantic, grouped palette — `background`/`surface`, `primary`, `text`, `status`, `border`, `shadow`, and `overlay` groups replace the old grab-bag of project-specific color names
- All generated templates (core widgets, navigation, app, feature, utils, AI config) migrated to the new semantic tokens — e.g. `blackPrimary` → `textPrimary`/`primary`, `white` → `surface`/`textOnPrimary`
- `TextStyleModifiers` now reference semantic tokens (`textPrimary`, `textOnPrimary`) instead of raw colors
- New projects get a coherent light-theme palette out of the box; existing projects are unaffected

### iOS Home-Screen Label Fix
- **Fixed** iOS collapsing spaces in multi-word app names on the home screen — flavor app names now use the `\U00A0` non-breaking-space escape in `FLAVOR_APP_NAME`, so names like `My App [DEV]` render with correct spacing
- Applies to both project generation (`project_generator.dart`) and the `change-app-name` command

### Code Quality Script Improvements
- **Improved** the generated `code_quality_check.sh` — Bash 3 compatibility (works with macOS's default shell), smarter rule detection, accurate `BlocBuilder`/`BlocListener` counting, and `dispose()` checks scoped to `StatefulWidget`s only (fewer false positives)
- **Added** `pull-requests: read` permission to the semantic-PR-title CI job

### CI Template
- **Updated** generated CI workflow Flutter version to 3.41.x

## 1.0.38

### Removed Spell Check from CI Pipeline
- **Removed** cspell spell-check job from generated `pr_quality_gate.yaml` — was producing false positives on domain-specific terms (e.g., `favorited`, `gorouter`, `imageset`, `snackbars`)
- **Removed** `.github/cspell.json` from generated project files
- **Removed** `cspellTemplate()` function from CI templates
- Existing projects: delete `.github/cspell.json` and remove the `spell-check` job from `.github/workflows/pr_quality_gate.yaml`

## 1.0.37

### Deployment CI/CD Integration
- **New** — `make deploy-setup` command added to Makefile for one-command CI/CD setup
- Integrates with [codeable-flutter-deploy](https://github.com/gocodeable/codeable-flutter-deploy) for automated TestFlight (iOS) and Firebase App Distribution (Android) builds
- Auto-clones the deploy tool if not already installed
- README updated with deployment section explaining the automated CI/CD workflow
- Push to `develop-release` for dev builds, `production` for prod builds — both platforms build automatically

## 1.0.36

### CI/CD Pipeline — Built-in Quality Gate
- **New** — every generated project now ships with a full CI/CD pipeline out of the box
- **GitHub Actions workflow** (`pr_quality_gate.yaml`) runs on PRs to `develop`/`dev`/`development` with 5 jobs: semantic PR title, format check, flutter analyze, custom code quality rules, and build verification
- **Code quality script** (`scripts/code_quality_check.sh`) enforces 33 project-specific rules across 9 categories: state management, view/widget structure, resource disposal, architecture, enums/type safety, custom components, code quality, imports, and naming conventions
- **PR template** with type-of-change checkboxes and quality checklist
- **Dependabot** config for weekly dependency updates (GitHub Actions + pub)
- **`make check`** target added to Makefile — runs format + analyze + quality script in one command
- Script only checks changed files in PRs (not the entire codebase), so existing projects can adopt incrementally
- Pre-push hook only blocks pushes to `develop`/`dev`/`development` — feature branches are unrestricted
- GitHub Actions annotations: violations appear inline on PR diffs

### Rules Enforced
- No `setState()` (use Cubit), no try-catch in cubits, `buildWhen`/`listenWhen` required
- No `_buildXyz()` methods or private classes in views, view files under 1000 lines
- Controllers/timers must have `dispose()`
- No raw `AlertDialog`, `ElevatedButton`, `SnackBar`, `DateFormat`, `print()`, `Color(0x...)`
- No `// ignore:` suppressions, one class per file, repos must use `execute()`
- Package imports only, snake_case file names
- Warnings for large files, duplicate widgets, commented-out code, cross-feature imports

## 1.0.35

### CustomButton — Single Widget, Five Factories
- **Removed** `CustomOutlineButton` — folded into `CustomButton.tertiary`. Generated apps now have a single button widget with five named factories instead of three separate widgets
- **`CustomButton.primary`** — black filled, default brand action (unchanged)
- **`CustomButton.secondary`** *(new)* — filled in `AppColors.secondaryMain`, alternate brand action
- **`CustomButton.tertiary`** — outlined (white bg, black border), takes the slot the old `CustomButton.secondary` used to fill
- **`CustomButton.danger`** *(new)* — red filled for destructive actions (delete, leave, cancel subscription)
- **`CustomButton.text`** — text-only ghost button (was previously `CustomButton.tertiary`)
- Removed redundant `loadingColor` field — uses `textColor` directly
- Added `alignPrefixStart` and `centerContent` flags for finer layout control
- Smarter disabled fallbacks: `disabledBackgroundColor ?? backgroundColor.withValues(alpha: 0.4)` instead of hardcoded `blackPrimary`
- All factories are now `const`-correct
- `socialAuthButtonTemplate` updated to use `.tertiary` (the new outlined slot)

### CustomTextField — Cleaner API & Focus Shadow
- **Removed** the `TextFieldIconConfig` indirection — prefix/suffix are now inline `Widget?` props
- Added subtle focus shadow via `DecoratedBox` (`blackPrimary` glow at 15% alpha) to signal active state without changing the fill color
- Smart `textCapitalization` (none for emails, sentences elsewhere) and smart `textInputAction` (multiline → newline, search → search, else done)
- Password eye toggle now uses `Icons.visibility`/`Icons.visibility_off` instead of the broken `dummyIcon` placeholder
- Border-radius default dropped from `100` (pill) → `12` (rounded rect); description multi-line stays `18`
- Border palette: `borderPrimary` (idle/disabled) → `blackPrimary` (focused) → `error`. Removed the focus-bg-swap to `textFieldBackground` — focus is signaled by border + shadow
- Fixed broken `context.caption` reference (didn't exist in the dual-font setup) — now uses `context.captionMedium`

### New Widgets — UserAvatar & Improved CachedImage
- **Added `UserAvatar`** — circular avatar with deterministic gradient (seeded by `user.id` so each user gets a stable color), optional photo via `CustomCachedImageWidget`, and `isLoading` overlay for upload state. Falls back to initials when the photo URL is invalid or fails to load
- **`CustomCachedImageWidget`** gained an `errorFallback: Widget?` parameter so callers (like `UserAvatar`) can render a custom widget on load failure instead of the generic placeholder. Empty-URL and image-error fallbacks now both use `SvgPicture.asset(AssetPaths.imageIcon)` with a `neutral700` color filter
- Bundled `image_icon.svg` into `lib/src/assets/svgs/` so the error fallback ships out of the box — no missing-asset crashes in fresh projects

### App Theming — Android 15 SafeArea & Theme Polish
- `AppView` is now a `StatefulWidget` that queries `device_info_plus` on launch — on Android SDK 35+ (Android 15, edge-to-edge by default) it wraps the `MaterialApp.router` content in `SafeArea` so content doesn't draw under the status/nav bars. iOS and older Android keep their existing layout
- Added `canvasColor: AppColors.backgroundPrimary` to `ThemeData` so page transitions don't flash white

### AppColors Additions
- `secondaryMain` (`#454545`) — fill for `CustomButton.secondary`; swap to brand accent
- `blackPrimaryShade` (`#000000`) — darker companion for blackPrimary gradients
- `neutral700` (`#979A9C`) — mid-dark gray for icons on placeholders
- `avatarGradients` — six gradient pairs used by `UserAvatar` (first is brand default, rest deterministically picked by `seed.hashCode`)

### API Layer — Cancel Token Support
- All `ApiService` methods (`get`, `post`, `put`, `patch`, `patchMultipart`, `delete`) now accept an optional `CancelToken? cancelToken`. `_handleRequest` rethrows `DioExceptionType.cancel` instead of wrapping it in `AppApiException`
- `delete` now also accepts an optional `data` body
- `RepositoryResponse` gained an `isCancelled` flag; `execute()` catches `DioException` of type `cancel` and returns `RepositoryResponse(isSuccess: false, isCancelled: true)` so cubits can no-op cancelled requests cleanly
- `RepositoryResponse` and `AppApiException` now carry an optional `details: List<dynamic>?` field for structured error payloads
- Generated `featureCubitTemplate` ships with a `_cancelToken` field, `close()` override, and an example cancellation pattern in comments

### ToastHelper — Match Holos Exactly
- All three toasts (`error`, `success`, `info`) now hide the close-X chip via `closeButton: const ToastCloseButton(showType: CloseButtonShowType.none)` since `closeOnClick` and `dragToClose` already handle dismissal
- Error toast's SVG icon now wears `colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn)` so it renders white on the red background
- Outer padding switched from `EdgeInsets.symmetric` to `EdgeInsetsDirectional.symmetric` for proper RTL handling

### AppLogger — Headers & Auth Token
- Added `AppLogger.authToken(String?)` — pretty-prints the bearer token in a boxed format for debug-only flows
- API request logging now **omits the `Authorization` header entirely** instead of partially masking it (`xxx...`) — cleaner request logs
- `DataState<T>` gained a `map<R>(R Function(T))` transformer for cubit-side projection without losing status/error context

### FirebaseNotificationService — Cleanup
- Replaced all `debugPrint` calls with `AppLogger.info` / `AppLogger.error` (with stack traces)
- Added `onTokenRefresh` stream getter and `handleInitialMessage()` for cold-start notification taps
- Foreground messages now route through `LocalNotificationService` so banners actually show — previously left as a TODO
- Removed `setForegroundNotificationPresentationOptions` call on iOS — was causing duplicate banners (system + flutter_local_notifications)

### Generated `.gitignore` — Mirror Holos
- New `gitignore_template.dart` overwrites Flutter's default `.gitignore` after `flutter create` with the holos-standard set: `.swiftpm/`, `.history`, `migrate_working_dir/`, `app.*.symbols`, `app.*.map.json`, `/android/app/{debug,profile,release}`, `/coverage/`, `/env/`, `**/*.jks`, `**/*.keystore`, `**/android/key.properties`, etc.
- The CLI's existing `.idea/runConfigurations/` whitelist append still runs on top, preserving the IDE-config-commit behavior

### Text Style System — Dual Font with Weight Variants
- **Switched** the text-style extension to a structured size + weight system across two fonts (`AppFonts.heading` = BBBPoppins for `display`/`h1`–`h5`, `AppFonts.body` = SFProRounded for `p1`/`p2`/`caption`/`overline`)
- Each size has three weight variants: `h1`/`h1Medium`/`h1Bold`, `p1`/`p1Medium`/`p1Bold`, `caption`/`captionMedium`/`captionBold`
- Added `display` (43, w400, heading font), `overline` (10, w400, body font), and `letterSpacing` parameter to the private style builders
- New text style modifiers: `.primary`, `.secondary`, `.light`, `.hint` (replaces the old `.secondary` / `.tertiary` pair)
- All template references migrated from old `b1`/`b2`/`l2` getters to new `p1Medium`/`p2`/`captionMedium`

### New Generated File — String Extensions
- Added `lib/utils/extensions/string_extensions.dart` with a `titleCase` getter (splits on `_` or whitespace, capitalizes each word)

### AI Config (CLAUDE.md / .cursorrules) — Major Enrichment
Pulled in everything generated apps were previously missing:
- **Layer Rules** — explicit dependency direction (`presentation → domain ← data`)
- **When to Create a Separate Feature** decision rule
- **Shared Models** — `core/models/common/` for cross-feature models
- Full **State Pattern code example** — `Equatable` + `DataState<T>` wrapping + `copyWith` template
- **Custom Components — MANDATORY** section listing every banned raw widget/API and the required replacement, including the new `CustomCachedImageWidget` and `UserAvatar` bans
- Full **Enums & Extensions code example** with `displayName` / `color` / `fromString` switch patterns
- **Naming conventions** — file/class/variable/constant/enum casing rules
- **Imports** — package imports only, no relative paths
- **AppLogger.error** requirement in repository error handling
- **SafeArea documentation** — explains the `AppView` Android 15 behavior so AI doesn't add manual `SafeArea` per screen
- **Quick Reference Checklist** — 22-item review checklist for self-audit
- Updated `CustomButton` factory list (5 variants) and `CustomTextField` factory list across both AI configs
- Updated text-style docs to reflect the dual-font setup with all size + weight variants enumerated

### CLI Commands
- **`create`**: app-name prompt now defaults to Title Case (`my_app` → "My App") instead of PascalCase ("MyApp"), matching what users typically type for the human-readable display name
- **`change-app-name`**: now scans `lib/l10n/` recursively for `.arb` files instead of just the top level — picks up files in `arb/` subfolders that the new project layout uses
- Added `TemplateEngine.toTitleCase()` helper

### Dependency Updates (generated `pubspec.yaml`)
- `bloc` ^9.2.0 → ^9.2.1
- `dio` ^5.9.1 → ^5.9.2
- `go_router` ^17.2.0 → ^17.2.3
- `firebase_core` ^4.6.0 → ^4.8.0
- `firebase_messaging` ^16.1.3 → ^16.2.1
- `firebase_remote_config` ^6.3.0 → ^6.5.0
- `sign_in_with_apple` ^7.0.1 → ^8.0.0 (major)
- `purchases_flutter` ^9.16.1 → ^10.0.2 (major)
- `flutter_svg` ^2.2.4 → ^2.3.0
- `image_picker` ^1.2.1 → ^1.2.2
- `toastification` ^3.1.0 → ^3.2.0
- `device_info_plus` ^12.3.0 → ^12.4.0
- `build_runner` ^2.11.1 → ^2.15.0
- `envied_generator` ^1.3.4 → ^1.3.5
- **Removed**: `firebase_auth`, `cloud_firestore`, `firebase_storage` (add per project)
- **Removed**: `lottie`, `blur`, `flutter_swipe_button` (add per project)

## 1.0.34

### iOS Signing — Strip Host Machine's DEVELOPMENT_TEAM
- **Fixed** `flutter create` baking the host machine's `DEVELOPMENT_TEAM` ID into every Runner build configuration of the generated `project.pbxproj`. Previously this leaked whichever Apple Developer Team was active on the machine that ran the CLI into all 9 flavor configs (Debug/Release/Profile × production/staging/development), pinning every developer who later opened the project to a team they didn't own
- The flavor build-configuration generator now strips the `DEVELOPMENT_TEAM = ...;` line when it duplicates the original Runner blocks, so each flavor opens in Xcode with `Team: None` and developers can pick their own team via "Automatically manage signing"

## 1.0.33

### Logging Overhaul — Zero-Dependency AppLogger
- **Replaced** the `logger` package-based `AppLogger` with a zero-dependency implementation using `debugPrint` directly — no external packages needed
- `AppLogger` now includes API-specific logging methods: `apiRequest()`, `apiResponse()`, `apiError()` with pretty-printed JSON, box-drawing borders, elapsed time display, and authorization header masking (first 15 chars only)
- General logging uses `debugPrint` (not `print`) to avoid dropped lines on Android, with filtered stack traces (excludes `dart:`, `flutter/`, `bloc/`, `dio/` frames, max 5 frames)
- Removed `logger: ^2.6.2` from generated project dependencies

### Log Interceptor — Uses AppLogger API Methods
- **Replaced** raw `print()` calls in `LoggingInterceptor` with `AppLogger.apiRequest/apiResponse/apiError` methods
- Added request timestamp tracking via `_timestamps` map for elapsed time calculation on every response/error
- Added smart error message extraction: checks `response.data.error.message`, then `response.data.message`, then `err.message`

### API Response Parser — Enhanced with Key Access & Value Parsing
- Added private `_extractData()` helper to DRY up data extraction from the `{"data": ...}` envelope
- `parse()` and `parseList()` now accept an optional `key` parameter for accessing nested objects/lists within the data envelope (e.g. `response.data.data.profile`)
- Added `parseValue<T>()` method for extracting single primitive values by key (e.g. `total_count`, `has_more`)

### Dependency Updates
- Removed `logger` package (replaced by zero-dependency AppLogger)
- `flutter_local_notifications` ^20.1.0 → ^21.0.0 (major)
- `camera` ^0.11.4 → ^0.12.0+1 (minor)
- `firebase_core` ^4.4.0 → ^4.6.0
- `firebase_messaging` ^16.1.1 → ^16.1.3
- `firebase_remote_config` ^6.1.4 → ^6.3.0
- `go_router` ^17.1.0 → ^17.2.0
- `purchases_flutter` ^9.12.2 → ^9.16.1
- `envied` / `envied_generator` ^1.1.1 → ^1.3.4
- `toastification` ^3.0.3 → ^3.1.0
- `flutter_svg` ^2.2.3 → ^2.2.4
- `lottie` ^3.3.2 → ^3.3.3
- `video_player` ^2.11.0 → ^2.11.1

## 1.0.32

### iOS UIScene Lifecycle — Use Official Flutter APIs
- **Breaking fix:** Replaced manual `FlutterEngine` creation in `AppDelegate.swift` with the official Flutter 3.41+ `FlutterImplicitEngineDelegate` protocol — the previous approach caused a black screen on startup because the engine wasn't connected to the Flutter view
- `AppDelegate` now conforms to `FlutterImplicitEngineDelegate` and registers plugins via `didInitializeImplicitFlutterEngine(_:)` instead of manually in `didFinishLaunchingWithOptions`
- `SceneDelegate` now subclasses `FlutterSceneDelegate` (a single empty subclass) instead of manually creating `FlutterViewController` and wiring the engine — Flutter handles this internally
- Info.plist `UIApplicationSceneManifest` unchanged (already correct from 1.0.31)
- Reference: https://docs.flutter.dev/release/breaking-changes/uiscenedelegate

## 1.0.31

### iOS UIScene Lifecycle Migration
- Added `AppDelegate.swift` template — creates a `FlutterEngine` eagerly and registers plugins, replacing the default Flutter-generated AppDelegate that uses the old `UIApplicationDelegate` lifecycle
- Added `SceneDelegate.swift` template — implements `UIWindowSceneDelegate` to manage the app window via `UIWindowScene`, using the FlutterEngine from AppDelegate
- Info.plist already included `UIApplicationSceneManifest` with SceneDelegate reference (added in a prior version) — now the corresponding Swift files are generated to match
- This ensures all new projects are compatible with upcoming iOS versions that require UIScene lifecycle support (see https://flutter.dev/to/uiscene-migration)

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
