<p align="center">
  <img src="https://img.shields.io/badge/FLUTTER-CLI-b7ff00?style=for-the-badge&labelColor=0e0926" alt="Flutter CLI" />
  <img src="https://img.shields.io/badge/DART-352e5c?style=for-the-badge&labelColor=0e0926&logo=dart&logoColor=b7ff00" alt="Dart" />
  <img src="https://img.shields.io/badge/FLUTTER-352e5c?style=for-the-badge&labelColor=0e0926&logo=flutter&logoColor=b7ff00" alt="Flutter" />
  <img src="https://img.shields.io/pub/v/codeable_cli?style=for-the-badge&color=6b6190&labelColor=0e0926" alt="pub.dev" />
</p>

<p align="center">
  <strong>Production-ready Flutter project scaffolding — Clean Architecture, BLoC/Cubit, Dio, Hive, GoRouter, multi-flavor builds, and 30+ UI components, all wired together in seconds.</strong>
</p>

<p align="center">
  <a href="https://pub.dev/packages/codeable_cli">pub.dev</a> &nbsp;&bull;&nbsp; <a href="https://github.com/Arhamss/codeable-flutter-cli">GitHub</a> &nbsp;&bull;&nbsp; <a href="https://github.com/Arhamss/codeable-flutter-cli/issues">Issues</a>
</p>

---

## Overview

Starting a new Flutter project means hours of boilerplate — setting up architecture, configuring flavors, wiring DI, adding interceptors, building reusable widgets, and configuring platform files. **Codeable CLI does all of that in seconds.**

| Metric | Detail |
|--------|--------|
| Architecture | Clean Architecture (feature-first) |
| State Management | BLoC/Cubit with DataState |
| Networking | Dio with auth, logging, Chucker interceptors |
| Storage | Hive-based local storage |
| Navigation | GoRouter with named routes |
| UI Components | 30+ production-ready widgets |
| Build Flavors | Development, Staging, Production |
| Platforms | Android & iOS pre-configured |
| Firebase | Multi-environment directory structure |
| Localization | ARB files with `context.l10n` + static `Localization` service |
| AI Config | CLAUDE.md + .cursorrules + [Claude Plugin](https://github.com/gocodeable/codeable-flutter-cli-claude-plugin) (auto-installed) |

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Commands](#commands)
- [Generated Architecture](#generated-architecture)
- [Included UI Components](#included-ui-components)
- [Multi-Flavor Builds](#multi-flavor-builds)
- [Platform Configuration](#platform-configuration)
- [AI-Assisted Development](#ai-assisted-development)
- [FAQ](#faq)
- [Contributing](#contributing)
- [Contributors](#contributors)
- [License](#license)

---

## Prerequisites

Before installing Codeable CLI, make sure you have:

- [Dart SDK](https://dart.dev/get-dart) >= 3.0
- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.0
- [Java/JDK](https://adoptium.net/) >= 17 (required for Android keystore generation)

---

## Installation

### Activate from pub.dev

```bash
dart pub global activate codeable_cli
```

### Activate a specific version

```bash
dart pub global activate codeable_cli 1.0.18
```

### Or run without activating

If you prefer not to globally activate (e.g., in CI), you can run commands directly:

```bash
dart pub global run codeable_cli:codeable_cli <command> <args>
```

### Update to the latest version

```bash
codeable_cli update
```

### Verify installation

```bash
codeable_cli --help
```

> **Note:** If `codeable_cli` is not found after activation, make sure `~/.pub-cache/bin` is in your system PATH:
>
> ```bash
> # macOS / Linux — add to ~/.zshrc or ~/.bashrc
> export PATH="$PATH":"$HOME/.pub-cache/bin"
>
> # Windows — add to your system environment variables
> # %LOCALAPPDATA%\Pub\Cache\bin
> ```
>
> After adding, restart your terminal or run `source ~/.zshrc`.

---

## Quick Start

Create a new project:
```bash
codeable_cli create --name my_app --app-name "My App" --org com.example.myapp
```

Navigate into the project:
```bash
cd my_app
```

Run it:
```bash
flutter run --flavor development -t lib/main_development.dart
```

That's it. Your project is ready with the full architecture, all dependencies installed, and the keystore generated.

### Generate a new feature

```bash
codeable_cli feature profile
```

This creates the full feature module directly in `lib/features/profile/` **and** auto-wires everything:
- Cubit registered in `app_page.dart`'s MultiBlocProvider
- Route added to `go_router` with named route constants
- Navigate with `context.goNamed(AppRouteNames.profileScreen)`

### Role-based features

Organize features by user role (e.g., customer, admin):

```bash
codeable_cli feature home --role customer
```

This creates `lib/features/customer/home/` with all files and classes prefixed — `CustomerHomeScreen`, `CustomerHomeCubit`, route `/customer-home`.

To interactively pick from existing role directories:

```bash
codeable_cli feature home --pick-role
```

### Verify everything works

```bash
flutter analyze   # Should show zero errors
flutter test      # Run tests
```

---

## Commands

### `create` — Scaffold a new project

```bash
codeable_cli create [options]
```

| Option | Description | Default |
|--------|-------------|---------|
| `-n, --name` | Project name (snake_case) | Prompted interactively |
| `-a, --app-name` | Display name of the app (e.g., `My App`) | Prompted interactively |
| `-o, --org` | Organization identifier (e.g., `com.example.app`) | Prompted interactively |
| `-d, --description` | Project description | `A new Flutter project` |
| `--output` | Output directory | `.` (current directory) |
| `--roles` | Comma-separated role directories under `features/` (e.g., `customer,admin`) | None |

**What it generates:**

```
my_app/
├── lib/
│   ├── main_development.dart       # Dev entry point (with DevicePreview)
│   ├── main_staging.dart           # Staging entry point
│   ├── main_production.dart        # Production entry point
│   ├── bootstrap.dart              # App initialization & DI setup
│   ├── exports.dart                # Global barrel exports
│   ├── app/view/                   # App root (MaterialApp.router, theme, splash)
│   ├── config/                     # Flavor config, API environment, remote config
│   ├── constants/                  # Colors, text styles, asset paths, constants
│   ├── core/
│   │   ├── api_service/            # Dio client + auth/log interceptors
│   │   ├── app_preferences/        # Hive-based local storage
│   │   ├── di/                     # GetIt dependency injection
│   │   ├── endpoints/              # API endpoint definitions
│   │   ├── locale/                 # Locale cubit for i18n
│   │   ├── models/                 # API response & auth models
│   │   ├── notifications/          # Firebase & local notifications
│   │   ├── permissions/            # Permission manager
│   │   └── field_validators.dart   # Form validation (email, phone, etc.)
│   ├── features/
│   │   └── onboarding/             # Sample feature (login screen)
│   ├── go_router/                  # GoRouter config, routes, named routes
│   ├── l10n/                       # Localization (ARB files, context.l10n, Localization service)
│   └── utils/
│       ├── extensions/             # Dart extensions
│       ├── helpers/                # Toast, layout, decorations, logger, etc.
│       ├── response_data_model/    # Response parsing utilities
│       └── widgets/core_widgets/   # 30+ reusable UI components
├── .run/                           # Android Studio run configurations (Dev/Staging/Prod)
├── assets/                         # images, vectors, animation, fonts
├── firebase/                       # Per-flavor Firebase config directories
├── android/                        # Configured with flavors, signing, ProGuard
├── ios/                            # Configured with Podfile, Info.plist, entitlements
├── CLAUDE.md                       # AI assistant context (Claude Code)
├── .cursorrules                    # AI assistant context (Cursor)
└── README.md                       # Project documentation
```

---

### `feature` — Generate a feature module

Must be run from inside an existing Codeable project.

```bash
codeable_cli feature <feature_name> [--role <role> | --pick-role]
```

| Option | Description |
|--------|-------------|
| `--role, -r` | Role prefix (e.g., `customer`, `admin`). Places the feature under `features/<role>/` and prefixes all file names, class names, and routes with the role. |
| `--pick-role, -R` | Interactively pick a role from existing role directories under `lib/features/`. |

**Basic example:**

```bash
codeable_cli feature profile
```

```
lib/features/profile/
├── data/
│   ├── models/profile_model.dart
│   └── repository/profile_repository_impl.dart
├── domain/
│   └── repository/profile_repository.dart
└── presentation/
    ├── cubit/
    │   ├── cubit.dart
    │   └── state.dart
    ├── views/profile_screen.dart
    └── widgets/
```

**Role-based example:**

```bash
codeable_cli feature home --role customer
```

```
lib/features/customer/home/
├── data/
│   ├── models/customer_home_model.dart
│   └── repository/customer_home_repository_impl.dart
├── domain/
│   └── repository/customer_home_repository.dart
└── presentation/
    ├── cubit/
    │   ├── cubit.dart
    │   └── state.dart
    ├── views/customer_home_screen.dart
    └── widgets/
```

With `--role`, all class names are prefixed (e.g., `CustomerHomeScreen`, `CustomerHomeCubit`) and the route becomes `/customer-home`. Without `--role`, behavior is identical to before.

Each generated file comes with boilerplate — the repository interface, implementation wired to `ApiService` and `AppPreferences` (cache), cubit with `DataState`, and a screen scaffold with `customAppBar` and `BlocBuilder`.

**Auto-wired out of the box:**
- Cubit registered in `app_page.dart`'s `MultiBlocProvider`
- Route added to `go_router/router.dart`
- Route constants added to `AppRoutes` and `AppRouteNames`
- Screen import added to `go_router/exports.dart`
- Navigate with `context.goNamed(AppRouteNames.customerHomeScreen)`

---

### `rename` — Rename a project

```bash
codeable_cli rename --name <new_name>
```

Updates the package name in `pubspec.yaml`, renames all `package:old_name/` imports across the codebase, renames the project folder, and runs `flutter pub get`.

---

### `change-app-name` — Change app display name

```bash
codeable_cli change-app-name --name "New App Name"
```

| Option | Description |
|--------|-------------|
| `-n, --name` | The new display name (e.g., `"My App"`) |

Updates the app display name across the entire project:
- `android/app/build.gradle.kts` (flavor `manifestPlaceholders`)
- `ios/Runner.xcodeproj/project.pbxproj` (`FLAVOR_APP_NAME`)
- `lib/constants/app_constants.dart` (`AppConstants.appName`)
- `lib/l10n/app_*.arb` (localization `appName` key)

Staging and development flavors are automatically suffixed with `[STG]` and `[DEV]`.

---

### `change-id` — Change bundle identifier

```bash
codeable_cli change-id --id <new_id>
```

Updates the application/bundle identifier in:
- `android/app/build.gradle.kts` (namespace + applicationId)
- `android/app/src/main/AndroidManifest.xml` (package attribute)
- `ios/Runner.xcodeproj/project.pbxproj` (PRODUCT_BUNDLE_IDENTIFIER)

---

### `doctor` — Check project health

```bash
codeable_cli doctor
```

Runs health checks on your Codeable project:
- **Cubit registration** — verifies all cubits in `features/` are registered in `app_page.dart`
- **Route wiring** — verifies all screens have routes in `go_router/`
- **Import consistency** — checks all imports in `go_router/exports.dart` resolve to existing files
- **Localization consistency** — validates all ARB files have the same set of keys

---

### `remove-feature` — Remove a feature

```bash
codeable_cli remove-feature --name profile [--role customer]
```

| Option | Description |
|--------|-------------|
| `-n, --name` | Feature name to remove (snake_case) |
| `-r, --role` | Optional role prefix (e.g., customer, admin) |

Safely removes a feature and all its wiring:
- Removes cubit from `app_page.dart`'s MultiBlocProvider
- Removes route from `go_router/router.dart`, `routes.dart`, `exports.dart`
- Deletes the feature directory
- Asks for confirmation before any destructive action

---

### `add-locale` — Add a new language

```bash
codeable_cli add-locale --locale fr
```

| Option | Description |
|--------|-------------|
| `-l, --locale` | Locale code (e.g., `fr`, `de`, `ar`, `pt_BR`) |

Adds a new locale to your project:
- Creates `lib/l10n/arb/app_<locale>.arb` with TODO placeholders from the English reference
- Preserves all `@key` metadata entries
- Runs `flutter gen-l10n` to regenerate localization classes

---

### `sample` — Add sample features

```bash
codeable_cli sample
```

Adds pre-built sample features showcasing the architecture patterns and UI components.

---

### `update` — Update CLI

```bash
codeable_cli update
```

Updates Codeable CLI to the latest version from pub.dev.

---

## Generated Architecture

### Clean Architecture

Every feature follows a strict three-layer structure:

```
UI (Screen/Widget)
    ↓ triggers
Cubit (State Management)
    ↓ calls
Repository Interface (Domain)
    ↓ implemented by
Repository Implementation (Data)
    ↓ uses
ApiService (Dio) + AppPreferences (Cache)
```

### State Management

Uses **Cubit** (not full BLoC with events) for simplicity. States use a `DataState<T>` wrapper:

```dart
// cubit.dart
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileState());

  final ProfileRepository _repository;

  Future<void> getProfile() async {
    emit(state.copyWith(profileState: DataState.loading));
    final response = await _repository.getProfile();
    if (response.isSuccess) {
      emit(state.copyWith(profileState: DataState.loaded, profile: response.data));
    } else {
      emit(state.copyWith(profileState: DataState.failure));
    }
  }
}
```

### Styling System

Text styles via context extension with modifier chains:

```dart
Text('Title', style: context.h1)                    // Header 32px bold
Text('Body', style: context.b1)                     // Body 14px medium
Text('Label', style: context.l2.secondary)           // Label 12px, white
Text('Caption', style: context.b3.tertiary)          // Body 12px, gray
```

Colors via `AppColors` constants:

```dart
AppColors.blackPrimary    // Primary text/foreground
AppColors.white           // White
AppColors.textSecondary   // Secondary text (gray)
AppColors.backgroundTertiary  // Light background
AppColors.error           // Error red
AppColors.success         // Success green
```

### API Layer

Pre-configured Dio client with:
- **Auth interceptor** — automatically attaches bearer token from local storage
- **Log interceptor** — request/response logging for development
- **Chucker interceptor** — in-app network inspector (development only)
- **60s timeout** with centralized error handling via `AppApiException`

### Dependency Injection

GetIt-based via `Injector` wrapper:

```dart
// Register in app_modules.dart
Injector.resolve<ApiService>();

// Resolve anywhere
final apiService = Injector.resolve<ApiService>();
```

---

## Included UI Components

The generated project includes **30+ production-ready widgets** in `lib/utils/widgets/core_widgets/`:

| Widget | Description |
|--------|-------------|
| `CustomAppBar` | App bar with back button, title, actions |
| `CustomButton` | Primary filled button with loading state |
| `CustomOutlineButton` | Outlined variant |
| `CustomTextButton` | Text-only button |
| `CustomIconButton` | Icon button with optional badge |
| `CustomTextField` | Text field with validation, prefix/suffix, formatters |
| `CustomSearchField` | Search input with debounce |
| `CustomDropdown` | Dropdown selector with cubit |
| `SearchableDropdown` | Dropdown with search/filter |
| `CustomSlidingTab` | Animated sliding tab bar |
| `CustomSectionTitle` | Section header with optional "See All" |
| `PaginatedListView` | List with built-in pagination |
| `CustomConfirmationDialog` | Confirmation dialog |
| `CustomBottomSheet` | Bottom sheet wrapper |
| `CustomShimmerWidget` | Shimmer loading placeholder |
| `CustomLoadingWidget` | Loading indicator |
| `CustomEmptyStateWidget` | Empty state with icon and message |
| `CustomRetryWidget` | Error state with retry button |
| `CustomStarRatingWidget` | Star rating display/input |
| `CustomSocialAuthButton` | Google/Apple sign-in buttons |
| `CachedNetworkImageWidget` | Cached network image with placeholder |
| `CustomDatePicker` | Date picker |
| `CustomTimePicker` | Time picker |
| `CustomCheckbox` | Checkbox with label |
| `CustomSwitch` | Toggle switch |
| `CustomSlider` | Range slider |
| `CustomChips` | Chip selection widget |
| `CustomProgressDashes` | Step progress indicator |
| `CustomRichText` | Rich text with tappable spans |
| `CustomBulletPointItem` | Bullet point list item |
| `StackedImagesWidget` | Overlapping avatar stack |
| `BlurOverlay` | Blurred background overlay |
| `ImagePickerWidget` | Camera/gallery image picker |
| `ReusableCalendarWidget` | Calendar date selector |

All widgets follow the `Custom<WidgetName>` naming convention and use the project's `AppColors` and text style system.

---

## Multi-Flavor Builds

Three flavors are configured out of the box with separate entry points:

| Flavor | Entry Point | Bundle ID Suffix | Display Name | App Icon |
|--------|-------------|-----------------|--------------|----------|
| `production` | `lib/main_production.dart` | _(none)_ | `MyApp` | `AppIcon` |
| `staging` | `lib/main_staging.dart` | `.stg` | `MyApp [STG]` | `AppIcon-stg` |
| `development` | `lib/main_development.dart` | `.dev` | `MyApp [DEV]` | `AppIcon-dev` |

```bash
flutter run --flavor development -t lib/main_development.dart
flutter run --flavor production -t lib/main_production.dart
```

### What's configured per flavor

**Android:**
- `productFlavors` in `build.gradle.kts` (development, staging, production)
- Per-flavor launcher icons in `android/app/src/{development,staging}/res/mipmap-*`
- Production icons in `android/app/src/main/res/mipmap-*`

**iOS:**
- Xcode schemes for each flavor (`development.xcscheme`, `staging.xcscheme`, `production.xcscheme`)
- 27 build configurations (3 build types × 3 flavors × 3 targets) in `project.pbxproj`
- Per-flavor `PRODUCT_BUNDLE_IDENTIFIER` (e.g., `com.example.app`, `com.example.app.stg`, `com.example.app.dev`)
- Per-flavor `FLAVOR_APP_NAME` for display name (resolved via `$(FLAVOR_APP_NAME)` in Info.plist)
- Per-flavor app icon sets in `ios/Runner/Assets.xcassets/` (`AppIcon`, `AppIcon-stg`, `AppIcon-dev`)

### Customizing per-flavor icons

All three icon sets start with the same default icons. To differentiate:

1. Replace icons in `ios/Runner/Assets.xcassets/AppIcon-dev.appiconset/` (development)
2. Replace icons in `ios/Runner/Assets.xcassets/AppIcon-stg.appiconset/` (staging)
3. Replace icons in `android/app/src/development/res/mipmap-*/` (Android dev)
4. Replace icons in `android/app/src/staging/res/mipmap-*/` (Android staging)

---

## Platform Configuration

### Android (pre-configured)
- `build.gradle.kts` with flavor dimensions, signing config, ProGuard, desugaring
- Per-flavor source sets with launcher icons (`src/development/res/`, `src/staging/res/`)
- Auto-generated keystore at `android/app/<project_name>-keystore.jks`
- Signing credentials in `android/key.properties`
- Internet, camera, location, notification permissions in AndroidManifest.xml

### iOS (pre-configured)
- Xcode schemes for each flavor (development, staging, production)
- 27 build configurations with per-flavor bundle IDs, display names, and app icons
- Per-flavor app icon sets in `Assets.xcassets` (AppIcon, AppIcon-dev, AppIcon-stg)
- Podfile with iOS 15.6 minimum, permission handler pods
- Info.plist with camera, photo library, location usage descriptions
- Entitlements for push notifications and Sign in with Apple
- Google Service copy script for per-flavor Firebase config

### Firebase
- Directory structure at `firebase/{development,staging,production}/`
- Drop in your `google-services.json` and `GoogleService-Info.plist` per flavor
- Build scripts auto-copy the correct config for the active flavor

---

## AI-Assisted Development

Generated projects include configuration files for AI coding assistants:

- **CLAUDE.md** — Project structure, patterns, and conventions for [Claude Code](https://claude.ai/claude-code)
- **.cursorrules** — Architecture rules and coding guidelines for [Cursor](https://cursor.com)
- **`.claude/settings.json`** — Auto-installs the [Codeable Flutter CLI Claude Plugin](https://github.com/gocodeable/codeable-flutter-cli-claude-plugin)

### Codeable Flutter CLI Claude Plugin (auto-installed)

The plugin is automatically configured in every generated project. When you open the project with Claude Code, you get:

| Component | Count | Highlights |
|-----------|-------|------------|
| **Skills** | 13 | Architecture, BLoC, Dio, GoRouter, Hive, Firebase, testing, security patterns |
| **Commands** | 38 | `/feature`, `/add-api`, `/localize`, `/add-auth-flow`, `/add-pagination`, `/generate-tests`, `/add-firebase-config`, and more |
| **Agents** | 9 | Code reviewer, test writer, security auditor, performance analyzer, API migrator |
| **Hooks** | 2 | Auto-lint on edit, analysis summary on stop |

No manual plugin installation needed — just open the project with Claude Code and start using commands.

For existing projects, run inside Claude Code:
```
/plugin marketplace add https://github.com/gocodeable/codeable-flutter-cli-claude-plugin.git
/plugin install codeable-flutter-cli@codeable-plugins
```

---

## FAQ

<details>
<summary><b>Do I need Flutter installed before using Codeable CLI?</b></summary>

Yes. Codeable CLI runs `flutter create` under the hood and then overlays the architecture on top. You need both Dart SDK (>= 3.0) and Flutter SDK (>= 3.0) installed.
</details>

<details>
<summary><b>Can I use this with an existing Flutter project?</b></summary>

The `create` command is designed for new projects. However, the `feature` command works inside any Codeable-structured project. If your existing project follows a similar architecture, you can use the `feature` command to generate new modules.
</details>

<details>
<summary><b>How do I add Firebase to a generated project?</b></summary>

The directory structure is already in place at `firebase/{development,staging,production}/`. Simply drop your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) into the appropriate flavor directory.
</details>

<details>
<summary><b>Can I customize the generated code after scaffolding?</b></summary>

Absolutely. The generated code is plain Dart/Flutter — no code generation or build_runner dependencies for the architecture itself. Modify anything you need.
</details>

<details>
<summary><b>Does the feature command require manual wiring?</b></summary>

No. As of v1.0.1, the `feature` command auto-wires everything: it registers the cubit in `app_page.dart`, adds routes to `go_router`, and creates route constants. You just need to start building your UI.
</details>

---

## Contributing

Contributions, issues, and feature requests are welcome!

```bash
# Fork the repo, then:
git clone https://github.com/<your-username>/codeable_cli.git
cd codeable_cli
dart pub get

# Make your changes, then:
dart test
dart analyze

# Submit a pull request
```

See the [issues page](https://github.com/Arhamss/codeable-flutter-cli/issues) for open tasks.

---

## Contributors

<table>
<tr>
<td align="center">
<a href="https://github.com/Arhamss">
<img src="https://github.com/Arhamss.png" width="80" style="border-radius:50%;" alt="Syed Arham Imran"/>
<br />
<b>Syed Arham Imran</b>
</a>
<br />
<a href="https://www.linkedin.com/in/syed-arham">LinkedIn</a>
</td>
<td align="center">
<a href="https://github.com/Abdullah-Zeb-0301">
<img src="https://github.com/Abdullah-Zeb-0301.png" width="80" style="border-radius:50%;" alt="Abdullah Zeb"/>
<br />
<b>Abdullah Zeb</b>
</a>
<br />
<a href="https://linkedin.com/in/abdullah-zeb-65095b226/">LinkedIn</a>
</td>
<td align="center">
<a href="https://github.com/Manas1255">
<img src="https://github.com/Manas1255.png" width="80" style="border-radius:50%;" alt="Muhammad Anas Akhtar"/>
<br />
<b>Muhammad Anas Akhtar</b>
</a>
<br />
<a href="https://www.linkedin.com/feed/update/urn:li:activity:7426607827072413697/">LinkedIn</a>
</td>
</tr>
<tr>
<td align="center">
<a href="https://github.com/ShoaibIrfan">
<img src="https://github.com/ShoaibIrfan.png" width="80" style="border-radius:50%;" alt="Muhammad Shoaib Irfan"/>
<br />
<b>Muhammad Shoaib Irfan</b>
</a>
<br />
<a href="https://www.linkedin.com/in/shoaib-irfan-2ba9991b9/">LinkedIn</a>
</td>
<td align="center">
<a href="https://github.com/shahab699">
<img src="https://github.com/shahab699.png" width="80" style="border-radius:50%;" alt="Shahab Arif"/>
<br />
<b>Shahab Arif</b>
</a>
<br />
<a href="https://www.linkedin.com/in/shahab-arif-b272721b7/">LinkedIn</a>
</td>
</tr>
</table>

---

## License

MIT

<p align="center">
  <br />
  <a href="https://gocodeable.com">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="assets/codeable_wordmark_white.svg" />
      <source media="(prefers-color-scheme: light)" srcset="assets/codeable_wordmark.svg" />
      <img src="assets/codeable_wordmark.svg" alt="Codeable" width="140" />
    </picture>
  </a>
  <br />
  <sub>Built with 💙 by <a href="https://gocodeable.com">Codeable</a></sub>
</p>
