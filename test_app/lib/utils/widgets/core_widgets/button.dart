import 'package:test_app/exports.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    super.key,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.textOnPrimary,
    this.disabledTextColor,
    this.disabledBackgroundColor,
    this.borderRadius = 100,
    EdgeInsetsGeometry? padding,
    this.fontWeight = FontWeight.w600,
    this.splashColor = Colors.black12,
    this.fontSize = 16,
    this.prefixIcon,
    this.suffixIcon,
    EdgeInsetsGeometry? outsidePadding,
    this.isExpanded = true,
    this.iconSpacing,
    this.disabled = false,
    this.loadingColor = AppColors.textOnPrimary,
    this.borderColor,
    this.borderWidth = 1.0,
    this.textStyle,
    this.hasShadow = false,
  })  : padding = padding ??
            const EdgeInsetsDirectional.symmetric(
              vertical: 12,
              horizontal: 24,
            ),
        outsidePadding = outsidePadding ?? const EdgeInsetsDirectional.all(4);

  /// Primary button - Dark background with light text
  CustomButton.primary({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    super.key,
    this.prefixIcon,
    this.suffixIcon,
    EdgeInsets? outsidePadding,
    this.isExpanded = true,
    this.iconSpacing,
    this.disabled = false,
    this.hasShadow = false,
  })  : backgroundColor = AppColors.primary,
        textColor = AppColors.textOnPrimary,
        disabledTextColor = AppColors.textTertiary,
        disabledBackgroundColor = AppColors.disabled,
        borderRadius = 100,
        padding = const EdgeInsetsDirectional.symmetric(
          vertical: 16,
          horizontal: 24,
        ),
        fontWeight = FontWeight.w600,
        splashColor = Colors.black12,
        fontSize = 16,
        loadingColor = AppColors.textOnPrimary,
        borderColor = AppColors.primary,
        borderWidth = 1.0,
        textStyle = null,
        outsidePadding = outsidePadding ?? const EdgeInsetsDirectional.all(4);

  /// Secondary button - Light background with dark text and border
  const CustomButton.secondary({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    super.key,
    this.prefixIcon,
    this.suffixIcon,
    this.outsidePadding = const EdgeInsetsDirectional.all(4),
    this.isExpanded = true,
    this.iconSpacing,
    this.disabled = false,
    this.hasShadow = false,
    this.padding = const EdgeInsetsDirectional.symmetric(
      vertical: 16,
      horizontal: 24,
    ),
    this.borderWidth = 1.0,
    this.textStyle,
    this.splashColor = Colors.black12,
  })  : backgroundColor = Colors.white,
        textColor = AppColors.primary,
        disabledTextColor = AppColors.textTertiary,
        disabledBackgroundColor = AppColors.borderSecondary,
        borderRadius = 100,
        fontWeight = FontWeight.w600,
        fontSize = 16,
        loadingColor = AppColors.primary,
        borderColor = AppColors.primary;

  /// Tertiary button - Text-only button with no background or border
  const CustomButton.tertiary({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    super.key,
    this.prefixIcon,
    this.suffixIcon,
    this.outsidePadding = const EdgeInsetsDirectional.all(4),
    this.isExpanded = true,
    this.iconSpacing,
    this.disabled = false,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
  })  : backgroundColor = Colors.transparent,
        textColor = AppColors.primary,
        disabledTextColor = AppColors.textTertiary,
        disabledBackgroundColor = Colors.transparent,
        borderRadius = 100,
        padding = const EdgeInsetsDirectional.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        splashColor = Colors.black12,
        loadingColor = AppColors.primary,
        borderColor = null,
        borderWidth = 0.0,
        textStyle = null,
        hasShadow = false;

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final FontWeight fontWeight;
  final Color splashColor;
  final double fontSize;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? outsidePadding;
  final bool isExpanded;
  final double? iconSpacing;
  final bool disabled;
  final Color? disabledTextColor;
  final Color? disabledBackgroundColor;
  final Color loadingColor;
  final Color? borderColor;
  final double borderWidth;
  final TextStyle? textStyle;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    final effectiveDisabledBackgroundColor =
        disabledBackgroundColor ?? AppColors.primary;
    final effectiveDisabledTextColor =
        disabledTextColor ?? Colors.white.withValues(alpha: 0.5);

    final buttonContent = TextButton(
      onPressed: (isLoading || disabled) ? null : onPressed,
      style: TextButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        backgroundColor:
            disabled ? effectiveDisabledBackgroundColor : backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderColor != null
              ? BorderSide(
                  color: disabled
                      ? borderColor!.withValues(alpha: 0.5)
                      : borderColor!,
                  width: borderWidth,
                )
              : BorderSide.none,
        ),
        splashFactory: InkRipple.splashFactory,
        overlayColor: splashColor,
      ),
      child: Padding(
        padding: padding,
        child: isLoading
            ? SizedBox(
                height: 23,
                width: 23,
                child: LoadingWidget(color: textColor),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    SizedBox(width: iconSpacing ?? 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: textStyle ??
                          context.h2.copyWith(
                            color: disabled
                                ? effectiveDisabledTextColor
                                : textColor,
                            fontWeight: fontWeight,
                            fontSize: fontSize,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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

    final Widget buttonWidget = Padding(
      padding: outsidePadding ?? EdgeInsets.zero,
      child: isExpanded
          ? Row(children: [Expanded(child: buttonContent)])
          : buttonContent,
    );

    if (hasShadow) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 4),
              blurRadius: 15,
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
          ],
        ),
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}
