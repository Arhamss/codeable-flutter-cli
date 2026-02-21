import 'package:test_app/exports.dart';

class CustomOutlineButton extends StatelessWidget {
  CustomOutlineButton({
    required this.text,
    required this.onPressed,
    required this.isLoading,
    super.key,
    this.borderColor = AppColors.primary,
    this.textColor = AppColors.primary,
    this.disabledTextColor = AppColors.textTertiary,
    this.disabledBorderColor,
    this.borderRadius = 100,
    EdgeInsets? padding,
    this.fontWeight = FontWeight.w600,
    this.splashColor = Colors.black12,
    this.fontSize = 16,
    this.prefixIcon,
    this.suffixIcon,
    EdgeInsets? outsidePadding,
    this.isExpanded = true,
    this.iconSpacing,
    this.disabled = false,
    this.loadingColor,
    this.borderWidth = 1.5,
  })  : padding = padding ??
            const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 14,
            ),
        outsidePadding = outsidePadding ?? const EdgeInsets.all(4);

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color borderColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final FontWeight fontWeight;
  final Color splashColor;
  final double fontSize;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsets? outsidePadding;
  final bool isExpanded;
  final double? iconSpacing;
  final bool disabled;
  final Color disabledTextColor;
  final Color? disabledBorderColor;
  final Color? loadingColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = disabled
        ? (disabledBorderColor ?? borderColor.withValues(alpha: 0.5))
        : borderColor;

    final button = TextButton(
      onPressed: (isLoading || disabled) ? null : onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsetsDirectional.zero,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: effectiveBorderColor, width: borderWidth),
        ),
        splashFactory: InkRipple.splashFactory,
        overlayColor: splashColor,
      ),
      child: Padding(
        padding: padding,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: LoadingWidget(color: loadingColor ?? textColor),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    SizedBox(width: iconSpacing ?? 8),
                  ],
                  Text(
                    text,
                    style: context.b1.copyWith(
                      color: disabled ? disabledTextColor : textColor,
                      fontWeight: fontWeight,
                      fontSize: fontSize,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    SizedBox(width: iconSpacing ?? 8),
                    suffixIcon!,
                  ],
                ],
              ),
      ),
    );

    return Padding(
      padding: outsidePadding ?? EdgeInsetsDirectional.zero,
      child: isExpanded ? Row(children: [Expanded(child: button)]) : button,
    );
  }
}
