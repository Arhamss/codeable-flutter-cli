extension StringHelpers on String {
  String get toLetterCase =>
      length > 0 ? '\${this[0].toUpperCase()}\${substring(1).toLowerCase()}' : '';

  String get toTitleCase => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toLetterCase)
      .join(' ');

  String sPluralise(num number) => (number == 1) ? this : '\${this}s';
}

extension StringListHelper on List<String> {
  String get toBulletedString => map((item) => '\u2022 \$item').join('\n\n');

  String bulletedString({String gap = '\n'}) =>
      map((item) => '\u2022 \$item').join(gap);
}

extension ImagePathHelper on String {
  bool get isSvg => endsWith('.svg');

  bool get isWebp => endsWith('.webp');
}
