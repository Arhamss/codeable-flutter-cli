const analysisOptionsTemplate = '''
analyzer:
  exclude:
    - lib/l10n/gen/*
  errors:
    avoid_positional_boolean_parameters: ignore
    lines_longer_than_80_chars: ignore
    use_build_context_synchronously: ignore

include: package:very_good_analysis/analysis_options.6.0.0.yaml

linter:
  rules:
    public_member_api_docs: false
''';
