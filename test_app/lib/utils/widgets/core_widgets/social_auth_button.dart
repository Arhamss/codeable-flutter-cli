import 'package:test_app/exports.dart';

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.iconPath,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? iconPath;

  @override
  Widget build(BuildContext context) {
    return CustomButton.secondary(
      text: text,
      onPressed: isLoading ? null : onPressed,
      isLoading: isLoading,
      prefixIcon: iconPath != null
          ? SvgPicture.asset(
              iconPath!,
              width: 20,
              height: 20,
            )
          : null,
      iconSpacing: 12,
    );
  }
}
