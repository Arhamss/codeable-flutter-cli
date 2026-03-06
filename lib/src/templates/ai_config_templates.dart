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
