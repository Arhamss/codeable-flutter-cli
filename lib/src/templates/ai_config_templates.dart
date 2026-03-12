const claudeSettingsTemplate = r'''
{
  "extraKnownMarketplaces": {
    "codeable-plugins": {
      "source": {
        "source": "github",
        "repo": "gocodeable/codeable-flutter-cli-claude-plugin"
      }
    }
  },
  "enabledPlugins": {
    "codeable-flutter-cli@codeable-plugins": true
  }
}
''';

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
- **In widgets/screens (have BuildContext):** `context.l10n.keyName`
- **In non-widget code (validators, formatters, models, utilities):** `Localization.keyName`
- Import for context.l10n: `import 'package:{{project_name}}/l10n/l10n.dart';`
- Import for static access: `import 'package:{{project_name}}/l10n/localization_service.dart';`
- ARB files in `lib/l10n/arb/`
- Static `Localization` service auto-updated via `AppView` builder on every locale change
- Add new getters to `lib/l10n/localization_service.dart` when adding ARB keys

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
- Localization: flutter_localizations with ARB files + static `Localization` service

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

### Localization
- **Widgets/screens (have BuildContext):** use `context.l10n.keyName` (import `l10n/l10n.dart`)
- **Non-widget code (validators, formatters, models):** use `Localization.keyName` (import `l10n/localization_service.dart`)
- ARB files in `lib/l10n/arb/` (app_en.arb, app_es.arb)
- After adding new ARB keys, add matching static getters to `lib/l10n/localization_service.dart`
- Run `flutter gen-l10n` after modifying ARB files

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

const localizeCommandTemplate = r'''
---
name: localize
description: Localize all hardcoded UI strings in a Flutter feature directory. Scans recursively, adds ARB keys, updates the Localization service, replaces strings in code, and verifies.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, TodoWrite
argument-hint: "<feature-path> e.g. lib/features/customer/customer_home"
---

# Localize Feature

You are a localization agent. Your job is to find and replace ALL hardcoded user-facing strings in a Flutter feature with localized calls. You work recursively until zero hardcoded strings remain.

## Arguments

$ARGUMENTS: The feature directory path to localize (e.g., lib/features/customer/customer_home)

If no argument is provided, ask the user which feature to localize.

## Key Files

**English ARB**: lib/l10n/arb/app_en.arb
**Spanish ARB**: lib/l10n/arb/app_es.arb
**l10n extension**: lib/l10n/l10n.dart (provides context.l10n extension on BuildContext)
**Localization static service**: lib/l10n/localization_service.dart (used ONLY in files without BuildContext)
**Generated files**: lib/l10n/gen/ (auto-generated, never edit manually)

## Localization Pattern

**In widgets/screens (have BuildContext)**: Use `context.l10n.keyName` — this uses Flutter's InheritedWidget mechanism and automatically triggers rebuilds when locale changes.
**In utility files without BuildContext** (validators, formatters, state files): Use `Localization.keyName` as a fallback.
**Import for context.l10n**: `import 'package:{{project_name}}/l10n/l10n.dart';`
**Import for static fallback**: `import 'package:{{project_name}}/l10n/localization_service.dart';`

## Phase 1: Discovery

1. Use Glob to find every .dart file in the feature directory recursively.
2. Read each file and identify ALL hardcoded user-facing strings. These include:
   - Text('...') widget content
   - Button labels (text: '...')
   - AppBar titles
   - Hint text, label text, error messages in text fields
   - Snackbar/toast messages
   - Dialog titles and content
   - Tooltip messages
   - Strings in lists/maps that feed into UI widgets
   - RichText TextSpan(text: '...') content
   - Placeholder/empty state text
   - Tab labels
3. **SKIP** strings that should NOT be localized:
   - Route names/paths (AppRoutes.xxx, '/home')
   - Asset paths (AssetPaths.xxx, 'assets/...')
   - API keys, URLs, endpoints, header keys
   - Map keys used for data logic (e.g., answers['space'], key: 'budget')
   - Enum values or role identifiers used in logic comparisons (e.g., == 'Business')
   - Color hex codes, font family names, package names
   - Log messages, debug strings
   - Empty strings ''
   - Single character strings used for formatting (e.g., '/', '-')
4. Build a complete manifest: {file, line, original_string, proposed_key}.

## Phase 2: Key Naming

Generate localization keys following these conventions:
- **camelCase** always
- Prefix with semantic context: `questionSpaceTitle`, `optionBedroom`, `featureUploadCatalog`, `customerHomeTitle`
- Keep keys concise but descriptive
- **Reuse existing keys** if the exact same English string already exists in app_en.arb
- For parameterized strings (containing $variable or dynamic values), use ICU message format:
  ```json
  "priceLabel": "Just {price}",
  "@priceLabel": { "placeholders": { "price": { "type": "String" } } }
  ```
- If the same string appears in multiple files, use ONE key for all occurrences

## Phase 3: Update ARB Files

1. Read existing app_en.arb and app_es.arb.
2. Add all new keys to BOTH files.
3. For app_es.arb, provide accurate Spanish translations.
4. For parameterized messages, include @key metadata with placeholder definitions in both files.
5. Do NOT remove or modify any existing keys.
6. Maintain the existing grouping style (blank line separators between sections).
7. Ensure valid JSON — no trailing commas, proper escaping.

## Phase 4: Update Localization Service

1. Read lib/l10n/localization_service.dart.
2. For each new key, add a static getter:
   ```dart
   static String get keyName => _instance.keyName;
   ```
3. For parameterized messages, add a static method:
   ```dart
   static String priceLabel(String price) => _instance.priceLabel(price);
   ```
4. Group new getters under a comment section named after the feature.
5. Do NOT remove existing getters.

## Phase 5: Update Code Files

For each file with hardcoded strings:

### Widget/Screen files (have BuildContext):
1. Add `import 'package:{{project_name}}/l10n/l10n.dart';` if not present.
2. Replace every identified hardcoded string with `context.l10n.keyName`.
3. If context is not directly in scope (e.g., in a class-level getter/list), convert it to a method that takes `BuildContext context`.
4. **Handle const removal**: If a string was inside a const context, remove the const qualifier since `context.l10n.xxx` is not compile-time constant.

### Utility files (no BuildContext — validators, formatters, state data):
1. Add `import 'package:{{project_name}}/l10n/localization_service.dart';` if not present.
2. Replace hardcoded strings with `Localization.keyName`.

### General rules:
1. Preserve ALL other code exactly as-is: formatting, logic, structure, comments.
2. Do NOT add docstrings, comments, type annotations, or any other changes beyond localization.

## Phase 6: Regenerate & Verify

1. Run `flutter gen-l10n` to regenerate localization classes from ARB files.
2. Run `flutter analyze --no-pub` to check for errors.
3. If errors exist, fix them:
   - **Missing getter in generated code**: Check ARB key spelling matches exactly.
   - **Type mismatch on parameterized message**: Check ICU message format and placeholder types.
   - **Const errors**: Ensure const was removed where `context.l10n.xxx` is now used.
   - **Import errors**: Ensure l10n.dart is imported for widget files.
4. Re-run `flutter analyze --no-pub` after each fix.
5. Repeat until 0 errors and 0 warnings (info-level lint issues are acceptable).

## Phase 7: Recursive Completion Check

1. Re-scan ALL .dart files in the feature directory for any remaining hardcoded user-facing strings.
2. If ANY are found, loop back to Phase 2 and process them.
3. Only declare completion when every UI-visible string uses `context.l10n.xxx` (or `Localization.xxx` in non-widget files).

## Rules

- **ALWAYS use `context.l10n.xxx`** in widgets/screens. This enables automatic rebuilds on locale change.
- **ONLY use `Localization.xxx`** in utility files without BuildContext (validators, formatters, state data).
- One widget class per file.
- Do NOT refactor, reorganize, or "improve" any code beyond localization.
- Do NOT add error handling, comments, or docstrings to code you didn't change.
- If a string appears in multiple files, use the same key everywhere.
- Track progress with TodoWrite — one todo per file being localized.
- Use parallel tool calls where possible (reading multiple files, writing independent files).
''';

const fixRtlCommandTemplate = r'''
---
name: fix-rtl
description: Migrate EdgeInsets to EdgeInsetsDirectional for proper RTL/LTR support. Scans a directory, replaces left/right with start/end, and verifies.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
argument-hint: "<path> e.g. lib/features/profile or lib/utils/widgets"
---

# Fix RTL — EdgeInsets to EdgeInsetsDirectional Migration

You are an RTL-readiness agent. Your job is to find and replace all directional `EdgeInsets` usages with `EdgeInsetsDirectional` equivalents in the given directory.

## Arguments

$ARGUMENTS: The directory path to scan (e.g., lib/features/profile, lib/utils/widgets, or lib/ for the whole project)

If no argument is provided, default to `lib/`.

## What to Replace

### Must replace (directional — breaks RTL):
- `EdgeInsets.only(left: x)` -> `EdgeInsetsDirectional.only(start: x)`
- `EdgeInsets.only(right: x)` -> `EdgeInsetsDirectional.only(end: x)`
- `EdgeInsets.only(left: x, right: y, ...)` -> `EdgeInsetsDirectional.only(start: x, end: y, ...)`
- `EdgeInsets.fromLTRB(l, t, r, b)` -> `EdgeInsetsDirectional.fromSTEB(l, t, r, b)`
- `Alignment.centerLeft` -> `AlignmentDirectional.centerStart`
- `Alignment.centerRight` -> `AlignmentDirectional.centerEnd`
- `Alignment.topLeft` -> `AlignmentDirectional.topStart`
- `Alignment.topRight` -> `AlignmentDirectional.topEnd`
- `Alignment.bottomLeft` -> `AlignmentDirectional.bottomStart`
- `Alignment.bottomRight` -> `AlignmentDirectional.bottomEnd`
- `TextAlign.left` -> `TextAlign.start`
- `TextAlign.right` -> `TextAlign.end`

### Do NOT replace (already direction-agnostic):
- `EdgeInsets.all(x)` — same in both directions
- `EdgeInsets.symmetric(horizontal: x, vertical: y)` — same in both directions
- `EdgeInsets.zero` — zero is directionless
- `EdgeInsets.only(top: x)` or `EdgeInsets.only(bottom: x)` — vertical only, no directional concern
- `Alignment.center`, `Alignment.topCenter`, `Alignment.bottomCenter`

## Process

1. Use Grep to find all `EdgeInsets.only(` and `EdgeInsets.fromLTRB(` containing `left` or `right` parameters.
2. Also search for `Alignment.centerLeft`, `Alignment.centerRight`, `Alignment.topLeft`, etc.
3. Also search for `TextAlign.left` and `TextAlign.right`.
4. For each match, read the surrounding context to understand the full expression.
5. Replace with the directional equivalent.
6. Preserve `const` qualifiers — if `const EdgeInsets.only(...)` becomes `const EdgeInsetsDirectional.only(...)`.
7. Run `flutter analyze --no-pub` to verify no errors were introduced.
8. Fix any errors and re-verify.

## Rules

- Do NOT change `EdgeInsets.all`, `EdgeInsets.symmetric`, or `EdgeInsets.zero`.
- Do NOT change `EdgeInsets.only` that uses only `top`/`bottom` parameters.
- Preserve all other code exactly as-is.
- Track progress with TodoWrite — one todo per file being updated.
''';

const addApiCommandTemplate = r'''
---
name: add-api
description: Wire up a new API endpoint end-to-end in an existing feature — adds the endpoint constant, repository method, cubit action, and connects to the screen.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
argument-hint: "<feature-path> <method> <endpoint> e.g. lib/features/profile GET /api/v1/profile"
---

# Add API Endpoint

You are an API wiring agent. Your job is to add a new API endpoint to an existing feature, wiring it through all Clean Architecture layers.

## Arguments

$ARGUMENTS: `<feature-path> <HTTP-method> <endpoint-path>`

Example: `lib/features/profile GET /api/v1/profile`

If arguments are missing, ask the user for: feature path, HTTP method (GET/POST/PUT/PATCH/DELETE), and endpoint path.

## Key Files

- **Endpoints**: `lib/core/endpoints/endpoints.dart`
- **ApiService**: `lib/core/api_service/api_service.dart`
- **Feature repository interface**: `<feature>/domain/repository/<feature>_repository.dart`
- **Feature repository impl**: `<feature>/data/repository/<feature>_repository_impl.dart`
- **Feature cubit**: `<feature>/presentation/cubit/cubit.dart`
- **Feature state**: `<feature>/presentation/cubit/state.dart`

## Process

### Step 1: Add Endpoint Constant
1. Read `lib/core/endpoints/endpoints.dart`.
2. Add a new static const for the endpoint path (e.g., `static const String getProfile = '/api/v1/profile';`).
3. Name it descriptively in camelCase.

### Step 2: Add Repository Method (Domain)
1. Read the abstract repository in `<feature>/domain/repository/`.
2. Add a new method signature that returns `Future<RepositoryResponse<T>>` where T is the expected response type.
3. If a response model is needed, create it in `<feature>/data/models/`.

### Step 3: Add Repository Implementation (Data)
1. Read the repository impl in `<feature>/data/repository/`.
2. Implement the new method using `_apiService` for the HTTP call.
3. Use `ApiResponseHandler.handleResponse()` for response parsing.
4. Handle both success and error cases.

### Step 4: Add Cubit Method
1. Read the cubit file.
2. Add a method that:
   - Emits loading state
   - Calls the repository method
   - Emits loaded state with data on success
   - Emits failure state on error

### Step 5: Update State (if needed)
1. If the cubit method needs new state fields, add them to the state class.
2. Update the `copyWith` method to include new fields.
3. Update `props` list for Equatable.

### Step 6: Verify
1. Run `flutter analyze --no-pub` to check for errors.
2. Fix any issues.

## Response Model Template

When creating a new model, follow this pattern:
```dart
class ProfileModel {
  const ProfileModel({
    this.id,
    this.name,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  final int? id;
  final String? name;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}
```

## Rules

- Follow the existing code patterns exactly.
- Use `RepositoryResponse<T>` for all repository returns.
- Use `DataState` enum (initial, loading, loaded, failure) for cubit states.
- Do NOT modify unrelated code.
- Preserve existing imports and formatting.
''';

const addCubitStateCommandTemplate = r'''
---
name: add-cubit-state
description: Add new state fields and corresponding cubit methods to an existing feature cubit. Updates state class, copyWith, props, and adds cubit actions.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
argument-hint: "<feature-path> e.g. lib/features/profile"
---

# Add Cubit State

You are a state management agent. Your job is to add new state fields and cubit methods to an existing feature's cubit/state files.

## Arguments

$ARGUMENTS: The feature directory path (e.g., lib/features/profile)

If no argument is provided, ask the user which feature to update.

After receiving the path, ask the user what state fields they want to add (name, type, initial value) and what cubit methods they need.

## Key Files

- **Cubit**: `<feature>/presentation/cubit/cubit.dart`
- **State**: `<feature>/presentation/cubit/state.dart`

## Process

### Step 1: Read Existing State
1. Read the state file to understand the current structure.
2. Identify the state class name, existing fields, copyWith method, and props list.

### Step 2: Add New State Fields
For each new field:
1. Add the field declaration with appropriate type (use `DataState` for async operations).
2. Add it to the constructor with a default value.
3. Add it to the `copyWith` method parameters and body.
4. Add it to the `props` list (for Equatable).

### Step 3: Add Cubit Methods
For each new action:
1. Add the method to the cubit class.
2. Follow the existing pattern:
   ```dart
   Future<void> fetchSomething() async {
     emit(state.copyWith(somethingState: DataState.loading));
     final response = await _repository.getSomething();
     if (response.isSuccess) {
       emit(state.copyWith(
         somethingState: DataState.loaded,
         something: response.data,
       ));
     } else {
       emit(state.copyWith(somethingState: DataState.failure));
     }
   }
   ```

### Step 4: Verify
1. Run `flutter analyze --no-pub` to check for errors.
2. Fix any issues.

## State Pattern Reference

```dart
class ProfileState extends Equatable {
  const ProfileState({
    this.profileState = DataState.initial,
    this.profile,
    // Add new fields here
  });

  final DataState profileState;
  final ProfileModel? profile;
  // New field declarations here

  ProfileState copyWith({
    DataState? profileState,
    ProfileModel? profile,
    // New copyWith params here
  }) {
    return ProfileState(
      profileState: profileState ?? this.profileState,
      profile: profile ?? this.profile,
      // New assignments here
    );
  }

  @override
  List<Object?> get props => [
    profileState,
    profile,
    // New props here
  ];
}
```

## Rules

- Follow the exact existing patterns in the cubit and state files.
- Use `DataState` enum for async operation states.
- Always update copyWith AND props when adding fields.
- Do NOT modify unrelated code.
- Preserve existing imports and formatting.
''';

const addModelCommandTemplate = r'''
---
name: add-model
description: Generate a data model with fromJson, toJson, copyWith, Equatable in a feature's data/models/ directory.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
argument-hint: "<feature-path> <model-name> e.g. lib/features/profile GET ProfileModel"
---

# Add Data Model

You are a model generation agent. Your job is to create a well-structured data model class in the appropriate feature directory, following the project's established patterns.

## Arguments

$ARGUMENTS: `<feature-path> <model-name>`

Example: `lib/features/profile ProfileModel`

If arguments are missing, ask the user for the feature path and model name. Then ask for the fields (name and type pairs).

## Process

### Step 1: Gather Field Information
1. Ask the user for the model fields. For each field, collect:
   - Field name (camelCase)
   - Field type (String, int, double, bool, DateTime, List<T>, or another model)
   - Whether it's nullable (default: yes, use `?`)

### Step 2: Create Model File
1. Determine the file path: `<feature-path>/data/models/<model_name_snake_case>.dart`
2. Create the model following this exact pattern:

```dart
import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  const ProfileModel({
    this.id,
    this.name,
    this.email,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
    );
  }

  final int? id;
  final String? name;
  final String? email;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };

  ProfileModel copyWith({
    int? id,
    String? name,
    String? email,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [id, name, email];
}
```

### Step 3: Handle Nested Models
- If a field references another model, import it properly.
- For `List<T>` fields in fromJson, use: `(json['items'] as List<dynamic>?)?.map((e) => ItemModel.fromJson(e as Map<String, dynamic>)).toList()`
- For DateTime fields: `json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null`
- For DateTime toJson: `'created_at': createdAt?.toIso8601String()`

### Step 4: Offer Repository Integration
- Ask the user if this model needs to be returned by a repository method.
- If yes, offer to update the repository interface and implementation to use this model.

### Step 5: Verify
1. Run `flutter analyze --no-pub` to check for errors.
2. Fix any issues.

## Rules

- Always extend `Equatable` and implement `props`.
- Always include `fromJson`, `toJson`, and `copyWith`.
- Use `const` constructor.
- Make all fields `final`.
- Default to nullable fields unless the user specifies otherwise.
- Use snake_case for JSON keys (matching typical API conventions).
- Use camelCase for Dart field names.
- Do NOT modify unrelated code.
''';

const addPaginationCommandTemplate = r'''
---
name: add-pagination
description: Wire up paginated API calls in an existing feature using a PaginationModel stored in cubit state with PaginatedListView or PaginatedGridView.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
argument-hint: "<feature-path> e.g. lib/features/products"
---

# Add Pagination

You are a pagination wiring agent. Your job is to add paginated API calls to an existing feature, using a PaginationModel stored in cubit state and the project's PaginatedListView/PaginatedGridView core widgets.

## Arguments

$ARGUMENTS: The feature directory path (e.g., lib/features/products)

If no argument is provided, ask the user which feature to add pagination to.

## Key Files

- **Feature cubit**: `<feature>/presentation/cubit/cubit.dart`
- **Feature state**: `<feature>/presentation/cubit/state.dart`
- **Feature repository interface**: `<feature>/domain/repository/<feature>_repository.dart`
- **Feature repository impl**: `<feature>/data/repository/<feature>_repository_impl.dart`
- **Endpoints**: `lib/core/endpoints/endpoints.dart`
- **Core widgets**: `lib/core/widgets/` (PaginatedListView, PaginatedGridView)

## Process

### Step 1: Create PaginationModel
1. Check if a shared `PaginationModel` already exists in `lib/core/models/common/` or similar.
2. If not, create one in the feature's `data/models/` directory:

```dart
import 'package:equatable/equatable.dart';

class PaginationModel<T> extends Equatable {
  const PaginationModel({
    this.items = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.perPage = 20,
  });

  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int perPage;

  bool get hasMore => currentPage < totalPages;

  PaginationModel<T> copyWith({
    List<T>? items,
    int? currentPage,
    int? totalPages,
    int? perPage,
  }) {
    return PaginationModel<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      perPage: perPage ?? this.perPage,
    );
  }

  @override
  List<Object?> get props => [items, currentPage, totalPages, perPage];
}
```

### Step 2: Update State
1. Add a `DataState<PaginationModel<ItemModel>>` field to the feature state:
```dart
final DataState paginatedItemsState;
final PaginationModel<ItemModel>? paginatedItems;
```
2. Update `copyWith` and `props` accordingly.

### Step 3: Add Endpoint
1. Add the paginated endpoint to `lib/core/endpoints/endpoints.dart`.

### Step 4: Update Repository
1. Add method to the abstract repository:
```dart
Future<RepositoryResponse<PaginationModel<ItemModel>>> getItems({
  required int page,
  int perPage = 20,
});
```
2. Implement in repository impl, parsing the paginated API response (typically has `data`, `current_page`, `last_page` or similar fields).

### Step 5: Add Cubit Methods
Add three methods to the cubit:

```dart
Future<void> fetchItems() async {
  emit(state.copyWith(paginatedItemsState: DataState.loading));
  final response = await _repository.getItems(page: 1);
  if (response.isSuccess) {
    emit(state.copyWith(
      paginatedItemsState: DataState.loaded,
      paginatedItems: response.data,
    ));
  } else {
    emit(state.copyWith(paginatedItemsState: DataState.failure));
  }
}

Future<void> loadNextPage() async {
  final current = state.paginatedItems;
  if (current == null || !current.hasMore) return;
  emit(state.copyWith(paginatedItemsState: DataState.pageLoading));
  final response = await _repository.getItems(page: current.currentPage + 1);
  if (response.isSuccess && response.data != null) {
    emit(state.copyWith(
      paginatedItemsState: DataState.loaded,
      paginatedItems: current.copyWith(
        items: [...current.items, ...response.data!.items],
        currentPage: response.data!.currentPage,
        totalPages: response.data!.totalPages,
      ),
    ));
  } else {
    emit(state.copyWith(paginatedItemsState: DataState.loaded));
  }
}

Future<void> refresh() async {
  await fetchItems();
}
```

### Step 6: Wire Screen to PaginatedListView
1. Read existing core widgets (PaginatedListView/PaginatedGridView) to match the exact API.
2. Update the screen to use the paginated widget:

```dart
BlocBuilder<ItemsCubit, ItemsState>(
  builder: (context, state) {
    return PaginatedListView<ItemModel>(
      items: state.paginatedItems?.items ?? [],
      dataState: state.paginatedItemsState,
      onLoadMore: () => context.read<ItemsCubit>().loadNextPage(),
      onRefresh: () => context.read<ItemsCubit>().refresh(),
      itemBuilder: (context, item) => ItemCard(item: item),
    );
  },
)
```

### Step 7: Verify
1. Run `flutter analyze --no-pub` to check for errors.
2. Fix any issues.

## Rules

- ALWAYS use a `PaginationModel` stored in cubit state. Do NOT use separate page/hasMore/items fields.
- Use `DataState.pageLoading` for load-more operations (not `DataState.loading`).
- Append items on loadNextPage, do NOT replace them.
- Use the existing PaginatedListView/PaginatedGridView from core widgets.
- Follow existing code patterns exactly.
- Do NOT modify unrelated code.
''';

const addFormCommandTemplate = r'''
---
name: add-form
description: Generate a validated form screen with CustomTextField widgets, FieldValidators, and cubit submission logic.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
argument-hint: "<feature-path> e.g. lib/features/profile/edit"
---

# Add Form Screen

You are a form generation agent. Your job is to create or update a screen with a validated form, wiring it to the feature's cubit for submission.

## Arguments

$ARGUMENTS: The feature directory path (e.g., lib/features/profile/edit)

If no argument is provided, ask the user which feature to add a form to.

Then ask the user what form fields they need. For each field, collect:
- Field label/name
- Field type (text, email, password, phone, number, date, dropdown)
- Validation rules (required, minLength, maxLength, email format, etc.)

## Key Files

- **FieldValidators**: `lib/core/field_validators.dart`
- **CustomTextField**: `lib/core/widgets/` (find the exact text field widget)
- **CustomButton**: `lib/core/widgets/` (find the exact button widget)
- **ToastHelper**: `lib/utils/helpers/toast_helper.dart` or similar
- **Feature cubit**: `<feature>/presentation/cubit/cubit.dart`
- **Feature state**: `<feature>/presentation/cubit/state.dart`

## Process

### Step 1: Read Existing Patterns
1. Read `lib/core/field_validators.dart` to see available validators.
2. Read core widgets directory to find CustomTextField, CustomButton, and their APIs.
3. Read existing form screens in the project for pattern reference.

### Step 2: Create Form Screen
1. Create or update the screen file in `<feature>/presentation/views/`.
2. Use this structure:

```dart
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: context.l10n.editProfile),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (prev, curr) => prev.submitState != curr.submitState,
        listener: (context, state) {
          if (state.submitState == DataState.loaded) {
            ToastHelper.showSuccess(context, context.l10n.profileUpdated);
            context.pop();
          } else if (state.submitState == DataState.failure) {
            ToastHelper.showError(context, context.l10n.somethingWentWrong);
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsetsDirectional.all(16),
              children: [
                CustomTextField(
                  controller: _nameController,
                  label: context.l10n.name,
                  validator: FieldValidators.required,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: context.l10n.email,
                  validator: FieldValidators.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 24),
                CustomButton(
                  text: context.l10n.save,
                  isLoading: state.submitState == DataState.loading,
                  onPressed: _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileCubit>().updateProfile(
        name: _nameController.text,
        email: _emailController.text,
      );
    }
  }
}
```

### Step 3: Update Cubit State
1. Add `submitState` field (DataState) to the feature state if not present.
2. Update `copyWith` and `props`.

### Step 4: Add Cubit Submit Method
```dart
Future<void> updateProfile({
  required String name,
  required String email,
}) async {
  emit(state.copyWith(submitState: DataState.loading));
  final response = await _repository.updateProfile(
    name: name,
    email: email,
  );
  if (response.isSuccess) {
    emit(state.copyWith(submitState: DataState.loaded));
  } else {
    emit(state.copyWith(submitState: DataState.failure));
  }
}
```

### Step 5: Verify
1. Run `flutter analyze --no-pub` to check for errors.
2. Fix any issues.

## Rules

- Always use `GlobalKey<FormState>` for form validation.
- Always dispose TextEditingControllers in `dispose()`.
- Use `BlocConsumer` when you need both listener (for side effects) and builder (for UI).
- Use `FieldValidators` from the project — do NOT write custom validation inline.
- Use `EdgeInsetsDirectional` instead of `EdgeInsets` for RTL support.
- Use `context.l10n.keyName` for all user-facing strings.
- Use `ToastHelper` for success/error feedback.
- Follow existing code patterns exactly.
- Do NOT modify unrelated code.
''';

const addDiCommandTemplate = r'''
---
name: add-di
description: Register a new service or repository in GetIt dependency injection via the Injector wrapper.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
argument-hint: "<service-name> e.g. PaymentService"
---

# Add Dependency Injection Registration

You are a dependency injection agent. Your job is to create and register a new service or repository in the project's GetIt-based DI system.

## Arguments

$ARGUMENTS: `<service-name>` (e.g., PaymentService)

If no argument is provided, ask the user what service or repository they want to register.

Then ask: Is this a **service** (standalone, lives in core/services/) or a **repository** (feature-based, lives in feature directory)?

## Key Files

- **Injector wrapper**: `lib/core/di/injector.dart`
- **App modules**: `lib/core/di/modules/app_modules.dart`
- **ApiService**: `lib/core/api_service/api_service.dart`
- **AppPreferences**: `lib/core/app_preferences/app_preferences.dart`

## Process

### For a Service (standalone):

#### Step 1: Create Abstract Interface
1. Create `lib/core/services/<service_name_snake>/<service_name_snake>.dart`:
```dart
abstract class PaymentService {
  Future<PaymentResult> processPayment(PaymentRequest request);
  Future<void> cancelPayment(String paymentId);
}
```

#### Step 2: Create Implementation
1. Create `lib/core/services/<service_name_snake>/<service_name_snake>_impl.dart`:
```dart
class PaymentServiceImpl implements PaymentService {
  PaymentServiceImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    // Implementation
  }

  @override
  Future<void> cancelPayment(String paymentId) async {
    // Implementation
  }
}
```

#### Step 3: Register in App Modules
1. Read `lib/core/di/modules/app_modules.dart`.
2. Add the registration:
```dart
injector.registerLazySingleton<PaymentService>(
  () => PaymentServiceImpl(injector<ApiService>()),
);
```

### For a Repository (feature-based):

#### Step 1: Create or Locate Repository Interface
1. Check if `<feature>/domain/repository/<feature>_repository.dart` exists.
2. If not, create the abstract repository class.

#### Step 2: Create or Locate Repository Implementation
1. Check if `<feature>/data/repository/<feature>_repository_impl.dart` exists.
2. If not, create the implementation class.

#### Step 3: Register in App Modules
1. Read `lib/core/di/modules/app_modules.dart`.
2. Add the registration:
```dart
injector.registerLazySingleton<ProfileRepository>(
  () => ProfileRepositoryImpl(
    injector<ApiService>(),
    injector<AppPreferences>(),
  ),
);
```

### Step 4: Verify
1. Run `flutter analyze --no-pub` to check for errors.
2. Fix any issues.

## Rules

- Always register using `injector.registerLazySingleton<AbstractType>(() => ConcreteType())`.
- The `injector` is a wrapper around GetIt — use it, not `GetIt.I` directly.
- Dependencies are resolved via `injector<DependencyType>()`.
- Abstract interfaces go in `domain/` (for features) or standalone abstract classes (for services).
- Implementations go in `data/` (for features) or `_impl` suffixed files (for services).
- Follow existing registration patterns in `app_modules.dart`.
- Do NOT modify unrelated code.
''';

const addHiveModelCommandTemplate = r'''
---
name: add-hive-model
description: Generate a Hive TypeAdapter model for local persistence with proper TypeId assignment and adapter registration.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
argument-hint: "<feature-path> <model-name> e.g. lib/features/profile UserCache"
---

# Add Hive Model

You are a Hive model generation agent. Your job is to create a Hive-persisted model with proper TypeAdapter annotations and register it in the app's bootstrap.

## Arguments

$ARGUMENTS: `<feature-path> <model-name>` (e.g., lib/features/profile UserCache)

If arguments are missing, ask the user for the feature path, model name, and fields.

## Key Files

- **Existing Hive models**: Search for `@HiveType` annotations across the project
- **Bootstrap/main**: `lib/bootstrap.dart` or `lib/main.dart` (where Hive adapters are registered)
- **pubspec.yaml**: `pubspec.yaml`

## Process

### Step 1: Find Next Available TypeId
1. Search the entire project for `@HiveType(typeId:` to find all existing TypeIds.
2. Determine the next available TypeId (max existing + 1).

### Step 2: Create Hive Model
1. Create the model file at `<feature-path>/data/models/<model_name_snake>.dart`:

```dart
import 'package:hive_ce/hive_ce.dart';
import 'package:equatable/equatable.dart';

part '<model_name_snake>.g.dart';

@HiveType(typeId: X)
class UserCache extends Equatable {
  const UserCache({
    this.id,
    this.name,
    this.email,
    this.cachedAt,
  });

  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final DateTime? cachedAt;

  UserCache copyWith({
    int? id,
    String? name,
    String? email,
    DateTime? cachedAt,
  }) {
    return UserCache(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, email, cachedAt];
}
```

### Step 3: Register Adapter
1. Find where Hive adapters are registered (usually `bootstrap.dart` or early in `main()`).
2. Add: `Hive.registerAdapter(UserCacheAdapter());`
3. The adapter class name is always `<ModelName>Adapter` — generated by build_runner.

### Step 4: Check Dependencies
1. Read `pubspec.yaml`.
2. Ensure `hive_ce` is in dependencies.
3. Ensure `hive_ce_generator` and `build_runner` are in dev_dependencies.
4. If missing, add them.

### Step 5: Instruct User
1. Tell the user to run: `dart run build_runner build --delete-conflicting-outputs`
2. This generates the `.g.dart` file with the TypeAdapter implementation.

### Step 6: Verify
1. Run `flutter analyze --no-pub` to check for errors (note: `.g.dart` won't exist until build_runner runs, so ignore that specific error).

## Rules

- TypeId must be UNIQUE across the entire project. Always scan first.
- HiveField indices start at 0 and increment sequentially.
- NEVER reuse a TypeId or HiveField index — this causes data corruption.
- Always include the `part` directive for code generation.
- Use `hive_ce` (community edition), not the original `hive` package.
- Follow existing Hive model patterns in the project.
- Do NOT modify unrelated code.
''';

const addTestCommandTemplate = r'''
---
name: add-test
description: Generate unit tests for a feature's cubit and repository using mocktail and bloc_test.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
argument-hint: "<feature-path> e.g. lib/features/profile"
---

# Add Tests

You are a test generation agent. Your job is to create comprehensive unit tests for a feature's cubit and repository layers.

## Arguments

$ARGUMENTS: The feature directory path (e.g., lib/features/profile)

If no argument is provided, ask the user which feature to test.

## Key Packages

- **mocktail**: For creating mocks (not mockito)
- **bloc_test**: For testing cubits with `blocTest`
- **flutter_test**: Standard Flutter testing

## Process

### Step 1: Read Feature Code
1. Read the cubit, state, repository interface, and repository implementation files.
2. Identify all public methods, state fields, and dependencies.

### Step 2: Create Test Directory Structure
```
test/features/<feature>/
├── presentation/cubit/
│   └── <feature>_cubit_test.dart
└── data/repository/
    └── <feature>_repository_impl_test.dart
```

### Step 3: Generate Cubit Tests
Create `test/features/<feature>/presentation/cubit/<feature>_cubit_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Import cubit, state, repository, models

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late ProfileCubit cubit;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    cubit = ProfileCubit(mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('ProfileCubit', () {
    test('initial state is correct', () {
      expect(cubit.state, const ProfileState());
    });

    blocTest<ProfileCubit, ProfileState>(
      'emits [loading, loaded] when fetchProfile succeeds',
      build: () {
        when(() => mockRepository.getProfile())
            .thenAnswer((_) async => RepositoryResponse.success(mockProfile));
        return cubit;
      },
      act: (cubit) => cubit.fetchProfile(),
      expect: () => [
        const ProfileState(profileState: DataState.loading),
        ProfileState(
          profileState: DataState.loaded,
          profile: mockProfile,
        ),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [loading, failure] when fetchProfile fails',
      build: () {
        when(() => mockRepository.getProfile())
            .thenAnswer((_) async => RepositoryResponse.failure('Error'));
        return cubit;
      },
      act: (cubit) => cubit.fetchProfile(),
      expect: () => [
        const ProfileState(profileState: DataState.loading),
        const ProfileState(profileState: DataState.failure),
      ],
    );
  });
}
```

### Step 4: Generate Repository Tests
Create `test/features/<feature>/data/repository/<feature>_repository_impl_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Import repository impl, api service, models

class MockApiService extends Mock implements ApiService {}
class MockAppPreferences extends Mock implements AppPreferences {}

void main() {
  late ProfileRepositoryImpl repository;
  late MockApiService mockApiService;
  late MockAppPreferences mockAppPreferences;

  setUp(() {
    mockApiService = MockApiService();
    mockAppPreferences = MockAppPreferences();
    repository = ProfileRepositoryImpl(mockApiService, mockAppPreferences);
  });

  group('ProfileRepositoryImpl', () {
    group('getProfile', () {
      test('returns success when API call succeeds', () async {
        when(() => mockApiService.get(any()))
            .thenAnswer((_) async => Response(
              data: {'id': 1, 'name': 'Test'},
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        final result = await repository.getProfile();

        expect(result.isSuccess, true);
        expect(result.data, isNotNull);
      });

      test('returns failure when API call throws', () async {
        when(() => mockApiService.get(any()))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
              type: DioExceptionType.connectionError,
            ));

        final result = await repository.getProfile();

        expect(result.isSuccess, false);
      });
    });
  });
}
```

### Step 5: Check Dependencies
1. Read `pubspec.yaml`.
2. Ensure these are in `dev_dependencies`:
   - `mocktail`
   - `bloc_test`
3. If missing, add them.

### Step 6: Run Tests
1. Run `flutter test test/features/<feature>/` to verify all tests pass.
2. Fix any failures.

## Rules

- Use `mocktail` (not mockito) for mocking.
- Use `blocTest` for all cubit tests — do NOT use manual emit testing.
- Test loading, success, AND failure paths for every async operation.
- Create mock data constants at the top of test files for reuse.
- Always `close()` the cubit in `tearDown`.
- Follow the existing test patterns in the project if any tests already exist.
- Do NOT modify source code — only create test files.
''';

const addBottomNavCommandTemplate = r'''
---
name: add-bottom-nav
description: Wire up bottom navigation with tabs for existing features using GoRouter ShellRoute and a navigation widget.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
argument-hint: "[role] e.g. customer (optional)"
---

# Add Bottom Navigation

You are a navigation wiring agent. Your job is to set up bottom navigation with tabs using GoRouter's ShellRoute and the project's navigation patterns.

## Arguments

$ARGUMENTS: `[role]` (optional, e.g., customer, admin — used for role-based navigation)

If no argument is provided, proceed without a role prefix.

## Key Files

- **GoRouter config**: `lib/go_router/router.dart`
- **Routes**: `lib/go_router/routes.dart`
- **Route exports**: `lib/go_router/exports.dart`
- **Features directory**: `lib/features/`
- **App page**: `lib/app/view/app_page.dart` (MultiBlocProvider)

## Process

### Step 1: Discover Available Features
1. List the features in `lib/features/` directory.
2. Ask the user which features should be tabs in the bottom navigation.
3. For each tab, ask for: icon, label.

### Step 2: Create Navigation Widget
1. Create a shell/navigation screen (e.g., `lib/features/navigation/presentation/views/navigation_screen.dart`):

```dart
class NavigationScreen extends StatelessWidget {
  const NavigationScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: context.l10n.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: context.l10n.profile,
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/profile')) return 1;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.profile);
    }
  }
}
```

### Step 3: Configure GoRouter with ShellRoute
1. Read the existing router configuration.
2. Wrap the tab routes in a `ShellRoute`:

```dart
ShellRoute(
  builder: (context, state, child) => NavigationScreen(child: child),
  routes: [
    GoRoute(
      path: '/home',
      name: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
),
```

### Step 4: Add Route Constants
1. Update `lib/go_router/routes.dart` with route path constants for each tab.
2. Update `lib/go_router/exports.dart` with necessary imports.

### Step 5: Handle Tab State Persistence
- GoRouter's ShellRoute preserves the state of each tab branch by default.
- If the project uses `StatefulShellRoute`, use `StatefulShellRoute.indexedStack` for keeping tab states alive:

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      NavigationScreen(navigationShell: navigationShell),
  branches: [
    StatefulShellBranch(routes: [/* home routes */]),
    StatefulShellBranch(routes: [/* profile routes */]),
  ],
)
```

### Step 6: Verify
1. Run `flutter analyze --no-pub` to check for errors.
2. Fix any issues.

## Rules

- Use GoRouter's `ShellRoute` or `StatefulShellRoute` — do NOT use a custom tab controller.
- Use `NavigationBar` (Material 3) or `BottomNavigationBar` depending on what the project already uses.
- Use `context.l10n` for all tab labels.
- Use `EdgeInsetsDirectional` for RTL support.
- Follow existing routing patterns in the project.
- Register any new cubits needed in `app_page.dart`'s MultiBlocProvider.
- Do NOT modify unrelated code.
''';

const addInterceptorCommandTemplate = r'''
---
name: add-interceptor
description: Add a custom Dio interceptor to the API service for cross-cutting concerns like caching, retry, or connectivity checks.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
argument-hint: "<interceptor-name> e.g. CacheInterceptor"
---

# Add Dio Interceptor

You are an API interceptor agent. Your job is to create a custom Dio interceptor and register it in the project's API service.

## Arguments

$ARGUMENTS: `<interceptor-name>` (e.g., CacheInterceptor, RetryInterceptor, ConnectivityInterceptor)

If no argument is provided, ask the user what type of interceptor they need. Common types:
- **Cache**: Cache GET responses for a configurable duration
- **Retry**: Retry failed requests with exponential backoff
- **Connectivity**: Check network connectivity before making requests
- **Rate Limit**: Throttle requests to avoid API rate limits
- **Logging**: Enhanced request/response logging

## Key Files

- **ApiService**: `lib/core/api_service/api_service.dart`
- **Existing interceptors**: `lib/core/api_service/` (look for AuthInterceptor, LoggingInterceptor, etc.)

## Process

### Step 1: Read Existing Interceptors
1. Read `lib/core/api_service/api_service.dart` to understand how interceptors are registered.
2. Read any existing interceptors to follow the established pattern.

### Step 2: Create Interceptor
1. Create `lib/core/api_service/<interceptor_name_snake>.dart`:

```dart
import 'package:dio/dio.dart';

class CacheInterceptor extends Interceptor {
  CacheInterceptor();

  final Map<String, _CacheEntry> _cache = {};
  final Duration cacheDuration;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Pre-request logic (e.g., check cache, add headers)
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Post-response logic (e.g., store in cache)
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Error handling logic (e.g., retry, serve stale cache)
    handler.next(err);
  }
}
```

### Step 3: Register in ApiService
1. Read the ApiService constructor to find where interceptors are added.
2. Add the new interceptor to the chain:
```dart
_dio.interceptors.addAll([
  AuthInterceptor(appPreferences),
  CacheInterceptor(),          // Add new interceptor
  LoggingInterceptor(),
]);
```
3. Order matters: Auth first, then custom interceptors, then logging last.

### Step 4: Handle Dependencies
- If the interceptor needs `AppPreferences`, `ApiService`, or other dependencies, inject them via constructor.
- Update the ApiService constructor if new dependencies are needed.
- Update DI registration in `app_modules.dart` if needed.

### Step 5: Verify
1. Run `flutter analyze --no-pub` to check for errors.
2. Fix any issues.

## Common Interceptor Patterns

### Retry Interceptor
```dart
@override
void onError(DioException err, ErrorInterceptorHandler handler) async {
  if (_shouldRetry(err) && retryCount < maxRetries) {
    await Future.delayed(Duration(seconds: pow(2, retryCount).toInt()));
    try {
      final response = await _dio.fetch(err.requestOptions);
      handler.resolve(response);
      return;
    } catch (_) {}
  }
  handler.next(err);
}
```

### Connectivity Interceptor
```dart
@override
void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
  final hasConnection = await _connectivityService.hasInternet;
  if (!hasConnection) {
    handler.reject(DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
      error: 'No internet connection',
    ));
    return;
  }
  handler.next(options);
}
```

## Rules

- Always extend `Interceptor` from Dio.
- Use `handler.next()` to pass to the next interceptor in the chain.
- Use `handler.resolve()` to short-circuit with a response (e.g., cached response).
- Use `handler.reject()` to short-circuit with an error.
- Interceptor order matters: Auth → Custom → Logging.
- Follow the existing interceptor patterns in the project.
- Do NOT modify unrelated code.
''';

const implementScreenCommandTemplate = r'''
---
name: implement-screen
description: Build a screen from a description or Figma reference following the project's architecture and existing core widgets.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
argument-hint: "<feature-path> e.g. lib/features/profile"
---

# Implement Screen

You are a screen implementation agent. Your job is to build a complete screen using the project's existing core widgets, theme system, and architecture patterns.

## Arguments

$ARGUMENTS: The feature directory path (e.g., lib/features/profile)

If no argument is provided, ask the user which feature's screen to implement.

Then ask: Do you have a **description** of the screen, or a **Figma URL** to reference?

## Key Files

- **Core widgets**: `lib/core/widgets/` (CustomAppBar, CustomButton, CustomTextField, PaginatedListView, PaginatedGridView, etc.)
- **AppColors**: `lib/constants/app_colors.dart`
- **Text styles**: Extensions on BuildContext — `context.h1`, `context.h2`, `context.t1`, `context.t2`, `context.b1`, `context.b2`, `context.l1`, `context.l2` (heading, title, body, label sizes)
- **AssetPaths**: `lib/constants/asset_paths.dart`
- **Feature cubit**: `<feature>/presentation/cubit/cubit.dart`
- **Feature state**: `<feature>/presentation/cubit/state.dart`

## Process

### Step 1: Understand Requirements
1. Read the user's description or Figma reference.
2. If a Figma URL is provided, use the Figma tools to extract the design context.

### Step 2: Read Available Core Widgets
1. Read `lib/core/widgets/` directory to understand available reusable widgets.
2. Read each relevant widget to understand its API (constructor parameters).
3. Read `lib/constants/app_colors.dart` for color constants.
4. Read text style extensions to know available typography.
5. Read `lib/constants/asset_paths.dart` for available assets.

### Step 3: Read Feature Context
1. Read the feature's cubit and state files to understand available data.
2. Read existing screens in the feature for patterns.

### Step 4: Build the Screen
1. Create or update the screen file in `<feature>/presentation/views/`.
2. Follow this structure:

```dart
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: context.l10n.profile),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.profileState == DataState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.profileState == DataState.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.l10n.somethingWentWrong, style: context.b1),
                  SizedBox(height: 16),
                  CustomButton(
                    text: context.l10n.retry,
                    onPressed: () => context.read<ProfileCubit>().fetchProfile(),
                  ),
                ],
              ),
            );
          }
          return _buildContent(context, state);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProfileState state) {
    return ListView(
      padding: EdgeInsetsDirectional.all(16),
      children: [
        // Build UI using core widgets, AppColors, text styles
      ],
    );
  }
}
```

### Step 5: Handle All States
- **Loading**: Show `CircularProgressIndicator` or skeleton/shimmer.
- **Failure**: Show error message with retry button.
- **Empty**: Show empty state illustration with message.
- **Loaded**: Show the actual content.

### Step 6: Verify
1. Run `flutter analyze --no-pub` to check for errors.
2. Fix any issues.

## Widget Usage Patterns

### Text Styles
```dart
Text('Heading', style: context.h1)
Text('Title', style: context.t1)
Text('Body text', style: context.b1)
Text('Label', style: context.l1)
// Use .copyWith() for modifications:
Text('Custom', style: context.b1.copyWith(color: AppColors.primary))
```

### Colors
```dart
Container(color: AppColors.primary)
Container(color: AppColors.background)
```

### Assets
```dart
Image.asset(AssetPaths.logo)
SvgPicture.asset(AssetPaths.emptyState)
```

### Spacing (RTL-safe)
```dart
Padding(padding: EdgeInsetsDirectional.only(start: 16, end: 16))
Padding(padding: EdgeInsetsDirectional.all(16))
// NEVER use EdgeInsets.left/right — always use EdgeInsetsDirectional.start/end
```

## Rules

- ALWAYS use existing core widgets before building custom ones.
- ALWAYS use `context.l10n.keyName` for user-facing strings.
- ALWAYS use `EdgeInsetsDirectional` instead of `EdgeInsets` for RTL support.
- ALWAYS use `context.h1/t1/b1/l1` text styles — do NOT use raw TextStyle.
- ALWAYS use `AppColors` — do NOT use hardcoded Color values.
- ALWAYS handle loading, error, and empty states.
- Use `BlocBuilder` for UI rendering, `BlocConsumer` when side effects are also needed.
- Keep the screen widget clean — extract complex sub-widgets into separate widget files in `<feature>/presentation/widgets/`.
- Do NOT modify unrelated code.
''';

const addFirebaseConfigCommandTemplate = r'''
---
name: add-firebase-config
description: Configure Firebase for all flavors (development, staging, production) using flutterfire configure with the correct bundle IDs.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
argument-hint: ""
---

# Add Firebase Configuration

You are a Firebase configuration agent. Your job is to set up Firebase for all three app flavors using `flutterfire configure`.

## Arguments

This command is interactive — no arguments needed.

## Process

### Step 1: Gather Information
1. **ASK the user for their Firebase project ID** (e.g., `my-app-12345`). Do NOT proceed without it.
2. Read `pubspec.yaml` to get the project name.
3. Read `android/app/build.gradle.kts` (or `build.gradle`) to detect the `applicationId` / org name / namespace.
4. Read `ios/Runner.xcodeproj/project.pbxproj` or flavor configs to detect iOS bundle ID pattern.

### Step 2: Determine Bundle IDs
Based on the detected org name (e.g., `com.example.myapp`), the three flavors are:
- **Development**: `com.example.myapp.dev` (Android), `com.example.myapp.dev` (iOS)
- **Staging**: `com.example.myapp.stg` (Android), `com.example.myapp.stg` (iOS)
- **Production**: `com.example.myapp` (Android), `com.example.myapp` (iOS)

### Step 3: Run flutterfire configure (3 times)
Run each command. If `flutterfire` is not installed, instruct the user to run `dart pub global activate flutterfire_cli` first.

#### Development flavor:
```bash
flutterfire configure \
  --project=<firebase-project-id> \
  --out=lib/firebase_options_dev.dart \
  --ios-bundle-id=<org>.dev \
  --android-app-id=<org>.dev \
  --yes
```

#### Staging flavor:
```bash
flutterfire configure \
  --project=<firebase-project-id> \
  --out=lib/firebase_options_stg.dart \
  --ios-bundle-id=<org>.stg \
  --android-app-id=<org>.stg \
  --yes
```

#### Production flavor:
```bash
flutterfire configure \
  --project=<firebase-project-id> \
  --out=lib/firebase_options_prod.dart \
  --ios-bundle-id=<org> \
  --android-app-id=<org> \
  --yes
```

### Step 4: Update Entry Points
1. Find the main entry files (typically `lib/main_development.dart`, `lib/main_staging.dart`, `lib/main_production.dart` or similar).
2. In each entry point, import the corresponding firebase_options file:
```dart
// In main_development.dart:
import 'firebase_options_dev.dart';

// In main_staging.dart:
import 'firebase_options_stg.dart';

// In main_production.dart:
import 'firebase_options_prod.dart';
```
3. Ensure `Firebase.initializeApp` uses the correct options:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Step 5: Check Dependencies
1. Read `pubspec.yaml`.
2. Ensure `firebase_core` is in dependencies.
3. If missing, add it.

### Step 6: Verify
1. Run `flutter analyze --no-pub` to check for errors.
2. Fix any issues.

## Rules

- ALWAYS ask for the Firebase project ID first — do NOT guess or make one up.
- The three flavors are: development (.dev), staging (.stg), production (no suffix).
- Use `--yes` flag to skip interactive prompts in flutterfire configure.
- Each flavor gets its own `firebase_options_*.dart` output file.
- Do NOT modify unrelated code.
- If flutterfire CLI is not available, instruct the user to install it first.
''';
