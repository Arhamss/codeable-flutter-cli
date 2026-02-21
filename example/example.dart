/// Codeable CLI — Example Usage
///
/// Codeable CLI is a command-line tool for scaffolding production-ready
/// Flutter projects. Below are the most common usage patterns.
///
/// ## Installation
///
/// ```sh
/// dart pub global activate codeable_cli
/// ```
///
/// ## Create a New Project
///
/// ```sh
/// # Interactive mode (prompts for name and org)
/// codeable_cli create
///
/// # With flags
/// codeable_cli create --name my_app --org com.example.myapp
///
/// # With a custom description and output directory
/// codeable_cli create \
///   --name my_app \
///   --org com.example.myapp \
///   --description "My production-ready Flutter app" \
///   --output ~/projects
/// ```
///
/// ## Generate a Feature Module
///
/// Run inside an existing Codeable project to scaffold a new feature
/// with Clean Architecture (data, domain, presentation layers):
///
/// ```sh
/// codeable_cli feature profile
/// ```
///
/// This creates `lib/features/profile/` with repository, cubit, and
/// screen files — and auto-wires routing and DI.
///
/// ## Rename a Project
///
/// ```sh
/// codeable_cli rename --name new_app_name
/// ```
///
/// ## Change Bundle Identifier
///
/// ```sh
/// codeable_cli change-id --id com.neworg.newapp
/// ```
///
/// ## Programmatic Usage
///
/// You can also invoke the CLI programmatically:
///
/// ```dart
/// import 'package:codeable_cli/src/command_runner.dart';
///
/// Future<void> main() async {
///   final runner = CodeableCliCommandRunner();
///   final exitCode = await runner.run([
///     'create',
///     '--name', 'my_app',
///     '--org', 'com.example.myapp',
///   ]);
///   print('Exit code: $exitCode');
/// }
/// ```
library;
