const claudeMdTemplate = r'''
# Project: {{ProjectName}}

## Overview
{{description}}

This is a Flutter application built with Clean Architecture and BLoC/Cubit state management.

## Architecture

### Directory Structure
```
lib/
├── app/view/                    # App entry point (MaterialApp, theme, routing)
├── config/                      # Flavor config, API environment
├── constants/                   # AppColors, AppTextStyle, AssetPaths, Constants
├── core/
│   ├── api_service/             # Dio-based API service with interceptors
│   ├── app_preferences/         # Hive-based local storage (auth tokens, user data)
│   ├── di/modules/              # GetIt dependency injection setup
│   ├── endpoints/               # API endpoint definitions
│   ├── enums/                   # App-wide enums (DataState, ApiCallState)
│   ├── locale/cubit/            # Locale management cubit
│   ├── models/
│   │   ├── api_response/        # API response models
│   │   ├── auth/                # Auth-related models (Hive TypeAdapters)
│   │   └── common/              # Shared models
│   ├── permissions/             # Permission manager and messages
│   └── field_validators.dart    # Form field validators
├── features/                    # Feature modules (see Feature Structure below)
├── go_router/                   # GoRouter configuration and route definitions
├── l10n/                        # Localization (ARB files, generated code)
├── utils/
│   ├── extensions/              # Dart extensions
│   ├── helpers/                 # Helper utilities (toast, layout, decorations, etc.)
│   ├── response_data_model/     # Response parsing utilities
│   └── widgets/core_widgets/    # Reusable UI components
└── exports.dart                 # Main barrel file
```

### Feature Structure (Clean Architecture)
Each feature follows this pattern:
```
features/<feature_name>/
├── data/
│   ├── models/          # Data models, DTOs
│   └── repository/      # Repository implementation (calls ApiService)
├── domain/
│   └── repository/      # Abstract repository interface
└── presentation/
    ├── cubit/           # Cubit + State classes
    ├── views/           # Screen widgets
    └── widgets/         # Feature-specific widgets
```

## Key Patterns

### State Management
- Uses **flutter_bloc** with **Cubit** pattern (not full Bloc with events)
- States use **DataState<T>** enum: `initial`, `loading`, `loaded`, `failure`
- Cubits are registered in `lib/app/view/app_page.dart` via MultiBlocProvider

### Dependency Injection
- Uses **GetIt** via `Injector` wrapper class
- Modules registered in `lib/core/di/modules/app_modules.dart`
- Resolve dependencies: `Injector.resolve<Type>()`

### API Layer
- **Dio**-based `ApiService` singleton with centralized error handling
- Auth interceptor adds bearer token from AppPreferences
- Endpoints defined in `lib/core/endpoints/endpoints.dart`
- Response models: `ApiResponseModel<T>`, `RepositoryResponse<T>`

### Navigation
- Uses **GoRouter** with named routes
- Routes defined in `lib/go_router/routes.dart` (AppRoutes + AppRouteNames)
- Router config in `lib/go_router/router.dart`

### Styling
- Colors: `AppColors.blackPrimary`, `AppColors.white`, `AppColors.textSecondary`, etc.
- Text styles via context extension: `context.h1`, `context.t1`, `context.b1`, `context.l1`
- Text style modifiers: `.secondary` (white), `.tertiary` (gray)
- Fonts: BBBPoppins (headings/titles via `AppFonts.heading`), SFProRounded (body/labels via `AppFonts.body`)
- Assets: `AssetPaths.arrowLeftIcon`, `AssetPaths.searchIcon`, etc.

### Storage
- **Hive** for local persistence via `AppPreferences`
- Auth models use Hive TypeAdapters (TypeId 1, 2, 3)

### Localization
- ARB-based with `flutter_localizations`
- Access via `context.l10n.stringKey`
- Files in `lib/l10n/arb/`

### Form Validation
- `FieldValidators` class with static methods
- Common validators: `emailValidator`, `passwordValidator`, `phoneValidator`, `nameValidator`

## Core Widgets (lib/utils/widgets/core_widgets/)
Reusable components available through `exports.dart`:
- `CustomAppBar` - App bar with back button, title, actions
- `CustomButton` - Primary filled button
- `CustomOutlineButton` - Outlined button
- `CustomTextField` - Text form field with validation
- `CustomSearchField` - Search input field
- `CustomDropdown` - Dropdown selector
- `SearchableDropdown` - Searchable dropdown with filtering
- `CustomSlidingTab` / `SlidingTab` - Tab bar widgets
- `CustomSectionTitle` - Section header with optional "See All"
- `CustomConfirmationDialog` - Confirmation dialog
- `CustomBottomSheet` - Bottom sheet wrapper
- `PaginatedListView` / `PaginatedGridView` - Paginated scrollable lists

## Build Flavors
- **development** (`main_development.dart`) - DevicePreview enabled
- **production** (`main_production.dart`) - Production config

## Commands
```bash
# Run development
flutter run --target lib/main_development.dart

# Run production
flutter run --target lib/main_production.dart

# Generate localization
flutter gen-l10n

# Run analysis
flutter analyze
```
''';

const cursorRulesTemplate = r'''
# {{ProjectName}} - Cursor Rules

## Project Type
Flutter mobile application using Clean Architecture with BLoC/Cubit pattern.

## Tech Stack
- Flutter & Dart
- State Management: flutter_bloc (Cubit pattern)
- DI: GetIt (via Injector wrapper)
- Networking: Dio
- Local Storage: Hive
- Routing: GoRouter
- Styling: Google Fonts (Plus Jakarta Sans), custom AppColors, context-based text styles
- Localization: flutter_localizations with ARB files

## Architecture Rules

### Feature Modules
Each feature lives in `lib/features/<name>/` with:
- `data/models/` - Data models and DTOs
- `data/repository/` - Repository implementation (concrete, uses ApiService)
- `domain/repository/` - Abstract repository interface
- `presentation/cubit/` - Cubit (cubit.dart) and State (state.dart)
- `presentation/views/` - Screen widgets
- `presentation/widgets/` - Feature-specific widgets

### Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Screen files: `<feature>_screen.dart`
- Cubit files: `cubit.dart` and `state.dart` inside feature's `presentation/cubit/`
- Repository: `<feature>_repository.dart` (abstract), `<feature>_repository_impl.dart` (concrete)

### State Management
- Use Cubit (not full Bloc with events) for state management
- States use DataState<T> enum with: initial, loading, loaded, failure
- Register cubits in `lib/app/view/app_page.dart` via MultiBlocProvider
- Resolve repository dependencies via `Injector.resolve<Type>()`

### Styling
- Colors: Use `AppColors` constants (e.g., `AppColors.blackPrimary`, `AppColors.white`, `AppColors.textSecondary`)
- Text: Use context extension (e.g., `context.h1`, `context.t1`, `context.b1`, `context.l1`)
- Text modifiers: `.secondary` (white text), `.tertiary` (gray text)
- Fonts: BBBPoppins for headings/titles, SFProRounded for body/labels
- Assets: Reference via `AssetPaths` constants

### API Layer
- Use `ApiService` for all network calls (GET, POST, PUT, PATCH, DELETE)
- Wrap responses in `RepositoryResponse<T>`
- Define endpoints in `lib/core/endpoints/endpoints.dart`
- Handle errors via `AppApiException`

### Navigation
- Define routes in `lib/go_router/routes.dart`
- Use named routes: `context.goNamed(AppRouteNames.home)`
- Add route config in `lib/go_router/router.dart`

### Imports
- Use the barrel file `exports.dart` for common imports (Material, Bloc, GoRouter, AppColors, etc.)
- Feature-specific imports should be direct

### Form Validation
- Use `FieldValidators` static methods for form validation
- Available: emailValidator, passwordValidator, phoneValidator, nameValidator, textValidator

### Core Widgets
Prefer using existing core widgets from `lib/utils/widgets/core_widgets/`:
- CustomAppBar, CustomButton, CustomOutlineButton, CustomTextField
- CustomSearchField, CustomDropdown, SearchableDropdown
- CustomSectionTitle, CustomConfirmationDialog, CustomBottomSheet
- PaginatedListView, PaginatedGridView

### DI Registration
- Register new singletons/factories in `lib/core/di/modules/app_modules.dart`
- Use `Injector.resolve<Type>()` to resolve

## Code Style
- Follow `very_good_analysis` lint rules
- Prefer const constructors
- Use trailing commas for better formatting
- Keep widgets small and composable
- Extract reusable widgets to the feature's widgets folder

## File Structure for New Features
When creating a new feature, create all required directories and files:
1. Abstract repository in domain/repository/
2. Repository implementation in data/repository/
3. Models in data/models/
4. Cubit and State in presentation/cubit/
5. Screen in presentation/views/
6. Register cubit in app_page.dart
7. Add route in go_router/router.dart and routes.dart
''';
