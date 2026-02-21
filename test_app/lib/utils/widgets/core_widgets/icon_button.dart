import 'package:test_app/exports.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    this.icon,
    this.onPressed,
    this.backgroundColor = Colors.white,
    this.iconColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
    this.borderColor = AppColors.textTertiary,
    this.splashColor = Colors.black12,
    this.outsidePadding = EdgeInsetsDirectional.zero,
    this.iconPadding,
    this.borderWidth = 1,
    this.isLoading = false,
    this.shrinkTargetSize = true,
    super.key,
  });

  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color? iconColor;
  final BorderRadiusGeometry borderRadius;
  final Color borderColor;
  final Color splashColor;
  final Widget? icon;
  final double? iconPadding;
  final EdgeInsetsDirectional outsidePadding;
  final bool isLoading;
  final double borderWidth;
  final bool shrinkTargetSize;

  @override
  Widget build(BuildContext context) {
    final Widget iconButtonWidget = IconButton(
      onPressed: isLoading == true ? null : onPressed,
      icon: isLoading
          ? const LoadingWidget(size: 18)
          : icon ?? const Icon(Icons.arrow_back_ios_new, size: 18),
      color: iconColor,
      style: IconButton.styleFrom(
        tapTargetSize: shrinkTargetSize
            ? MaterialTapTargetSize.shrinkWrap
            : MaterialTapTargetSize.padded,
        padding: EdgeInsetsDirectional.all(iconPadding ?? 8),
        minimumSize: Size.zero,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: borderColor, width: borderWidth),
        ),
      ),
    );

    return Padding(padding: outsidePadding, child: iconButtonWidget);
  }
}
