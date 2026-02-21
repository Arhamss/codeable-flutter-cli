import 'package:test_app/exports.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    required this.title,
    this.padding,
    this.bottomSpacing,
    super.key,
  });

  final String title;
  final EdgeInsets? padding;
  final double? bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: context.t1.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: bottomSpacing ?? 16),
      ],
    );
  }
}
