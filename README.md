<div align="center">

# Codeable CLI

**A production-ready Flutter project scaffolding tool.**

Instantly generate Flutter projects with Clean Architecture, BLoC/Cubit state management, Dio networking, Hive storage, GoRouter navigation, multi-flavor builds, Firebase integration, and 40+ reusable UI components — all wired together and ready to go.

[![Pub Version](https://img.shields.io/pub/v/codeable_cli.svg)](https://pub.dev/packages/codeable_cli)
[![Style: Very Good Analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

</div>

---

## Why Codeable CLI?

Starting a new Flutter project means hours of boilerplate — setting up architecture, configuring flavors, wiring DI, adding interceptors, building reusable widgets, and configuring platform files. **Codeable CLI does all of that in seconds.**

You get a project that's structured exactly like a production app from day one:

- Clean Architecture with feature-first organization
- Cubit-based state management with proper data flow
- Pre-configured API layer with auth interceptors and error handling
- 40+ production-ready, reusable UI components
- Multi-flavor builds (development, staging, production) out of the box
- Android keystore generation and signing configuration
- iOS permissions, Podfile, and entitlements pre-configured
- Firebase directory structure for multi-environment setup
- Localization support with ARB files
- AI assistant config files (CLAUDE.md, .cursorrules) for better AI-assisted development

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
dart pub global activate codeable_cli 1.0.0
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
│   │   ├── guards/                 # Auth & guest guards
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

Each generated file comes with boilerplate — the repository interface, implementation wired to ApiService, cubit with DataState, and a basic screen scaffold.

After generating, you just need to:
1. Register the cubit in `app_page.dart`
2. Add the route in `go_router/router.dart`
3. Register the repository in `app_modules.dart`

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
ApiService (Dio)
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

## Requirements

| Tool | Version |
|------|---------|
| Dart SDK | >= 3.0 |
| Flutter SDK | >= 3.0 |

---

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built by [Codeable](https://github.com/ArsalImam)**

</div>
