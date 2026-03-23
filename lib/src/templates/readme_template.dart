const readmeTemplate = r'''
<div align="center">

# {{ProjectName}}

**{{description}}**

Built with [Codeable CLI](https://github.com/Arhamss/codeable-flutter-cli) — a production-ready Flutter architecture scaffold.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Style: Very Good Analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

</div>

---

## Table of Contents

- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Flavors & Environments](#flavors--environments)
- [Firebase Setup](#firebase-setup)
- [Running the App](#running-the-app)
- [Building for Release](#building-for-release)
- [Feature Generation](#feature-generation)
- [Localization](#localization)
- [Key Dependencies](#key-dependencies)
- [Code Conventions](#code-conventions)

---

## Architecture

This project follows **Clean Architecture** with the **BLoC/Cubit** pattern for state management:

```
Feature/
├── data/           ← Implementations, API calls, models
│   ├── models/     ← Data models, JSON serialization
│   └── repository/ ← Repository implementations
├── domain/         ← Business logic contracts
│   └── repository/ ← Abstract repository interfaces
└── presentation/   ← UI layer
    ├── cubit/      ← State management (Cubit + State)
    ├── views/      ← Screens / pages
    └── widgets/    ← Feature-specific widgets
```

**Data flows one way:** UI → Cubit → Repository (abstract) → Repository Impl → API Service

---

## Getting Started

### Prerequisites

| Tool             | Version  |
| ---------------- | -------- |
| Flutter SDK      | >= 3.0   |
| Dart SDK         | >= 3.0   |
| Xcode            | >= 15.0  |
| Android Studio   | >= 2024  |
| CocoaPods        | >= 1.15  |
| Java / JDK       | >= 17    |

### Initial Setup

Clone the repo:
```bash
git clone <repository-url>
cd {{project_name}}
```

Install dependencies:
```bash
flutter pub get
```

Generate localization files:
```bash
flutter gen-l10n
```

iOS pods (first time):
```bash
cd ios && pod install && cd ..
```

---

## Project Structure

```
{{project_name}}/
├── .run/                        ← Android Studio run configs (Dev/Staging/Prod)
├── android/                     ← Android platform project
├── ios/                         ← iOS platform project
├── env/                         ← Per-flavor .env files (gitignored)
│   ├── .env.development
│   ├── .env.staging
│   └── .env.production
├── firebase/                    ← Firebase config files per flavor
│   ├── development/             ← GoogleService-Info.plist & google-services.json
│   ├── staging/
│   └── production/
├── assets/
│   ├── images/                  ← Raster images (PNG, JPG)
│   ├── svgs/                    ← Vector graphics (SVG)
│   ├── animation/               ← Lottie animation files
│   └── fonts/                   ← Custom font files
├── lib/
│   ├── main_development.dart    ← Development entry point
│   ├── main_staging.dart        ← Staging entry point
│   ├── main_production.dart     ← Production entry point
│   ├── bootstrap.dart           ← App initialization & DI setup
│   ├── exports.dart             ← Global barrel exports
│   ├── app/
│   │   └── view/
│   │       ├── app_page.dart    ← Root widget with BlocProviders
│   │       ├── app_view.dart    ← MaterialApp.router setup
│   │       └── splash.dart      ← Splash / auth check screen
│   ├── config/
│   │   ├── flavor_config.dart   ← Flavor enum & singleton
│   │   ├── env/                 ← Envied-based environment config
│   │   │   ├── env_dev.dart     ← Development env variables
│   │   │   ├── env_stg.dart     ← Staging env variables
│   │   │   ├── env_prod.dart    ← Production env variables
│   │   │   └── app_env.dart     ← Flavor-based env resolver
│   │   └── remote_config.dart   ← Firebase Remote Config wrapper
│   ├── constants/
│   │   ├── app_colors.dart      ← Color palette
│   │   ├── app_text_style.dart  ← Typography (Google Fonts)
│   │   ├── asset_paths.dart     ← Asset path constants
│   │   └── constants.dart       ← App-wide constants
│   ├── core/
│   │   ├── api_service/         ← Dio HTTP client, interceptors
│   │   ├── app_preferences/     ← Hive-based local storage
│   │   ├── di/                  ← GetIt dependency injection
│   │   ├── endpoints/           ← API endpoint definitions
│   │   ├── locale/              ← Locale cubit
│   │   ├── models/              ← Shared models (API response, auth)
│   │   ├── notifications/       ← Firebase & local notifications
│   │   └── permissions/         ← Permission handling
│   ├── features/
│   │   └── onboarding/          ← Sample feature (login, guest)
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   ├── go_router/
│   │   ├── router.dart          ← GoRouter configuration
│   │   ├── routes.dart          ← Route paths & names
│   │   └── exports.dart         ← Router barrel exports
│   ├── l10n/
│   │   ├── l10n.dart                  ← context.l10n extension
│   │   ├── localization_service.dart  ← static Localization.xxx accessor
│   │   └── arb/                       ← ARB translation files
│   └── utils/
│       ├── extensions/          ← Dart extensions
│       ├── helpers/             ← Utility helpers
│       ├── response_data_model/ ← Generic response wrappers
│       └── widgets/
│           └── core_widgets/    ← Reusable UI components
└── pubspec.yaml
```

---

## Flavors & Environments

The app supports **three build flavors**, each with its own entry point and configuration:

| Flavor        | Entry Point                | Use Case                   |
| ------------- | -------------------------- | -------------------------- |
| `development` | `lib/main_development.dart`| Day-to-day development     |
| `staging`     | `lib/main_staging.dart`    | QA / testing builds        |
| `production`  | `lib/main_production.dart` | App Store / Play Store     |

Each flavor configures:
- **API keys & URLs** via `envied`-based environment files
- **Firebase project** via flavor-specific config files
- **App name suffix** for easy identification on devices

### Environment Configuration

Environment variables are managed with the [`envied`](https://pub.dev/packages/envied) package for compile-time injection with obfuscation support.

**1. `.env` files** — located in a gitignored `env/` folder at the project root:

```
env/
├── .env.development
├── .env.staging
└── .env.production
```

Each file contains key-value pairs:
```
BASE_URL=https://api.example.com/
API_VERSION=v1
MAPBOX_API_KEY=pk_test_xxx
STRIPE_PUBLISHABLE_KEY=pk_test_xxx
GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com
SOCKET_URL=wss://api.example.com/ws
```

**2. Env Dart files** — in `lib/config/env/`:
- `env_dev.dart`, `env_stg.dart`, `env_prod.dart` — `@Envied` annotated classes
- `app_env.dart` — resolver that picks the right env class based on the current flavor

**3. Adding a new key:**
1. Add the variable to all three `.env.*` files
2. Add an `@EnviedField` entry in each `env_*.dart` file (use `obfuscate: true` for secrets)
3. Add a getter in `app_env.dart` that switches on flavor
4. Run `dart run build_runner build --delete-conflicting-outputs`

**4. Release builds** should use `--obfuscate --split-debug-info=build/symbols` for additional protection.

---

## Firebase Setup

Firebase configuration files are loaded **per flavor** from the `firebase/` directory at the project root:

```
firebase/
├── development/
│   ├── GoogleService-Info.plist    ← iOS
│   └── google-services.json       ← Android
├── staging/
│   ├── GoogleService-Info.plist
│   └── google-services.json
└── production/
    ├── GoogleService-Info.plist
    └── google-services.json
```

### Setup Steps

1. Create a Firebase project for each environment (or use one project with multiple apps)
2. Download the config files from the Firebase Console
3. Place them in the corresponding `firebase/<flavor>/` directory
4. **That's it** — build scripts automatically copy the correct file per flavor

> **Note:** The project compiles and runs without Firebase config files. You'll see a build warning until you add them.

### How It Works

- **iOS:** An Xcode Run Script build phase copies the correct `GoogleService-Info.plist` into `ios/Runner/` based on the active build configuration
- **Android:** Gradle copy tasks move `google-services.json` from `firebase/<flavor>/` to `app/src/<flavor>/` before the Google Services plugin processes it

---

## Running the App

```bash
# Development (default for daily work)
flutter run --flavor development -t lib/main_development.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor production -t lib/main_production.dart
```

### With Device Preview (development only)

Development builds include [Device Preview](https://pub.dev/packages/device_preview) for testing across screen sizes. Toggle it in `main_development.dart`.

---

## Building for Release

### Android

```bash
# APK
flutter build apk --flavor production -t lib/main_production.dart

# App Bundle (recommended for Play Store)
flutter build appbundle --flavor production -t lib/main_production.dart
```

The release build uses a keystore at `android/app/{{project_name}}-keystore.jks` configured in `android/key.properties`.

### iOS

```bash
flutter build ios --flavor production -t lib/main_production.dart
```

Then archive and distribute via Xcode or CI/CD.

---

## Feature Generation

Use the Codeable CLI to scaffold new features with the correct architecture:

```bash
codeable_cli feature <feature_name> [--role <role>]
```

For example:

```bash
# Basic feature
codeable_cli feature profile

# Role-based feature
codeable_cli feature home --role customer
```

**Basic feature** generates:

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

**Role-based feature** (`--role customer`) generates:

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

With `--role`, all file names, class names, and routes are prefixed with the role (e.g., `CustomerHomeScreen`, route `/customer-home`).

**Everything is auto-wired** — cubit registered in `app_page.dart`, route added to `go_router`, route constants created. Navigate with:
```dart
context.goNamed(AppRouteNames.profileScreen);
// or for role-based:
context.goNamed(AppRouteNames.customerHomeScreen);
```

---

## Localization

This project uses Flutter's built-in localization with ARB files.

### Adding a New String

1. Add the key to [`lib/l10n/arb/app_en.arb`](lib/l10n/arb/app_en.arb):
   ```json
   {
     "greeting": "Hello, {name}!",
     "@greeting": {
       "placeholders": {
         "name": { "type": "String" }
       }
     }
   }
   ```

2. Add translations in other ARB files (e.g., `app_es.arb`)

3. Regenerate:
   ```bash
   flutter gen-l10n
   ```

4. Add a static getter to `lib/l10n/localization_service.dart`:
   ```dart
   static String greeting(String name) => _instance.greeting(name);
   ```

5. Use in code:
   ```dart
   // In widgets/screens (have BuildContext) — preferred
   Text(context.l10n.greeting('World'))

   // In non-widget code (validators, formatters, models)
   Localization.greeting('World')
   ```

### Supported Locales

| Language | File        |
| -------- | ----------- |
| English  | `app_en.arb`|
| Spanish  | `app_es.arb`|

Add more by creating new ARB files and updating `l10n.yaml`.

---

## Key Dependencies

| Category           | Package                       | Purpose                          |
| ------------------ | ----------------------------- | -------------------------------- |
| State Management   | `flutter_bloc`                | BLoC / Cubit pattern             |
| Networking         | `dio`                         | HTTP client with interceptors    |
| Routing            | `go_router`                   | Declarative navigation           |
| DI                 | `get_it`                      | Service locator                  |
| Local Storage      | `hive_ce_flutter`             | Key-value storage                |
| Firebase           | `firebase_core`, `firebase_auth` | Backend services              |
| Image Caching      | `cached_network_image`        | Efficient image loading          |
| Notifications      | `firebase_messaging`, `flutter_local_notifications` | Push & local |
| UI Utilities       | `shimmer`, `toastification`   | Loading states & toasts          |
| Debugging          | `chucker_flutter`             | Network inspector (dev only)     |

See [`pubspec.yaml`](pubspec.yaml) for the full dependency list.

---

## Code Conventions

- **Architecture:** Clean Architecture with feature-first folder organization
- **State Management:** One Cubit per feature; states use `DataState<T>` wrapper
- **Naming:** Files in `snake_case`, classes in `PascalCase`, variables in `camelCase`
- **Linting:** Enforced via [Very Good Analysis](https://pub.dev/packages/very_good_analysis)
- **Imports:** Use the barrel `exports.dart` for shared imports
- **API Calls:** Always go through `ApiService` → Repository pattern
- **Error Handling:** Use `ToastHelper` for user-facing errors, `AppLogger` for debug logging

---

## Other CLI Commands

```bash
# Rename the project (updates imports, pubspec, folder name)
codeable_cli rename --name <new_name>

# Change the app/bundle identifier
codeable_cli change-id --id <new_id>
```

---

<div align="center">

**Built with Codeable CLI**

</div>
''';
