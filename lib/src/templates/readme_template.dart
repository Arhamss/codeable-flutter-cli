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

```bash
# Clone the repo
git clone <repository-url>
cd {{project_name}}

# Install dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# iOS pods (first time)
cd ios && pod install && cd ..
```

---

## Project Structure

```
{{project_name}}/
├── android/                     ← Android platform project
├── ios/                         ← iOS platform project
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
│   │   ├── api_environment.dart ← Per-flavor API base URLs
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
│   │   ├── l10n.dart            ← context.l10n extension
│   │   └── arb/                 ← ARB translation files
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
- **API base URL** via `ApiEnvironment`
- **Firebase project** via flavor-specific config files
- **App name suffix** for easy identification on devices

### Environment Configuration

Update your API URLs in [`lib/config/api_environment.dart`](lib/config/api_environment.dart):

```dart
enum ApiEnvironment {
  development(baseUrl: 'https://dev-api.example.com'),
  staging(baseUrl: 'https://staging-api.example.com'),
  production(baseUrl: 'https://api.example.com');
}
```

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

The release build uses a keystore at `android/app/upload-keystore.jks` configured in `android/key.properties`.

### iOS

```bash
flutter build ios --flavor production -t lib/main_production.dart
```

Then archive and distribute via Xcode or CI/CD.

---

## Feature Generation

Use the Codeable CLI to scaffold new features with the correct architecture:

```bash
codeable_cli feature <feature_name>
```

For example:

```bash
codeable_cli feature profile
```

This generates:

```
lib/features/profile/
├── data/
│   ├── models/
│   └── repository/
│       └── profile_repository_impl.dart
├── domain/
│   └── repository/
│       └── profile_repository.dart
└── presentation/
    ├── cubit/
    │   ├── cubit.dart
    │   └── state.dart
    ├── views/
    │   └── profile_screen.dart
    └── widgets/
```

After generating, remember to:
1. Register the Cubit in [`lib/app/view/app_page.dart`](lib/app/view/app_page.dart)
2. Add routes in [`lib/go_router/router.dart`](lib/go_router/router.dart) and [`lib/go_router/routes.dart`](lib/go_router/routes.dart)
3. Register the repository in [`lib/core/di/modules/app_modules.dart`](lib/core/di/modules/app_modules.dart)

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

4. Use in code:
   ```dart
   Text(context.l10n.greeting('World'))
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
| Debugging          | `chucker_flutter`             | Network inspector                |

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
