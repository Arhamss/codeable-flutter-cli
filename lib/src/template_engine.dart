/// Simple mustache-style template engine.
///
/// Replaces `{{key}}` placeholders in templates with values from [vars].
class TemplateEngine {
  const TemplateEngine._();

  /// Renders a template string by replacing all `{{key}}` placeholders.
  static String render(String template, Map<String, String> vars) {
    var result = template;
    for (final entry in vars.entries) {
      result = result.replaceAll('{{${entry.key}}}', entry.value);
    }
    return result;
  }

  /// Converts a snake_case name to PascalCase.
  static String toPascalCase(String snakeCase) {
    return snakeCase
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join();
  }

  /// Converts a snake_case name to camelCase.
  static String toCamelCase(String snakeCase) {
    final pascal = toPascalCase(snakeCase);
    if (pascal.isEmpty) return '';
    return '${pascal[0].toLowerCase()}${pascal.substring(1)}';
  }

  /// Converts a snake_case name to kebab-case.
  static String toKebabCase(String snakeCase) {
    return snakeCase.replaceAll('_', '-');
  }

  /// Converts a PascalCase or camelCase name to snake_case.
  static String toSnakeCase(String name) {
    return name
        .replaceAllMapped(
          RegExp('([A-Z])'),
          (match) => '_${match.group(1)!.toLowerCase()}',
        )
        .replaceAll(RegExp('^_'), '')
        .replaceAll(RegExp('__+'), '_');
  }

  /// Builds the standard variable map from project inputs.
  static Map<String, String> buildVars({
    required String projectName,
    required String orgName,
    String description = 'A new Flutter project',
  }) {
    final snakeName = toSnakeCase(projectName)
        .replaceAll(RegExp('[^a-z0-9_]'), '')
        .replaceAll(RegExp('^[0-9]'), '');
    return {
      'project_name': snakeName,
      'ProjectName': toPascalCase(snakeName),
      'projectName': toCamelCase(snakeName),
      'org_name': orgName,
      'description': description,
    };
  }
}
