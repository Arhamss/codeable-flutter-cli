<div align="center">

<a href="https://github.com/ArsalImam/codeable_cli">
  <img src="https://img.shields.io/badge/Codeable-CLI-blue?style=for-the-badge&logo=dart&logoColor=white" alt="Codeable CLI" />
</a>

# Codeable CLI

**A production-ready Flutter project scaffolding tool.**

Instantly generate Flutter projects with Clean Architecture, BLoC/Cubit state management, Dio networking, Hive storage, GoRouter navigation, multi-flavor builds, Firebase integration, and 40+ reusable UI components — all wired together and ready to go.

[![Pub Version](https://img.shields.io/pub/v/codeable_cli.svg?style=for-the-badge)](https://pub.dev/packages/codeable_cli)
[![Style: Very Good Analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg?style=for-the-badge)](https://pub.dev/packages/very_good_analysis)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

<a href="https://github.com/ArsalImam/codeable_cli">GitHub</a> &nbsp;&bull;&nbsp; <a href="https://pub.dev/packages/codeable_cli">pub.dev</a> &nbsp;&bull;&nbsp; <a href="https://github.com/ArsalImam/codeable_cli/issues">Issues</a>

</div>

---

## Table of Contents

- [Overview](#overview)
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

## Overview

Starting a new Flutter project means hours of boilerplate — setting up architecture, configuring flavors, wiring DI, adding interceptors, building reusable widgets, and configuring platform files. **Codeable CLI does all of that in seconds.**

| Metric | Detail |
|--------|--------|
| Architecture | Clean Architecture (feature-first) |
| State Management | BLoC/Cubit with DataState |
| Networking | Dio with auth, logging, Chucker interceptors |
| Storage | Hive-based local storage |
| Navigation | GoRouter with named routes |
| UI Components | 40+ production-ready widgets |
| Build Flavors | Development, Staging, Production |
| Platforms | Android & iOS pre-configured |
| Firebase | Multi-environment directory structure |
| Localization | ARB files with context.l10n |
| AI Config | CLAUDE.md + .cursorrules |

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
dart pub global activate codeable_cli 1.0.1
```

### Or run without activating

If you prefer not to globally activate (e.g., in CI), you can run commands directly:

```bash
dart pub global run codeable_cli:codeable_cli <command> <args>
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

```bash
# Create a new project
codeable_cli create --name my_app --org com.example.myapp

# Navigate into the project
cd my_app

# Run it
flutter run --flavor development -t lib/main_development.dart
```

That's it. Your project is ready with the full architecture, all dependencies installed, and the keystore generated.

### Generate a new feature

```bash
codeable_cli feature profile
```

This creates the full feature module **and** auto-wires everything:
- Cubit registered in `app_page.dart`'s MultiBlocProvider
- Route added to `go_router` with named route constants
- Navigate with `context.goNamed(AppRouteNames.profileScreen)`

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
| `-o, --org` | Organization identifier (e.g., `com.example.app`) | Prompted interactively |
| `-d, --description` | Project description | `A new Flutter project` |
| `--output` | Output directory | `.` (current directory) |

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
│   ├── l10n/                       # Localization (ARB files, context.l10n)
│   └── utils/
│       ├── extensions/             # Dart extensions
│       ├── helpers/                # Toast, layout, decorations, logger, etc.
│       ├── response_data_model/    # Response parsing utilities
│       └── widgets/core_widgets/   # 40+ reusable UI components
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
codeable_cli feature <feature_name>
```

**Example:**

```bash
codeable_cli feature profile
```

**Generates:**

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

Each generated file comes with boilerplate — the repository interface, implementation wired to `ApiService` and `AppPreferences` (cache), cubit with `DataState`, and a screen scaffold with `customAppBar` and `BlocBuilder`.

**Auto-wired out of the box:**
- Cubit registered in `app_page.dart`'s `MultiBlocProvider`
- Route added to `go_router/router.dart`
- Route constants added to `AppRoutes` and `AppRouteNames`
- Screen import added to `go_router/exports.dart`

---

### `rename` — Rename a project

```bash
codeable_cli rename --name <new_name>
```

Updates the package name in `pubspec.yaml`, renames all `package:old_name/` imports across the codebase, renames the project folder, and runs `flutter pub get`.

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

### `update` — Update the CLI

```bash
codeable_cli update
```

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
- **Chucker interceptor** — in-app network inspector (shake to view)
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

The generated project includes **40+ production-ready widgets** in `lib/utils/widgets/core_widgets/`:

| Widget | Description |
|--------|-------------|
| `CustomAppBar` | App bar with back button, title, actions |
| `CustomButton` | Primary filled button with loading state |
| `CustomOutlineButton` | Outlined variant |
| `CustomTextField` | Text field with validation, prefix/suffix, formatters |
| `CustomSearchField` | Search input with debounce |
| `CustomDropdown` | Dropdown selector |
| `SearchableDropdown` | Dropdown with search/filter |
| `CustomSlidingTab` | Animated sliding tab bar |
| `SectionTitle` | Section header with optional "See All" |
| `PaginatedListView` | List with built-in pagination |
| `PaginatedGridView` | Grid with built-in pagination |
| `ConfirmationDialog` | Confirmation dialog |
| `CustomBottomSheet` | Bottom sheet wrapper |
| `ShimmerLoadingWidget` | Shimmer loading placeholder |
| `EmptyStateWidget` | Empty state with icon and message |
| `RetryWidget` | Error state with retry button |
| `StarRatingWidget` | Star rating display/input |
| `SocialAuthButton` | Google/Apple sign-in buttons |
| `CachedNetworkImageWidget` | Cached network image with placeholder |
| `CustomDatePicker` | Date picker |
| `CustomTimePicker` | Time picker |
| `ImagePickerWidget` | Camera/gallery image picker |

...and more. All widgets use the project's `AppColors` and text style system.

---

## Multi-Flavor Builds

Three flavors are configured out of the box with separate entry points:

| Flavor | Entry Point | Use Case |
|--------|-------------|----------|
| `development` | `lib/main_development.dart` | Daily development (DevicePreview enabled) |
| `staging` | `lib/main_staging.dart` | QA and testing |
| `production` | `lib/main_production.dart` | App Store / Play Store |

```bash
flutter run --flavor development -t lib/main_development.dart
flutter run --flavor production -t lib/main_production.dart
```

---

## Platform Configuration

### Android (pre-configured)
- `build.gradle.kts` with flavor dimensions, signing config, ProGuard, desugaring
- Auto-generated keystore at `android/app/upload-keystore.jks`
- Signing credentials in `android/key.properties`
- Internet, camera, location, notification permissions in AndroidManifest.xml

### iOS (pre-configured)
- Podfile with iOS 15.6 minimum, permission handler pods
- Info.plist with camera, photo library, location usage descriptions
- Entitlements for push notifications and Sign in with Apple

### Firebase
- Directory structure at `firebase/{development,staging,production}/`
- Drop in your `google-services.json` and `GoogleService-Info.plist` per flavor
- Build scripts auto-copy the correct config for the active flavor

---

## AI-Assisted Development

Generated projects include configuration files for AI coding assistants:

- **CLAUDE.md** — Project structure, patterns, and conventions for [Claude Code](https://claude.ai/claude-code)
- **.cursorrules** — Architecture rules and coding guidelines for [Cursor](https://cursor.com)

These files give AI assistants full context about your project's architecture, so they generate code that follows your patterns.

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

See the [issues page](https://github.com/ArsalImam/codeable_cli/issues) for open tasks.

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

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built by [Codeable](https://github.com/ArsalImam)** &nbsp;&bull;&nbsp; [GitHub](https://github.com/ArsalImam/codeable_cli) &nbsp;&bull;&nbsp; [pub.dev](https://pub.dev/packages/codeable_cli)

</div>
