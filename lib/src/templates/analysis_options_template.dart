const analysisOptionsTemplate = '''
analyzer:
  exclude:
    - lib/l10n/gen/*
    - "**/*.g.dart"
  errors:
    avoid_positional_boolean_parameters: ignore
    lines_longer_than_80_chars: ignore
    use_build_context_synchronously: ignore

include: package:very_good_analysis/analysis_options.6.0.0.yaml

linter:
  rules:
    public_member_api_docs: false
    one_member_abstracts: false
    sort_pub_dependencies: false
    use_setters_to_change_properties: false
''';
