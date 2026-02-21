import 'package:test_app/exports.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    required this.onPressed,
    required this.text,
    this.textStyle,
    super.key,
  });

  final VoidCallback onPressed;
  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        splashFactory: NoSplash.splashFactory,
        foregroundColor: AppColors.primary,
        overlayColor: Colors.transparent,
      ),
      child: Text(text, style: textStyle ?? context.h2.copyWith(fontSize: 16)),
    );
  }
}
