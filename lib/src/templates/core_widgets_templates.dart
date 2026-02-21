const String appBarTemplate = '''
import 'package:{{project_name}}/exports.dart';

/// Universal round, fixed-size back button for app bars.
/// White circle with black arrow so it stands out from the background.
class AppBarBackButton extends StatelessWidget {
  const AppBarBackButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppBarCircleButton(
      icon: SvgPicture.asset(
        AssetPaths.arrowLeftIcon,
        colorFilter: const ColorFilter.mode(
          AppColors.blackPrimary,
          BlendMode.srcIn,
        ),
      ),
      onPressed: onPressed ?? () => context.pop(),
      backgroundColor: AppColors.white,
    );
  }
}

/// Universal round, fixed-size circle button for app bar leading/actions.
/// Same size ([40]) everywhere for consistency.
class AppBarCircleButton extends StatelessWidget {
  const AppBarCircleButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.backgroundColor,
    this.foregroundColor,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    const double size = 40;
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        style: IconButton.styleFrom(
          minimumSize: Size(size, size),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const CircleBorder(),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
      ),
    );
  }
}

/// Standard padding for app bar leading (wraps [AppBarBackButton] / [AppBarCircleButton]).
const EdgeInsets _appBarLeadingPadding = EdgeInsets.only(
  left: 16,
  bottom: 8,
  top: 8,
);

/// This AppBar follows the consistent pattern used across all screens:
/// - Dark system overlay style
/// - Transparent material
/// - Standardized round, fixed-size leading button (white circle, black arrow)
/// - Consistent title styling
PreferredSizeWidget customAppBar({
  required BuildContext context,
  required String title,
  VoidCallback? onBackPressed,
  List<Widget>? actions,
  bool showBackButton = true,
  double? toolbarHeight,
  Widget? leading,
  Widget? titleWidget,
}) {
  return AppBar(
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    forceMaterialTransparency: true,
    toolbarHeight: toolbarHeight,
    leadingWidth:
        16 + 40,
    leading: showBackButton
        ? (leading ??
            Padding(
              padding: _appBarLeadingPadding,
              child: AppBarBackButton(onPressed: onBackPressed),
            ))
        : null,
    title: titleWidget ??
        Text(
          title,
          style: context.t1.copyWith(fontSize: 16),
        ),
    actions: actions,
  );
}

/// Legacy AppBar function (deprecated - use customAppBar instead)
@Deprecated('Use customAppBar instead')
PreferredSizeWidget legacyCustomAppBar({
  required BuildContext context,
  required String title,
  VoidCallback? leadingAction,
  List<Widget>? actions,
  bool? showBackButton = true,
}) {
  return AppBar(
    backgroundColor: AppColors.white,
    flexibleSpace: Container(color: AppColors.white),
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    forceMaterialTransparency: true,
    centerTitle: false,
    titleSpacing: 0,
    leadingWidth:
        16 + 40,
    leading: (showBackButton ?? false)
        ? Padding(
            padding: _appBarLeadingPadding,
            child: AppBarBackButton(onPressed: leadingAction),
          )
        : null,
    title: Text(
      title,
      style: context.t3.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.blackPrimary,
      ),
    ),
    actionsPadding: const EdgeInsets.symmetric(horizontal: 24),
    actions: actions,
  );
}
''';

const String bottomSheetTemplate = '''
import 'package:{{project_name}}/exports.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({
    required this.title,
    this.imagePath,
    this.imageWidget,
    this.subtitle,
    this.onTap,
    this.buttonOneText,
    this.buttonTwoText,
    this.buttonOneOnTap,
    this.buttonTwoOnTap,
    this.buttonOneColor,
    this.buttonTwoColor,
    this.buttonOneTextColor,
    this.buttonTwoTextColor,
    this.isLoading = false,
    this.body,
    super.key,
  });

  final String title;
  final String? imagePath;
  final Widget? imageWidget;
  final String? subtitle;
  final VoidCallback? onTap;
  final String? buttonOneText;
  final String? buttonTwoText;
  final VoidCallback? buttonOneOnTap;
  final VoidCallback? buttonTwoOnTap;
  final Color? buttonOneColor;
  final Color? buttonTwoColor;
  final Color? buttonOneTextColor;
  final Color? buttonTwoTextColor;
  final bool isLoading;
  final Widget? body;

  static void show({
    required BuildContext context,
    required String title,
    String? imagePath,
    Widget? imageWidget,
    String? subtitle,
    String? buttonOneText,
    String? buttonTwoText,
    VoidCallback? buttonOneOnTap,
    VoidCallback? buttonTwoOnTap,
    Color? buttonOneColor,
    Color? buttonTwoColor,
    Color? buttonOneTextColor,
    Color? buttonTwoTextColor,
    double? height,
    VoidCallback? onTap,
    bool isLoading = false,
    Widget? body,
    bool safeAreaBottom = true,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        minWidth: MediaQuery.of(context).size.width,
      ),
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final keyboardHeight = mediaQuery.viewInsets.bottom;
        final bottomPadding = safeAreaBottom ? mediaQuery.padding.bottom : 0.0;
        final contentHeight = height != null
            ? (mediaQuery.size.height - mediaQuery.viewPadding.top) * height
            : null;
        final totalHeight =
            contentHeight != null ? contentHeight + bottomPadding : null;

        // White background extends to screen bottom; content is inset via SafeArea
        return Padding(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: Container(
            height: totalHeight,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              bottom: safeAreaBottom,
              child: SizedBox(
                height: contentHeight,
                child: GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: CustomBottomSheet(
                    imagePath: imagePath,
                    title: title,
                    subtitle: subtitle,
                    onTap: onTap,
                    isLoading: isLoading,
                    imageWidget: imageWidget,
                    buttonOneText: buttonOneText,
                    buttonTwoText: buttonTwoText,
                    buttonOneOnTap: buttonOneOnTap,
                    buttonTwoOnTap: buttonTwoOnTap,
                    buttonOneColor: buttonOneColor,
                    buttonTwoColor: buttonTwoColor,
                    buttonOneTextColor: buttonOneTextColor,
                    buttonTwoTextColor: buttonTwoTextColor,
                    body: body,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsetsDirectional.all(16),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: body != null ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 64,
                decoration: BoxDecoration(
                  color: AppColors.filterHandleBar,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 16),
              if (imagePath != null) ...[
                SvgPicture.asset(imagePath!, height: 100),
                const SizedBox(height: 24),
              ],
              if (imageWidget != null) ...[
                imageWidget!,
                const SizedBox(height: 20),
              ],
              Text(
                title,
                style: context.t1,
              ),
              if (body != null) ...[
                Expanded(child: body!),
                if (buttonOneText != null || buttonTwoText != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (buttonOneText != null)
                        Expanded(
                          child: CustomButton(
                            padding: const EdgeInsetsDirectional.symmetric(
                              vertical: 12,
                            ),
                            text: buttonOneText!,
                            onPressed: buttonOneOnTap,
                            isLoading: isLoading,
                            borderColor: buttonOneTextColor,
                            textColor: buttonOneTextColor ?? AppColors.white,
                            backgroundColor:
                                buttonOneColor ?? AppColors.blackPrimary,
                          ),
                        ),
                      if (buttonOneText != null && buttonTwoText != null)
                        const SizedBox(width: 16),
                      if (buttonTwoText != null)
                        Expanded(
                          child: CustomButton(
                            padding: const EdgeInsetsDirectional.symmetric(
                              vertical: 12,
                            ),
                            text: buttonTwoText!,
                            textColor: buttonTwoTextColor ?? AppColors.white,
                            onPressed: buttonTwoOnTap,
                            isLoading: isLoading,
                            backgroundColor: buttonTwoColor ?? AppColors.red,
                          ),
                        ),
                    ],
                  ),
                ],
              ] else ...[
                const SizedBox(height: 12),
                if (subtitle != null) ...[
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: SingleChildScrollView(
                      child: Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: context.b2,
                        softWrap: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: CustomButton(
                        padding: const EdgeInsetsDirectional.symmetric(
                          vertical: 12,
                        ),
                        text: buttonOneText ?? '',
                        onPressed: buttonOneOnTap,
                        isLoading: isLoading,
                        borderColor: buttonOneTextColor,
                        textColor: buttonOneTextColor ?? AppColors.white,
                        backgroundColor:
                            buttonOneColor ?? AppColors.blackPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        padding: const EdgeInsetsDirectional.symmetric(
                          vertical: 12,
                        ),
                        text: buttonTwoText ?? '',
                        textColor: buttonTwoTextColor ?? AppColors.white,
                        onPressed: buttonTwoOnTap,
                        isLoading: isLoading,
                        backgroundColor: buttonTwoColor ?? AppColors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
    );
  }
}
''';

const String bulletPointItemTemplate = '''
import 'package:{{project_name}}/exports.dart';

class BulletPointItem extends StatelessWidget {
  const BulletPointItem({
    required this.text,
    super.key,
    this.textStyle,
    this.bulletCharacter = '•',
    this.bulletSize = 16.0,
    this.bulletColor,
    this.spacing = 8.0,
    this.padding = const EdgeInsetsDirectional.only(bottom: 8),
  });

  final String text;
  final TextStyle? textStyle;
  final String bulletCharacter;
  final double bulletSize;
  final Color? bulletColor;
  final double spacing;
  final EdgeInsetsDirectional padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bulletCharacter,
            style: TextStyle(
              fontSize: bulletSize,
              color: bulletColor ?? AppColors.blackPrimary,
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Text(
              text,
              style:
                  textStyle ??
                  context.b2.copyWith(color: AppColors.blackPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
''';

const String buttonTemplate = '''
import 'package:{{project_name}}/exports.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    super.key,
    this.backgroundColor = AppColors.blackPrimary,
    this.textColor = AppColors.white,
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
    this.loadingColor = AppColors.white,
    this.borderColor,
    this.borderWidth = 1.0,
    this.textStyle,
    this.hasShadow = false,
  }) : padding = padding ?? EdgeInsetsDirectional.symmetric(
          vertical: 12,
          horizontal: 24,
        ),
        outsidePadding = outsidePadding ?? EdgeInsetsDirectional.all(4);

  /// Primary button - Black background with white text
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
  })  : backgroundColor = AppColors.blackPrimary,
        textColor = AppColors.white,
        disabledTextColor = AppColors.buttonDisabledText,
        disabledBackgroundColor = AppColors.textTertiary,
        borderRadius = 100,
        padding = EdgeInsetsDirectional.symmetric(
          vertical: 16,
          horizontal: 24,
        ),
        fontWeight = FontWeight.w600,
        splashColor = Colors.black12,
        fontSize = 16,
        loadingColor = AppColors.white,
        borderColor = AppColors.blackPrimary,
        borderWidth = 1.0,
        textStyle = null,
        outsidePadding = outsidePadding ?? EdgeInsetsDirectional.all(4);

  /// Secondary button - White background with black text and border
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
  })  : backgroundColor = AppColors.white,
        textColor = AppColors.blackPrimary,
        disabledTextColor = AppColors.textTertiary,
        disabledBackgroundColor = AppColors.backgroundTertiary,
        borderRadius = 100,
        fontWeight = FontWeight.w600,
        fontSize = 16,
        loadingColor = AppColors.blackPrimary,
        borderColor = AppColors.blackPrimary;

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
        textColor = AppColors.blackPrimary,
        disabledTextColor = AppColors.textTertiary,
        disabledBackgroundColor = Colors.transparent,
        borderRadius = 100,
        padding = const EdgeInsetsDirectional.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        splashColor = Colors.black12,
        loadingColor = AppColors.blackPrimary,
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
        disabledBackgroundColor ?? AppColors.blackPrimary;
    final effectiveDisabledTextColor =
        disabledTextColor ?? AppColors.white.withValues(alpha: 0.5);

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
              color: AppColors.blackPrimary.withValues(alpha: 0.05),
            ),
          ],
        ),
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}
''';

const String cachedNetworkImageTemplate = '''
import 'package:cached_network_image/cached_network_image.dart';
import 'package:{{project_name}}/constants/constants.dart';
import 'package:{{project_name}}/exports.dart';
import 'package:shimmer/shimmer.dart';

class CustomCachedImageWidget extends StatelessWidget {
  const CustomCachedImageWidget({
    required this.imageUrl,
    this.placeHolder = AppConstants.productPlaceHolder,
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.compactPlaceholder = false,
    this.placeholderAspectRatio,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final String placeHolder;
  final BorderRadiusGeometry? borderRadius;
  final BoxFit fit;
  /// When true, placeholder/shimmer is centered and constrained (e.g. for full-screen
  /// viewers) so the background stays visible instead of shimmer filling the screen.
  final bool compactPlaceholder;
  /// When set, placeholder height = width / value (e.g. 4/3 gives shorter placeholder).
  /// Only used when [compactPlaceholder] is false and [width] is non-null.
  final double? placeholderAspectRatio;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl.trim();
    if (trimmedUrl.isEmpty) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(0),
        child: Container(
          width: width,
          height: height,
          color: AppColors.backgroundTertiary,
          child: Image.asset(
            placeHolder,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                color: AppColors.backgroundTertiary,
                child: Icon(
                  Icons.image_outlined,
                  size: (width != null && height != null)
                      ? (width! < height! ? width! * 0.5 : height! * 0.5)
                      : 24,
                  color: AppColors.textTertiary,
                ),
              );
            },
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(0),
      child: CachedNetworkImage(
        imageUrl: trimmedUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: AppColors.backgroundTertiary,
          highlightColor: AppColors.white,
          child: compactPlaceholder
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth > 0
                        ? constraints.maxWidth * 0.9
                        : 280.0;
                    final h = w * (4 / 3);
                    return Center(
                      child: Container(
                        width: w,
                        height: h,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundTertiary,
                          borderRadius:
                              borderRadius ?? BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                )
              : placeholderAspectRatio != null
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final h = w / placeholderAspectRatio!;
                        return SizedBox(
                          width: w,
                          height: h,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.backgroundTertiary,
                              borderRadius:
                                  borderRadius ?? BorderRadius.zero,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundTertiary,
                        borderRadius: borderRadius ?? BorderRadius.zero,
                      ),
                    ),
        ),
        errorWidget: (context, url, error) =>
            Image.asset(placeHolder, width: width, height: height, fit: fit),
      ),
    );
  }
}
''';

const String checkboxTemplate = '''
import 'package:{{project_name}}/exports.dart';

class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
    this.borderColor,
    this.checkColor,
    this.size = 20,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final Color? borderColor;
  final Color? checkColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: value ? AppColors.white : Colors.transparent,
          border: Border.all(
            color: borderColor ?? AppColors.blackPrimary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: value
            ? Padding(
                padding: const EdgeInsets.all(3),
                child: SvgPicture.asset(
                  AssetPaths.tickIcon,
                  colorFilter: const ColorFilter.mode(
                    AppColors.blackPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
''';

const String chipsTemplate = '''
import 'package:{{project_name}}/exports.dart';

class CustomChip extends StatelessWidget {
  const CustomChip({
    required this.text,
    required this.onTap,
    this.backgroundColor = AppColors.blackPrimary,
    this.fontColor = AppColors.blackPrimary,
    this.isSelected = false,
    this.fontStyle,
    this.padding,
    super.key,
  });

  final bool isSelected;
  final String text;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color fontColor;
  final TextStyle? fontStyle;
  final EdgeInsetsDirectional? padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? backgroundColor : backgroundColor,
          borderRadius: BorderRadius.circular(100),
        ),
        padding:
            padding ??
            const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          text,
          style:
              fontStyle ?? context.t3.copyWith(fontSize: 12, color: fontColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
''';

const String confirmationDialogTemplate = '''
import 'package:{{project_name}}/exports.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    required this.title,
    required this.subtitle,
    required this.confirmButtonText,
    required this.onConfirm,
    this.cancelButtonText = 'Cancel',
    this.onCancel,
    this.isLoading = false,
    this.isDanger = false,
    this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final String confirmButtonText;
  final String cancelButtonText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;
  final bool isDanger;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 8),
              blurRadius: 32,
              color: AppColors.blackPrimary.withValues(alpha: 0.1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDanger
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.blackPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Center(child: icon),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                title,
                style: context.t3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                subtitle,
                style: context.b2.copyWith(
                  color: AppColors.blackPrimary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  CustomButton(
                    text: confirmButtonText,
                    onPressed: isLoading ? null : onConfirm,
                    isLoading: isLoading,
                    backgroundColor: isDanger
                        ? AppColors.error
                        : AppColors.blackPrimary,
                    padding: const EdgeInsetsDirectional.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    hasShadow: true,
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: cancelButtonText,
                    onPressed: isLoading
                        ? null
                        : (onCancel ?? () => context.pop()),
                    textColor: AppColors.blackPrimary,
                    backgroundColor: AppColors.white,
                    padding: const EdgeInsetsDirectional.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmationDialogHelper {
  static void show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String confirmButtonText,
    required VoidCallback onConfirm,
    String cancelButtonText = 'Cancel',
    VoidCallback? onCancel,
    bool isLoading = false,
    bool isDanger = false,
    Widget? icon,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: !isLoading,
      barrierColor: AppColors.blackPrimary.withValues(alpha: 0.6),
      builder: (context) => ConfirmationDialog(
        title: title,
        subtitle: subtitle,
        confirmButtonText: confirmButtonText,
        cancelButtonText: cancelButtonText,
        onConfirm: () {
          context.pop();
          onConfirm();
        },
        onCancel: onCancel,
        isLoading: isLoading,
        isDanger: isDanger,
        icon: icon,
      ),
    );
  }
}
''';

const String customDatePickerTemplate = '''
import 'package:{{project_name}}/exports.dart';
import 'package:{{project_name}}/utils/helpers/datetime_helper.dart';

class CustomDatePicker extends StatelessWidget {
  const CustomDatePicker({
    required this.labelText,
    required this.onDateChanged,
    this.selectedDate,
    this.hintText,
    this.iconPath,
    this.enabled = true,
    this.validator,
    this.showValidation = false,
    this.firstDate,
    this.lastDate,
    super.key,
  });

  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DatePickerMode initialDatePickerMode = DatePickerMode.day,
  }) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: initialDatePickerMode,
      builder: (context, child) {
        return Theme(data: _getCustomDatePickerTheme(context), child: child!);
      },
    );
  }

  static ThemeData _getCustomDatePickerTheme(BuildContext context) {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: AppColors.blackPrimary,
        onSurface: AppColors.blackPrimary,
      ),
      datePickerTheme: DatePickerThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        dividerColor: AppColors.blackPrimary,
      ),
      textTheme: Theme.of(context).textTheme.copyWith(
            labelLarge: context.b1,
            headlineLarge: context.t3.copyWith(fontWeight: FontWeight.w600),
            headlineSmall: context.b1,
            bodyLarge: context.b2,
            titleSmall: context.b1,
          ),
    );
  }

  final String labelText;
  final DateTime? selectedDate;
  final void Function(DateTime) onDateChanged;
  final String? hintText;
  final String? iconPath;
  final bool enabled;
  final String? Function(String?)? validator;
  final bool showValidation;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final dateString = selectedDate?.toIso8601String();
    final hasError =
        showValidation && validator != null && validator!(dateString) != null;

    final displayText = selectedDate != null
        ? DateTimeHelper.formatDateOfBirth(selectedDate!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: context.b1.copyWith(color: AppColors.blackPrimary),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: enabled
              ? () async {
                  final pickedDate = await CustomDatePicker.show(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: firstDate ?? DateTime(1900),
                    lastDate: lastDate ?? DateTime.now(),
                  );
                  if (pickedDate != null) {
                    onDateChanged(pickedDate);
                  }
                }
              : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: enabled ? AppColors.white : AppColors.textFieldBackground,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: enabled
                    ? (hasError ? AppColors.error : AppColors.textTertiary)
                    : AppColors.textTertiary,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText ?? (hintText ?? labelText),
                    style: displayText != null
                        ? context.b2
                        : context.b2.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                if (iconPath != null) ...[
                  SvgPicture.asset(
                    iconPath!,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showValidation &&
            validator != null &&
            validator!(dateString) != null) ...[
          const SizedBox(height: 6),
          Text(
            validator!(dateString)!,
            style: context.b3.copyWith(
              color: AppColors.error,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}
''';

const String customDropdownTemplate = '''
import 'package:{{project_name}}/exports.dart';

class CustomDropdown extends StatelessWidget {
  const CustomDropdown({
    required this.labelText,
    required this.options,
    required this.onChanged,
    this.selectedValue,
    this.hintText,
    this.prefixIconPath,
    this.borderRadius = 100.0,
    this.maxHeight = 200.0,
    this.enabled = true,
    this.validator,
    this.showValidation = false,
    this.onTap,
    super.key,
  });

  final String labelText;
  final List<String> options;
  final void Function(String) onChanged;
  final String? selectedValue;
  final String? hintText;
  final String? prefixIconPath;
  final double borderRadius;
  final double maxHeight;
  final bool enabled;
  final String? Function(String?)? validator;
  final bool showValidation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: selectedValue,
      validator: validator,
      builder: (FormFieldState<String> field) {
        return BlocProvider(
          create: (_) => CustomDropdownCubit(),
          child: _CustomDropdownContent(
            labelText: labelText,
            options: options,
            onChanged: (value) {
              field.didChange(value);
              onChanged(value);
            },
            selectedValue: selectedValue,
            hintText: hintText,
            prefixIconPath: prefixIconPath,
            borderRadius: borderRadius,
            maxHeight: maxHeight,
            enabled: enabled,
            validator: validator,
            showValidation: showValidation,
            onTap: onTap,
            formFieldState: field,
          ),
        );
      },
    );
  }
}

class _CustomDropdownContent extends StatefulWidget {
  const _CustomDropdownContent({
    required this.labelText,
    required this.options,
    required this.onChanged,
    this.selectedValue,
    this.hintText,
    this.prefixIconPath,
    this.borderRadius = 100.0,
    this.maxHeight = 200.0,
    this.enabled = true,
    this.validator,
    this.showValidation = false,
    this.onTap,
    this.formFieldState,
  });

  final String labelText;
  final List<String> options;
  final void Function(String) onChanged;
  final String? selectedValue;
  final String? hintText;
  final String? prefixIconPath;
  final double borderRadius;
  final double maxHeight;
  final bool enabled;
  final String? Function(String?)? validator;
  final bool showValidation;
  final VoidCallback? onTap;
  final FormFieldState<String>? formFieldState;

  @override
  State<_CustomDropdownContent> createState() => _CustomDropdownContentState();
}

class _CustomDropdownContentState extends State<_CustomDropdownContent> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _dropdownKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);

    // Initial validation if showValidation is true
    if (widget.showValidation && widget.validator != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _validateField(context.read<CustomDropdownCubit>());
        }
      });
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!mounted) return;
    
    if (!_focusNode.hasFocus) {
      // Close dropdown when focus is lost (tapping outside)
      try {
        if (mounted) {
          context.read<CustomDropdownCubit>().closeDropdown();
        }
      } catch (e) {
        // Widget might be disposed, ignore
      }
    }
  }

  void _validateField(CustomDropdownCubit cubit) {
    if (!mounted) return;
    
    try {
      if (widget.validator != null && widget.showValidation) {
        final error = widget.validator!(widget.selectedValue);
        if (mounted) {
          cubit.setError(error);
        }
      } else {
        if (mounted) {
          cubit.clearError();
        }
      }
    } catch (e) {
      // Widget might be disposed, ignore
    }
  }

  void _selectOption(CustomDropdownCubit cubit, String option) {
    if (!mounted) return;
    
    try {
      // Call the onChanged callback first
      widget.onChanged(option);
      
      // Then close dropdown and validate, but only if still mounted
      if (mounted) {
        cubit.closeDropdown();
        _validateField(cubit);
      }
    } catch (e) {
      // Widget might be disposed during callback, ignore
    }
  }

  @override
  void didUpdateWidget(covariant _CustomDropdownContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Validate when showValidation changes from false to true
    if (widget.showValidation && !oldWidget.showValidation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _validateField(context.read<CustomDropdownCubit>());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomDropdownCubit, CustomDropdownState>(
      builder: (context, state) {
        final cubit = context.read<CustomDropdownCubit>();
        final hasValue =
            widget.selectedValue != null && widget.selectedValue!.isNotEmpty;
        final hasError = state.errorText != null;

        final borderColor = !widget.enabled
            ? AppColors.textTertiary
            : hasError
                ? AppColors.error
                : AppColors.textTertiary;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.labelText,
              style: context.b1.copyWith(color: AppColors.blackPrimary),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: widget.enabled
                  ? () {
                      widget.onTap?.call();
                      // Always open the dropdown when tapped, regardless of current state
                      if (!state.isOpen) {
                        cubit.openDropdown();
                        _focusNode.requestFocus();
                      }
                    }
                  : null,
              child: Focus(
                focusNode: _focusNode,
                child: Container(
                  key: _dropdownKey,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                      state.isOpen ? 16 : widget.borderRadius,
                    ),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            if (widget.prefixIconPath != null) ...[
                              SvgPicture.asset(
                                widget.prefixIconPath!,
                                width: 16,
                                colorFilter: ColorFilter.mode(
                                  widget.enabled
                                      ? AppColors.blackPrimary
                                      : AppColors.textTertiary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Text(
                                hasValue
                                    ? widget.selectedValue!
                                    : (widget.hintText ?? widget.labelText),
                                style: hasValue
                                    ? context.b2
                                    : context.b2.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                              ),
                            ),
                            AnimatedRotation(
                              turns: state.isOpen ? 0.5 : 0,
                              duration: Duration(milliseconds: 200),
                              child: SvgPicture.asset(
                                AssetPaths.dropdownArrowIcon,
                                colorFilter: ColorFilter.mode(
                                  widget.enabled
                                      ? AppColors.blackPrimary
                                      : AppColors.textTertiary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (state.isOpen && widget.options.isNotEmpty) ...[
                        const Divider(
                          color: AppColors.textTertiary,
                          height: 1,
                          thickness: 1,
                        ),
                        Container(
                          constraints:
                              BoxConstraints(maxHeight: widget.maxHeight),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const ClampingScrollPhysics(),
                            itemCount: widget.options.length,
                            itemBuilder: (context, index) {
                              final option = widget.options[index];
                              final isSelected = widget.selectedValue == option;

                              return InkWell(
                                onTap: () => _selectOption(cubit, option),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding:
                                      const EdgeInsetsDirectional.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: context.b2.copyWith(
                                            color: AppColors.blackPrimary,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: AppColors.blackPrimary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: SvgPicture.asset(
                                            AssetPaths.tickIcon,
                                            width: 14,
                                            height: 14,
                                            colorFilter: const ColorFilter.mode(
                                              AppColors.white,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Always reserve fixed space for error when field has validator so layout never shifts
            if (widget.validator != null)
              SizedBox(
                height: 24,
                child: widget.showValidation && hasError && state.errorText != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 6, left: 12),
                        child: Text(
                          state.errorText!,
                          style: context.b3.copyWith(
                            color: AppColors.error,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        );
      },
    );
  }
}
''';

const String customDropdownCubitTemplate = '''
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomDropdownState {
  const CustomDropdownState({
    this.isOpen = false,
    this.errorText,
  });

  final bool isOpen;
  final String? errorText;

  CustomDropdownState copyWith({
    bool? isOpen,
    String? errorText,
    bool clearError = false,
  }) {
    return CustomDropdownState(
      isOpen: isOpen ?? this.isOpen,
      errorText: clearError ? null : (errorText ?? this.errorText),
    );
  }
}

class CustomDropdownCubit extends Cubit<CustomDropdownState> {
  CustomDropdownCubit() : super(const CustomDropdownState());

  void toggleDropdown() {
    emit(state.copyWith(isOpen: !state.isOpen));
  }

  void closeDropdown() {
    emit(state.copyWith(isOpen: false));
  }

  void openDropdown() {
    emit(state.copyWith(isOpen: true));
  }

  void setError(String? error) {
    emit(state.copyWith(errorText: error, clearError: error == null));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
''';

const String customSlidingTabTemplate = '''
import 'package:{{project_name}}/exports.dart';

class CustomSlidingTab extends StatefulWidget {
  CustomSlidingTab({
    required this.tabs,
    required this.onTabChanged,
    this.selectedIndex = 0,
    this.height = 40,
    this.backgroundColor,
    this.selectedColor,
    this.borderRadius = 12,
    this.textStyle,
    this.selectedTextStyle,
    Duration? animationDuration,
    super.key,
  }) : animationDuration = animationDuration ?? Duration(milliseconds: 300);

  final List<SlidingTabItem> tabs;
  final void Function(int) onTabChanged;
  final Duration animationDuration;
  final int selectedIndex;
  final double height;
  final Color? backgroundColor;
  final Color? selectedColor;
  final double borderRadius;
  final TextStyle? textStyle;
  final TextStyle? selectedTextStyle;

  @override
  State<CustomSlidingTab> createState() => _CustomSlidingTabState();
}

class _CustomSlidingTabState extends State<CustomSlidingTab> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(CustomSlidingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _selectedIndex = widget.selectedIndex;
    }
  }

  void _onTabTap(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      widget.onTabChanged(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.blackPrimary,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: widget.animationDuration,
            alignment: Alignment(
              -1.0 + (2.0 * _selectedIndex / (widget.tabs.length - 1)),
              0,
            ),
            child: Container(
              width:
                  (MediaQuery.of(context).size.width -
                      (MediaQuery.of(context).size.width * 0.2)) /
                  widget.tabs.length,
              height: widget.height,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: widget.selectedColor ?? AppColors.blackPrimary,
                borderRadius: BorderRadius.circular(widget.borderRadius - 2),
              ),
            ),
          ),
          Row(
            children: List.generate(widget.tabs.length, (index) {
              final isSelected = _selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => _onTabTap(index),
                  child: Container(
                    height: widget.height,
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: widget.animationDuration,
                      style: isSelected
                          ? (widget.selectedTextStyle ??
                                (widget.textStyle ?? context.b1).copyWith(
                                  color: AppColors.white,
                                ))
                          : (widget.textStyle ?? context.b1).copyWith(
                              color: AppColors.blackPrimary,
                            ),
                      child: Text(
                        widget.tabs[index].label,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class SlidingTabItem {
  const SlidingTabItem({required this.label, this.value});

  final String label;
  final dynamic value;

  @override
  String toString() => 'SlidingTabItem(label: \$label, value: \$value)';
}
''';

const String datePickerTemplate = '''
import 'package:flutter/cupertino.dart';
import 'package:{{project_name}}/exports.dart';

enum RMBDatePickerMode {
  past, // Can't pick dates after now
  future, // Can't pick dates before now
}

class RMBDatePicker extends StatefulWidget {
  const RMBDatePicker({
    required this.onDateSelected,
    this.mode = RMBDatePickerMode.past,
    super.key,
    this.firstDate,
    this.lastDate,
    this.initialDate,
  });

  final dynamic Function(DateTime) onDateSelected;
  final RMBDatePickerMode mode;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;

  @override
  State<RMBDatePicker> createState() => _RMBDatePickerState();
}

class _RMBDatePickerState extends State<RMBDatePicker> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDate = widget.mode == RMBDatePickerMode.past
        ? widget.firstDate ?? DateTime(1900)
        : now;
    final lastDate = widget.mode == RMBDatePickerMode.past
        ? now
        : widget.lastDate ?? DateTime(2100);

    final initialDate = widget.initialDate ?? now;
    final validInitialDate = initialDate.isBefore(firstDate)
        ? firstDate
        : initialDate.isAfter(lastDate)
        ? lastDate
        : initialDate;

    return SizedBox(
      height: 200,
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: validInitialDate,
        minimumDate: firstDate,
        maximumDate: lastDate,
        onDateTimeChanged: widget.onDateSelected,
        backgroundColor: AppColors.white,
      ),
    );
  }
}
''';

const String dialogTemplate = '''
// import 'dart:io';

// import 'package:rentmebeach/core/permissions/permission_manager.dart';
// import 'package:rentmebeach/exports.dart';

// class CustomDialog {
//   static void showOpenSettingsDialog({
//     required BuildContext context,
//     required String title,
//   }) {
//     showAdaptiveDialog<dynamic>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: AppColors.white,
//           title: Text(
//             title,
//             style: context.b1,
//             textAlign: TextAlign.center,
//           ),
//           actions: [
//             rentmebeachButton(
//               text: 'Open Settings',
//               onPressed: () async {
//                 await PermissionManager.openAppSettingsPage();
//               },
//               isLoading: false,
//             ),
//           ],
//         );
//       },
//     );
//   }

//   static void showLogoutDialog({
//     required BuildContext context,
//     required String title,
//     required String message,
//     required String confirmText,
//     required VoidCallback onConfirm,
//   }) {
//     showDialog<dynamic>(
//       context: context,
//       barrierColor: AppColors.black.withValues(alpha: 0.7),
//       builder: (context) {
//         return AlertDialog(
//           insetPadding: const EdgeInsets.all(22),
//           actionsPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
//           contentPadding: const EdgeInsetsDirectional.all(16),
//           titlePadding: const EdgeInsetsDirectional.only(top: 16),
//           buttonPadding: const EdgeInsetsDirectional.all(0),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           backgroundColor: AppColors.white,
//           title: Text(
//             title,
//             style: context.h2.copyWith(
//               fontWeight: FontWeight.w800,
//               fontSize: 22,
//               color: AppColors.textPrimary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           content: Text(
//             message,
//             style: context.b1.copyWith(
//               color: AppColors.textPrimary,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           actionsAlignment: MainAxisAlignment.center,
//           actions: [
//             // Confirm Button
//             rentmebeachButton(
//               textStyle: context.b2.copyWith(
//                 color: AppColors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//               ),
//               text: confirmText,
//               onPressed: () {
//                 onConfirm();
//               },
//               backgroundColor: AppColors.activeDetailsProgressBar,
//               isLoading: false,
//             ),
//             const SizedBox(height: 8),
//           ],
//         );
//       },
//     );
//   }

//   static void showLoadingDialog({
//     required BuildContext context,
//   }) {
//     showDialog<dynamic>(
//       context: context,
//       barrierColor: AppColors.black.withValues(alpha: 0.7),
//       builder: (context) {
//         return const PopScope(
//           canPop: false,
//           child: Center(
//             child: LoadingWidget(),
//           ),
//         );
//       },
//     );
//   }

//   static void showPermissionDialog({
//     required BuildContext context,
//     required String title,
//     required String message,
//   }) {
//     showDialog<dynamic>(
//       barrierDismissible: false,
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//       ),
//     );
//   }

//   static void showFullImage({
//     required BuildContext context,
//     required File imageFile,
//   }) {
//     showDialog<dynamic>(
//       context: context,
//       barrierColor: AppColors.black.withValues(alpha: 0.7),
//       builder: (context) {
//         return Stack(
//           children: [
//             Image.file(
//               imageFile,
//               width: MediaQuery.sizeOf(context).width,
//               height: MediaQuery.sizeOf(context).height,
//               fit: BoxFit.fitWidth,
//             ),
//             Positioned(
//               top: 10,
//               right: 10,
//               child: GestureDetector(
//                 onTap: context.pop,
//                 child: const Icon(
//                   Icons.highlight_remove,
//                   size: 45,
//                   color: Colors.red,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   static void showConfirmationDialog({
//     required BuildContext context,
//     required String title,
//     required String message,
//     required String confirmText,
//     required VoidCallback onConfirm,
//     String cancelText = 'Cancel',
//   }) {
//     showDialog<dynamic>(
//       context: context,
//       barrierColor: AppColors.black.withValues(alpha: 0.7),
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           backgroundColor: Colors.white,
//           title: Text(
//             title,
//             style: context.h2.copyWith(
//               fontWeight: FontWeight.w600,
//               color: AppColors.black,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           content: Text(
//             message,
//             style: context.b1.copyWith(
//               color: AppColors.textSecondary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           actionsAlignment: MainAxisAlignment.center,
//           actions: [
//             // Confirm Button
//             rentmebeachButton(
//               text: confirmText,
//               onPressed: () {
//                 Navigator.pop(context); // Close the dialog
//                 onConfirm(); // Execute the confirm action
//               },
//               backgroundColor: Colors.redAccent,
//               isLoading: false,
//             ),
//             const SizedBox(height: 8),
//             // Cancel Button
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context); // Close the dialog
//               },
//               child: Text(
//                 cancelText,
//                 style: context.b2.copyWith(
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   static void showActionDialog({
//     required String svgAssetPath,
//     required BuildContext context,
//     required String title,
//     required String message,
//     required String confirmText,
//     required VoidCallback onConfirm,
//     String cancelText = 'Cancel',
//     bool isLoading = false,
//     bool isDanger = false,
//   }) {
//     showDialog<dynamic>(
//       context: context,
//       barrierDismissible: !isLoading,
//       barrierColor: AppColors.black.withValues(alpha: 0.7),
//       builder: (context) {
//         return Dialog(
//           insetPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 24,
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.circular(30),
//             ),
//             padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SvgPicture.asset(
//                   svgAssetPath,
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   title,
//                   style: context.h2.copyWith(
//                     color: AppColors.textPrimary,
//                     fontWeight: FontWeight.w800,
//                     fontSize: 22,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   textAlign: TextAlign.center,
//                   message,
//                   style: context.b1.copyWith(
//                     color: AppColors.textSecondary,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 Flexible(
//                   child: rentmebeachButton(
//                     text: confirmText,
//                     onPressed: isLoading ? null : onConfirm,
//                     isLoading: isLoading,
//                     backgroundColor: isDanger
//                         ? AppColors.redPrimary
//                         : AppColors.primaryColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
''';

const String dropdownTemplate = '''
// import 'dart:developer';

// import 'package:google_fonts/google_fonts.dart';
// import 'package:activ/exports.dart';

// class ActivDropDown extends StatefulWidget {
//   const ActivDropDown({
//     required this.labelText,
//     required this.dataLoader,
//     required this.displayKey,
//     required this.controller,
//     this.initialValue,
//     this.prefixPath,
//     this.onSelected,
//     this.onFieldTap,
//     this.hintText,
//     super.key,
//   });

//   final String? initialValue;
//   final String labelText;
//   final Future<List<Map<String, dynamic>>> Function() dataLoader;
//   final String displayKey;
//   final void Function(Map<String, dynamic>)? onSelected;
//   final TextEditingController controller;
//   final String? prefixPath;
//   final void Function()? onFieldTap;
//   final String? hintText;

//   @override
//   State<ActivDropDown> createState() => _ActivDropDownState();
// }

// class _ActivDropDownState extends State<ActivDropDown> {
//   bool _isOpen = false;
//   List<Map<String, dynamic>>? _cachedData;
//   List<Map<String, dynamic>> _filteredData = [];

//   bool _isLoading = false;
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _focusNode = FocusNode();
//   final ScrollController _scrollController = ScrollController();
//   bool _valueChanged = false;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.initialValue != null) {
//       widget.controller.text = widget.initialValue!;
//       _searchController.text = widget.initialValue!;
//       _valueChanged = false;
//     }

//     _focusNode.addListener(_onFocusChange);
//   }

//   @override
//   void didUpdateWidget(covariant ActivDropDown oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (widget.controller.text != _searchController.text) {
//       _searchController.text = widget.controller.text;
//     }
//   }

//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }

//   void _onFocusChange() {
//     setState(() {});
//   }

//   void _filterData() {
//     if (_cachedData == null) return;
//     final query = _searchController.text.toLowerCase();

//     setState(() {
//       _filteredData = _cachedData!.where((item) {
//         final value = item[widget.displayKey];
//         return value is String && value.toLowerCase().contains(query);
//       }).toList();
//     });
//   }

//   Future<void> _loadData() async {
//     if (_cachedData != null) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final data = await widget.dataLoader();
//       _cachedData = data;
//       _filteredData = List.from(data);
//     } catch (e) {
//       log('Error loading data: \$e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _selectItem(Map<String, dynamic> item) {
//     setState(() {
//       widget.controller.text = item[widget.displayKey] as String;
//       _searchController.text = item[widget.displayKey] as String;
//       _isOpen = false;
//       _valueChanged = true;
//     });
//     if (widget.onSelected != null) {
//       widget.onSelected!(item);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final hasText = widget.controller.text.isNotEmpty;
//     final isFocused = _focusNode.hasFocus;
//     final setEnabledColor = isFocused || hasText;

//     final borderColor =
//         _valueChanged ? AppColors.primaryBlue : AppColors.disabled;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           widget.labelText,
//           style: context.b1.copyWith(
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: () async {
//             setState(() {
//               _isOpen = !_isOpen;
//             });
//             if (_isOpen) {
//               _focusNode.requestFocus();
//               await _loadData();
//             } else {
//               _focusNode.unfocus();
//               _searchController.clear();
//             }
//           },
//           child: Container(
//             height: _isOpen ? 250 : 50,
//             decoration: BoxDecoration(
//               color: _isOpen ? AppColors.white : AppColors.greyShade5,
//               borderRadius: BorderRadius.circular(16),
//               border: _isOpen
//                   ? Border.all(
//                       color: setEnabledColor ? borderColor : AppColors.disabled,
//                     )
//                   : null,
//             ),
//             child: Padding(
//               padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       if (widget.prefixPath != null) ...[
//                         SvgPicture.asset(
//                           widget.prefixPath ?? '',
//                           colorFilter: setEnabledColor
//                               ? const ColorFilter.mode(
//                                   AppColors.primaryBlue,
//                                   BlendMode.srcIn,
//                                 )
//                               : null,
//                         ),
//                       ],
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: TextField(
//                           controller: _searchController,
//                           focusNode: _focusNode,
//                           cursorWidth: 1,
//                           decoration: InputDecoration(
//                             hintText: widget.hintText ?? widget.labelText,
//                             hintStyle: GoogleFonts.urbanist(
//                               color: AppColors.disabled,
//                             ),
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsetsDirectional.zero,
//                           ),
//                           onChanged: (value) {
//                             _filterData();
//                           },
//                           style: GoogleFonts.urbanist(
//                             color: AppColors.black,
//                           ),
//                           onTap: () async {
//                             setState(() {
//                               _isOpen = !_isOpen;
//                             });
//                             if (_isOpen) {
//                               _focusNode.requestFocus();
//                               await _loadData();
//                             } else {
//                               _focusNode.unfocus();
//                             }
//                             widget.onFieldTap?.call();
//                           },
//                         ),
//                       ),
//                       SvgPicture.asset(
//                         _isOpen
//                             ? AssetPaths.arrowUpIcon
//                             : AssetPaths.arrowDownIcon,
//                         colorFilter: setEnabledColor
//                             ? const ColorFilter.mode(
//                                 AppColors.primaryBlue,
//                                 BlendMode.srcIn,
//                               )
//                             : null,
//                       ),
//                     ],
//                   ),
//                   if (_isOpen && _filteredData.isNotEmpty) ...[
//                     const Divider(
//                       color: AppColors.textFieldBorder,
//                       thickness: 1,
//                       height: 1,
//                     ),
//                     if (_isLoading)
//                       const Padding(
//                         padding: EdgeInsetsDirectional.only(top: 80),
//                         child: LoadingWidget(),
//                       )
//                     else
//                       Expanded(
//                         child: RawScrollbar(
//                           thumbColor: AppColors.textFieldBorder,
//                           radius: const Radius.circular(50),
//                           thumbVisibility: true,
//                           mainAxisMargin: 8,
//                           controller: _scrollController,
//                           child: ListView.builder(
//                             physics: const AlwaysScrollableScrollPhysics(),
//                             controller: _scrollController,
//                             itemCount: _filteredData.length,
//                             itemBuilder: (context, index) {
//                               final item = _filteredData[index];
//                               return DropdownRow(
//                                 dropdownText: item[widget.displayKey] as String,
//                                 isSelected: widget.controller.text ==
//                                     item[widget.displayKey]!,
//                                 onTap: () {
//                                   _selectItem(item);
//                                   _focusNode.unfocus();
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
''';

const String dropdownRowTemplate = '''
// import 'package:rentmebeach/exports.dart';

// class DropdownRow extends StatelessWidget {
//   const DropdownRow({
//     required this.dropdownText,
//     required this.isSelected,
//     required this.onTap,
//     super.key,
//   });

//   final String dropdownText;
//   final bool isSelected;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
//         child: Container(
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? AppColors.primaryColor.withValues(alpha: 0.2)
//                 : null,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           padding:
//               const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 2),
//           child: Text(
//             dropdownText,
//             style: context.b1.copyWith(
//               color: isSelected ? AppColors.black : AppColors.disabled,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
''';

const String dropdownTextfieldTemplate = '''
// import 'package:rentmebeach/exports.dart';

// class DropdownTextField extends StatefulWidget {
//   const DropdownTextField({
//     required this.controller,
//     required this.options,
//     this.padding = EdgeInsetsDirectional.zero,
//     this.labelText,
//     this.hintText,
//     this.validator,
//     this.onChanged,
//     this.borderRadius,
//     this.prefixIconPath,
//     this.maxHeight,
//     super.key,
//   });

//   final TextEditingController controller;
//   final List<String> options;
//   final EdgeInsetsGeometry padding;
//   final String? labelText;
//   final String? hintText;
//   final String? Function(String?)? validator;
//   final void Function(String)? onChanged;
//   final double? borderRadius;
//   final String? prefixIconPath;
//   final double? maxHeight;

//   @override
//   State<DropdownTextField> createState() => _DropdownTextFieldState();
// }

// class _DropdownTextFieldState extends State<DropdownTextField> {
//   final FocusNode _focusNode = FocusNode();
//   String? _errorText;
//   bool _isMenuOpen = false;

//   @override
//   void initState() {
//     super.initState();
//     _focusNode.addListener(() {
//       setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }

//   String? _validate(String? value) {
//     final error = widget.validator?.call(value);
//     setState(() {
//       _errorText = error;
//     });
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final borderColor = _errorText != null
//         ? AppColors.error
//         : (_focusNode.hasFocus || _isMenuOpen)
//         ? AppColors.primaryColor
//         : AppColors.greyShade6;

//     final iconColor = _errorText != null
//         ? AppColors.error
//         : (_focusNode.hasFocus || _isMenuOpen)
//         ? AppColors.primaryColor
//         : AppColors.secondaryColor;

//     // Create text styles in build method to avoid context issues
//     final baseTextStyle = context.b2.copyWith(
//       fontWeight: FontWeight.w700,
//       fontSize: 14,
//     );

//     return Padding(
//       padding: widget.padding,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (widget.labelText != null) ...[
//             Text(
//               widget.labelText!,
//               style: context.t1.copyWith(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w800,
//                 color: AppColors.primaryColor,
//               ),
//             ),
//             const SizedBox(height: 8),
//           ],
//           PopupMenuButton<String>(
//             position: PopupMenuPosition.under,
//             constraints: BoxConstraints(
//               minWidth: MediaQuery.of(context).size.width - 48,
//               maxWidth: MediaQuery.of(context).size.width - 48,
//             ),
//             color: AppColors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//               side: const BorderSide(
//                 color: AppColors.greyShade6,
//               ),
//             ),
//             shadowColor: Colors.black.withValues(alpha: 0.08),
//             elevation: 8,
//             onOpened: () {
//               setState(() => _isMenuOpen = true);
//               _focusNode.requestFocus();
//             },
//             onCanceled: () {
//               setState(() => _isMenuOpen = false);
//               _focusNode.unfocus();
//             },
//             child: Container(
//               padding: const EdgeInsetsDirectional.symmetric(
//                 horizontal: 16,
//                 vertical: 16,
//               ),
//               decoration: BoxDecoration(
//                 color: AppColors.white,
//                 borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
//                 border: Border.all(color: borderColor),
//               ),
//               child: Row(
//                 children: [
//                   // Prefix icon
//                   if (widget.prefixIconPath != null) ...[
//                     Padding(
//                       padding: const EdgeInsetsDirectional.only(end: 12),
//                       child: SvgPicture.asset(
//                         widget.prefixIconPath!,
//                         colorFilter: ColorFilter.mode(
//                           iconColor,
//                           BlendMode.srcIn,
//                         ),
//                       ),
//                     ),
//                   ],

//                   // Text content
//                   Expanded(
//                     child: Text(
//                       widget.controller.text.isNotEmpty
//                           ? widget.controller.text
//                           : widget.hintText ?? '',
//                       style: baseTextStyle.copyWith(
//                         color: widget.controller.text.isNotEmpty
//                             ? AppColors.textDark
//                             : AppColors.lightText,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),

//                   // Dropdown arrow
//                   const Padding(
//                     padding: EdgeInsetsDirectional.only(start: 12),
//                     child: Icon(
//                       Icons.keyboard_arrow_down,
//                       color: AppColors.primaryColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             itemBuilder: (context) => [
//               // Single PopupMenuItem containing all options
//               PopupMenuItem<String>(
//                 enabled: false, // Disable the outer container
//                 padding: EdgeInsets.zero,
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(
//                     maxHeight: widget.maxHeight ?? 200,
//                   ),
//                   child: IntrinsicHeight(
//                     child: widget.options.length <= 4
//                         ? Padding(
//                             padding: const EdgeInsetsDirectional.symmetric(
//                               horizontal: 8,
//                               vertical: 8,
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: widget.options.map((option) {
//                                 final isSelected =
//                                     widget.controller.text == option;
//                                 return InkWell(
//                                   onTap: () {
//                                     widget.controller.text = option;
//                                     widget.onChanged?.call(option);
//                                     _validate(option);
//                                     setState(() => _isMenuOpen = false);
//                                     _focusNode.unfocus();
//                                     Navigator.of(context).pop();
//                                   },
//                                   child: Container(
//                                     width: double.infinity,
//                                     padding:
//                                         const EdgeInsetsDirectional.symmetric(
//                                           horizontal: 16,
//                                           vertical: 12,
//                                         ),
//                                     decoration: isSelected
//                                         ? BoxDecoration(
//                                             color: AppColors
//                                                 .contactUsDropdownSelected,
//                                             border: Border.all(
//                                               color: AppColors
//                                                   .activeDetailsProgressBar,
//                                             ),
//                                             borderRadius: BorderRadius.circular(
//                                               16,
//                                             ),
//                                           )
//                                         : null,
//                                     child: Text(
//                                       option,
//                                       style: baseTextStyle.copyWith(
//                                         color: isSelected
//                                             ? AppColors.primaryColor
//                                             : AppColors.textDark,
//                                       ),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           )
//                         : SingleChildScrollView(
//                             child: Padding(
//                               padding: const EdgeInsetsDirectional.symmetric(
//                                 horizontal: 8,
//                                 vertical: 8,
//                               ),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: widget.options.map((option) {
//                                   final isSelected =
//                                       widget.controller.text == option;
//                                   return InkWell(
//                                     onTap: () {
//                                       widget.controller.text = option;
//                                       widget.onChanged?.call(option);
//                                       _validate(option);
//                                       setState(() => _isMenuOpen = false);
//                                       _focusNode.unfocus();
//                                       Navigator.of(context).pop();
//                                     },
//                                     child: Container(
//                                       width: double.infinity,
//                                       padding:
//                                           const EdgeInsetsDirectional.symmetric(
//                                             horizontal: 16,
//                                             vertical: 12,
//                                           ),
//                                       decoration: isSelected
//                                           ? BoxDecoration(
//                                               color: AppColors
//                                                   .contactUsDropdownSelected,
//                                               border: Border.all(
//                                                 color: AppColors
//                                                     .activeDetailsProgressBar,
//                                               ),
//                                               borderRadius:
//                                                   BorderRadius.circular(16),
//                                             )
//                                           : null,
//                                       child: Text(
//                                         option,
//                                         style: baseTextStyle.copyWith(
//                                           color: isSelected
//                                               ? AppColors.primaryColor
//                                               : AppColors.textDark,
//                                         ),
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   );
//                                 }).toList(),
//                               ),
//                             ),
//                           ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           if (_errorText != null) ...[
//             const SizedBox(height: 6),
//             Text(
//               _errorText!,
//               style: baseTextStyle.copyWith(
//                 color: AppColors.error,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
''';

const String emptyStateWidgetTemplate = '''
import 'package:{{project_name}}/exports.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.title,
    this.subtitle,
    this.iconPath,
    this.iconBgColor,
    this.buttonText,
    this.onButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    this.showSecondaryButton = false,
    this.iconColor,
    this.iconWidget,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? iconPath;
  final Color? iconBgColor;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;
  final bool showSecondaryButton;
  final Color? iconColor;
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconWidget != null && iconPath == null) ...[
            iconWidget!,
          ] else if (iconPath != null && iconWidget == null) ...[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color:
                    iconBgColor ??
                    AppColors.blackPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath!,
                  width: 40,
                  height: 40,
                  colorFilter: iconColor != null
                      ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            title,
            style: context.h3.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.blackPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: context.b2.copyWith(color: AppColors.blackPrimary),
              textAlign: TextAlign.center,
            ),
          ],
          if (buttonText != null || showSecondaryButton) ...[
            const SizedBox(height: 32),
            if (showSecondaryButton && secondaryButtonText != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomButton(
                      text: buttonText ?? '',
                      onPressed: onButtonPressed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: secondaryButtonText!,
                      onPressed: onSecondaryButtonPressed,
                    ),
                  ),
                ],
              ),
            ] else if (buttonText != null) ...[
              CustomButton(text: buttonText!, onPressed: onButtonPressed),
            ],
          ],
        ],
      ),
    );
  }
}
''';

const String exportTemplate = '''
export '../blur_overlay.dart';
export '../filter_icon_widget.dart';
export 'app_bar.dart';
export 'bottom_sheet.dart';
export 'bullet_point_item.dart';
export 'button.dart';
export 'cached_network_image.dart';
export 'chips.dart';
export 'confirmation_dialog.dart';
export 'custom_date_picker.dart';
export 'custom_dropdown.dart';
export 'custom_dropdown_cubit.dart';
export 'date_picker.dart';
export 'dialog.dart';
export 'dropdown.dart';
export 'dropdown_row.dart';
export 'dropdown_textfield.dart';
export 'empty_state_widget.dart';
export 'icon_button.dart';
export 'image_picker.dart';
export 'loading_widget.dart';
export 'notification_tile.dart';
export 'outline_button.dart';
export 'paginated_list_view.dart';
export 'popup_menu_button.dart';
export 'progress_dashes.dart';
export 'retry_widget.dart';
export 'rich_text.dart';
export 'search_field.dart';
export 'searchable_dropdown.dart';
export 'shimmer_loading_widget.dart';
export 'slider.dart';
export 'sliding_tab.dart';
export 'social_auth_button.dart';
export 'stacked_images_widget.dart';
export 'switch.dart';
export 'text_button.dart';
export 'text_field.dart';
export 'time_picker.dart';
export 'title_row.dart';
export 'section_title.dart';
''';

const String iconButtonTemplate = '''
import 'package:{{project_name}}/exports.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    this.icon,
    this.onPressed,
    this.backgroundColor = AppColors.white,
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
          : icon ?? SvgPicture.asset(AssetPaths.arrowLeftIcon),
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
''';

const String imagePickerTemplate = '''
import 'dart:io';

import 'package:{{project_name}}/exports.dart';

class RMBImagePicker extends StatelessWidget {
  const RMBImagePicker({
    required this.onButtonPressed,
    required this.imagePath,
    super.key,
  });

  final VoidCallback onButtonPressed;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onButtonPressed,
      icon: imagePath == null || (imagePath ?? '').isEmpty
          ? const Icon(Icons.add_a_photo)
          : ClipOval(child: _getImageWidget(imagePath!)),
      padding: EdgeInsetsDirectional.all(
        imagePath == null || (imagePath ?? '').isEmpty ? 50 : 0,
      ),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.blackPrimary,
        shape: const CircleBorder(),
        side: const BorderSide(color: AppColors.blackPrimary),
      ),
    );
  }

  Widget _getImageWidget(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        height: 130.03,
        width: 130.03,
        imagePath,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        height: 130.03,
        width: 130.03,
        fit: BoxFit.cover,
        File(imagePath.replaceFirst('file://', '')),
      );
    }
  }
}
''';

const String loadingWidgetTemplate = '''
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:{{project_name}}/exports.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.size = 24,
    this.color = AppColors.blackPrimary,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: Platform.isIOS
            ? CupertinoActivityIndicator(color: color)
            : CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 1.5,
              ),
      ),
    );
  }
}
''';

const String notificationTileTemplate = '''
// import 'package:activ/exports.dart';

// class NotificationTile extends StatelessWidget {
//   const NotificationTile({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.time,
//     required this.onTap,
//     required this.isRead,
//     super.key,
//   });

//   final String? icon;
//   final String title;
//   final String subtitle;
//   final String time;
//   final VoidCallback onTap;

//   final bool isRead;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: AppColors.iconBackground,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         padding: EdgeInsetsDirectional.symmetric(
//           horizontal: MediaQuery.sizeOf(context).width * 0.04,
//           vertical: MediaQuery.sizeOf(context).height * 0.01,
//         ),
//         child: Row(
//           children: [
//             Stack(
//               alignment: Alignment.topRight,
//               children: [
//                 Container(
//                   height: 48,
//                   width: 48,
//                   decoration: BoxDecoration(
//                     color: AppColors.white,
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: AppColors.primaryBlue,
//                       width: 0.75,
//                     ),
//                   ),
//                   child: Center(
//                     child: SvgPicture.asset(
//                       icon ?? AssetPaths.notificationEnabledIcon,
//                       width: 32,
//                       height: 32,
//                     ),
//                   ),
//                 ),
//                 if (!isRead)
//                   Positioned(
//                     top: 2,
//                     right: 2,
//                     child: Container(
//                       height: 10,
//                       width: 10,
//                       decoration: const BoxDecoration(
//                         color: AppColors.primaryBlue,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     maxLines: 2,
//                     overflow: TextOverflow.visible,
//                     style: context.b1.copyWith(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     subtitle,
//                     style: context.b2,
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Text(
//                   time,
//                   style: context.l3.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textNormal,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 SvgPicture.asset(
//                   AssetPaths.rightArrowIcon,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
''';

const String outlineButtonTemplate = '''
import 'package:google_fonts/google_fonts.dart';
import 'package:{{project_name}}/exports.dart';

class RMBOutlineButton extends StatelessWidget {
  RMBOutlineButton({
    required this.text,
    required this.onPressed,
    required this.isLoading,
    super.key,
    this.borderColor = AppColors.blackPrimary,
    this.textColor = AppColors.blackPrimary,
    this.disabledTextColor = AppColors.blackPrimary,
    this.disabledBorderColor,
    this.borderRadius = 100,
    EdgeInsets? padding,
    this.fontWeight = FontWeight.w800,
    this.splashColor = Colors.black12,
    this.fontSize = 18,
    this.prefixIcon,
    this.suffixIcon,
    EdgeInsets? outsidePadding,
    this.isExpanded = true,
    this.iconSpacing,
    this.disabled = false,
    this.loadingColor,
    this.borderWidth = 1.5,
  }) : padding = padding ?? EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 14,
        ),
        outsidePadding = outsidePadding ?? EdgeInsets.all(4);

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
                    style: GoogleFonts.urbanist(
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
''';

const String paginatedListViewTemplate = '''
import 'package:{{project_name}}/exports.dart';

class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMoreData,
    super.key,
    this.emptyTitle = 'No items found',
    this.emptySubtitle = 'Check back later for more content',
    this.emptyIcon,
    this.errorMessage,
    this.onRetry,
    this.separatorBuilder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.loadMoreThreshold = 200,
    this.refreshIndicatorColor,
    this.refreshIndicatorBackgroundColor,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreData;
  final String emptyTitle;
  final String emptySubtitle;
  final String? emptyIcon;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double loadMoreThreshold;
  final Color? refreshIndicatorColor;
  final Color? refreshIndicatorBackgroundColor;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent -
                widget.loadMoreThreshold &&
        !widget.isLoadingMore &&
        widget.hasMoreData &&
        widget.items.isNotEmpty) {
      widget.onLoadMore();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: EmptyStateWidget(
          title: widget.emptyTitle,
          subtitle: widget.emptySubtitle,
          iconPath: widget.emptyIcon,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: RetryWidget(
        message: widget.errorMessage ?? 'Something went wrong',
        onRetry: widget.onRetry ?? widget.onRefresh,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: LoadingWidget(),
    );
  }

  Widget _buildListView() {
    final itemCount = widget.items.length + (widget.isLoadingMore ? 1 : 0);

    return RefreshIndicator.adaptive(
      onRefresh: widget.onRefresh,
      color: widget.refreshIndicatorColor,
      backgroundColor: widget.refreshIndicatorBackgroundColor,
      child: ListView.separated(
        controller: _scrollController,
        padding: widget.padding,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        itemCount: itemCount,
        separatorBuilder:
            widget.separatorBuilder ??
            (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          // Show loading indicator at the end
          if (index >= widget.items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsetsDirectional.all(16),
                child: LoadingWidget(),
              ),
            );
          }

          final item = widget.items[index];
          return widget.itemBuilder(context, item, index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show error state if there's an error and no items
    if (widget.errorMessage != null && widget.items.isEmpty) {
      return _buildErrorState();
    }

    // Show loading state on initial load
    if (widget.isLoading && widget.items.isEmpty) {
      return _buildLoadingState();
    }

    // Show empty state if no items and not loading
    if (widget.items.isEmpty && !widget.isLoading) {
      return _buildEmptyState();
    }

    // Show list view with items
    return _buildListView();
  }
}

// Specialized widget for sliver lists
class PaginatedSliverListView<T> extends StatefulWidget {
  const PaginatedSliverListView({
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMoreData,
    super.key,
    this.loadMoreThreshold = 200,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreData;
  final double loadMoreThreshold;

  @override
  State<PaginatedSliverListView<T>> createState() =>
      _PaginatedSliverListViewState<T>();
}

class _PaginatedSliverListViewState<T>
    extends State<PaginatedSliverListView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent -
                widget.loadMoreThreshold &&
        !widget.isLoadingMore &&
        widget.hasMoreData &&
        widget.items.isNotEmpty) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.items.length + (widget.isLoadingMore ? 1 : 0);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Show loading indicator at the end
          if (index >= widget.items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsetsDirectional.all(16),
                child: LoadingWidget(),
              ),
            );
          }

          final item = widget.items[index];
          return widget.itemBuilder(context, item, index);
        },
        childCount: itemCount,
      ),
    );
  }
}

class PaginatedGridView<T> extends StatefulWidget {
  const PaginatedGridView({
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMoreData,
    required this.gridDelegate,
    super.key,
    this.emptyTitle = 'No items found',
    this.emptySubtitle = 'Check back later for more content',
    this.emptyIcon,
    this.errorMessage,
    this.onRetry,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.loadMoreThreshold = 200,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreData;
  final SliverGridDelegate gridDelegate;
  final String emptyTitle;
  final String emptySubtitle;
  final String? emptyIcon;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double loadMoreThreshold;

  @override
  State<PaginatedGridView<T>> createState() => _PaginatedGridViewState<T>();
}

class _PaginatedGridViewState<T> extends State<PaginatedGridView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent -
                widget.loadMoreThreshold &&
        !widget.isLoadingMore &&
        widget.hasMoreData &&
        widget.items.isNotEmpty) {
      widget.onLoadMore();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: EmptyStateWidget(
          title: widget.emptyTitle,
          subtitle: widget.emptySubtitle,
          iconPath: widget.emptyIcon,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: RetryWidget(
        message: widget.errorMessage ?? 'Something went wrong',
        onRetry: widget.onRetry ?? widget.onRefresh,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: LoadingWidget(),
    );
  }

  Widget _buildGridView() {
    return RefreshIndicator.adaptive(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: widget.physics,
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: widget.gridDelegate,
              padding: widget.padding,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return widget.itemBuilder(context, item, index);
              },
            ),
            if (widget.isLoadingMore && widget.items.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: LoadingWidget(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.errorMessage != null && widget.items.isEmpty) {
      return _buildErrorState();
    }

    if (widget.isLoading && widget.items.isEmpty) {
      return _buildLoadingState();
    }

    if (widget.items.isEmpty && !widget.isLoading) {
      return _buildEmptyState();
    }

    return _buildGridView();
  }
}

class PaginatedSliverGridView<T> extends StatefulWidget {
  const PaginatedSliverGridView({
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMoreData,
    required this.gridDelegate,
    super.key,
    this.loadMoreThreshold = 200,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreData;
  final SliverGridDelegate gridDelegate;
  final double loadMoreThreshold;

  @override
  State<PaginatedSliverGridView<T>> createState() =>
      _PaginatedSliverGridViewState<T>();
}

class _PaginatedSliverGridViewState<T>
    extends State<PaginatedSliverGridView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent -
                widget.loadMoreThreshold &&
        !widget.isLoadingMore &&
        widget.hasMoreData &&
        widget.items.isNotEmpty) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.items.length + (widget.isLoadingMore ? 1 : 0);

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= widget.items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsetsDirectional.all(16),
                child: LoadingWidget(),
              ),
            );
          }

          final item = widget.items[index];
          return widget.itemBuilder(context, item, index);
        },
        childCount: itemCount,
      ),
      gridDelegate: widget.gridDelegate,
    );
  }
}
''';

const String popupMenuButtonTemplate = '''
// import 'package:activ/exports.dart';

// class ActivPopupMenuButton extends StatelessWidget {
//   const ActivPopupMenuButton({
//     required this.buttonOneText,
//     required this.buttonOneOnTap,
//     super.key,
//     this.buttonTwoText,
//     this.buttonTwoOnTap,
//     this.icon,
//     this.buttonOneTextStyle,
//     this.buttonTwoTextStyle,
//     this.offset = const Offset(0, 40),
//     this.buttonBackgroundColor = AppColors.iconBackground,
//   });

//   final String buttonOneText;
//   final VoidCallback buttonOneOnTap;
//   final String? buttonTwoText;
//   final VoidCallback? buttonTwoOnTap;
//   final Widget? icon;
//   final TextStyle? buttonOneTextStyle;
//   final TextStyle? buttonTwoTextStyle;
//   final Offset offset;
//   final Color buttonBackgroundColor;

//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<String>(
//       clipBehavior: Clip.antiAlias,
//       enableFeedback: false,
//       elevation: 2,
//       style: ButtonStyle(
//         backgroundColor: WidgetStateProperty.all(buttonBackgroundColor),
//         minimumSize: WidgetStateProperty.all(Size.zero),
//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//         overlayColor: WidgetStateProperty.all(Colors.transparent),
//         padding: WidgetStateProperty.all(const EdgeInsetsDirectional.all(12)),
//         splashFactory: NoSplash.splashFactory,
//       ),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       menuPadding: EdgeInsetsDirectional.zero,
//       padding: EdgeInsetsDirectional.zero,
//       color: AppColors.white,
//       onSelected: (value) {
//         if (value == 'buttonOne') {
//           buttonOneOnTap();
//         } else if (value == 'buttonTwo' && buttonTwoOnTap != null) {
//           buttonTwoOnTap!();
//         }
//       },
//       itemBuilder: (BuildContext context) {
//         final menuItems = <PopupMenuEntry<String>>[
//           PopupMenuItem<String>(
//             height: 40,
//             value: 'buttonOne',
//             child: Center(
//               child: Text(
//                 buttonOneText,
//                 style: buttonOneTextStyle ?? context.b2,
//               ),
//             ),
//           ),
//         ];

//         if (buttonTwoText != null) {
//           menuItems.add(
//             PopupMenuItem<String>(
//               height: 40,
//               value: 'buttonTwo',
//               child: Center(
//                 child: Text(
//                   buttonTwoText!,
//                   style: buttonTwoTextStyle ??
//                       context.b2.copyWith(
//                         color: AppColors.error,
//                       ),
//                 ),
//               ),
//             ),
//           );
//         }

//         return menuItems;
//       },
//       icon: icon ?? SvgPicture.asset(AssetPaths.menuIcon),
//       offset: offset,
//     );
//   }
// }
''';

const String progressDashesTemplate = '''
import 'package:{{project_name}}/exports.dart';

class RMBProgressDashes extends StatelessWidget {
  const RMBProgressDashes({
    required this.totalSteps,
    required this.currentIndex,
    super.key,
    this.height = 3,
    this.gap = 8,
    this.borderRadius = 999,
    this.activeColor = AppColors.blackPrimary,
    this.inactiveColor = AppColors.blackPrimary,
  }) : assert(totalSteps > 0, 'totalSteps must be > 0');

  final int totalSteps;
  final int currentIndex;
  final double height;
  final double gap;
  final double borderRadius;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final totalGapsWidth = gap * (totalSteps - 1);
        final dashWidth = (availableWidth - totalGapsWidth) / totalSteps;

        return Row(
          children: List.generate(totalSteps * 2 - 1, (i) {
            if (i.isOdd) {
              return SizedBox(width: gap);
            }

            final index = i ~/ 2;
            final isActive = index <= currentIndex;
            return _Dash(
              width: dashWidth.clamp(4, double.infinity),
              height: height,
              color: isActive ? activeColor : inactiveColor,
              radius: borderRadius,
            );
          }),
        );
      },
    );
  }
}

class _Dash extends StatelessWidget {
  const _Dash({
    required this.width,
    required this.height,
    required this.color,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
''';

const String retryWidgetTemplate = '''
import 'package:{{project_name}}/exports.dart';

class RetryWidget extends StatelessWidget {
  const RetryWidget({
    required this.onRetry,
    required this.message,
    super.key,
  });

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message ?? 'Something went wrong. Please try again.',
            style: context.b2.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              side: const BorderSide(color: AppColors.error),
              foregroundColor: AppColors.white,
              backgroundColor: AppColors.error,
            ),
            child: Text(
              'Retry',
              style: context.b2.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
''';

const String reusableCalendarWidgetTemplate = '''
import 'package:{{project_name}}/exports.dart';

enum CalendarMode {
  single, // For postpone - single date selection
  dual, // For filters - start and end date selection
}

class ReusableCalendarWidget extends StatefulWidget {
  const ReusableCalendarWidget({
    required this.mode,
    this.onDateSelected,
    this.startDate,
    this.endDate,
    this.selectedDate,
    this.isSelectingEndDate = false,
    this.onStartDateSelected,
    this.onEndDateSelected,
    super.key,
  });

  final CalendarMode mode;
  final dynamic Function(DateTime)? onDateSelected; // For single mode
  final DateTime? startDate; // For dual mode
  final DateTime? endDate; // For dual mode
  final DateTime? selectedDate; // For single mode
  final bool isSelectingEndDate; // For dual mode
  final dynamic Function(DateTime)? onStartDateSelected; // For dual mode
  final dynamic Function(DateTime)? onEndDateSelected; // For dual mode

  @override
  State<ReusableCalendarWidget> createState() => _ReusableCalendarWidgetState();
}

class _ReusableCalendarWidgetState extends State<ReusableCalendarWidget> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Month Navigation
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(
                        _currentMonth.year,
                        _currentMonth.month - 1,
                      );
                    });
                  },
                  icon: const Icon(
                    Icons.chevron_left,
                    color: AppColors.blackPrimary,
                  ),
                ),
                Text(
                  '\${_getMonthName(_currentMonth.month)} \${_currentMonth.year}',
                  style: context.t3.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(
                        _currentMonth.year,
                        _currentMonth.month + 1,
                      );
                    });
                  },
                  icon: const Icon(
                    Icons.chevron_right,
                    color: AppColors.blackPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Weekday Headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sat', 'Su']
                  .map(
                    (day) => SizedBox(
                      width: 32,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: context.t3.copyWith(
                          fontSize: 12,
                          color: AppColors.blackPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Calendar Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCalendarGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month);
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    final now = DateTime.now();

    final days = <Widget>[];

    // Add empty spaces for days before the first day of the month
    for (var i = 1; i < firstWeekday; i++) {
      days.add(const SizedBox(height: 32));
    }

    // Add days of the month
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);

      // Determine if date is selected based on mode
      var isSelected = false;
      var isDisabled = false;

      if (widget.mode == CalendarMode.single) {
        isSelected = widget.selectedDate != null &&
            isSameDay(date, widget.selectedDate!);
        isDisabled = date.isBefore(
          DateTime(now.year, now.month, now.day),
        ); // Past dates disabled
      } else {
        // Dual mode
        final isStartDate =
            widget.startDate != null && isSameDay(date, widget.startDate!);
        final isEndDate =
            widget.endDate != null && isSameDay(date, widget.endDate!);
        isSelected = isStartDate || isEndDate;
        isDisabled = widget.isSelectingEndDate &&
            widget.startDate != null &&
            date.isBefore(widget.startDate!);
      }

      final isToday = isSameDay(date, now);

      days.add(
        GestureDetector(
          onTap: isDisabled ? null : () => _handleDateTap(date),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.blackPrimary
                  : isToday
                      ? AppColors.blackPrimary
                      : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.toString(),
                    style: context.b2.copyWith(
                      fontSize: 12,
                      color: isDisabled
                          ? AppColors.blackPrimary.withValues(alpha: 0.3)
                          : isSelected
                              ? AppColors.white
                              : isToday
                                  ? AppColors.blackPrimary
                                  : Colors.black,
                      fontWeight: (isSelected || isToday)
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (isToday) ...[
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDisabled
                            ? AppColors.blackPrimary.withValues(alpha: 0.3)
                            : isSelected
                                ? AppColors.white
                                : AppColors.blackPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: days,
    );
  }

  void _handleDateTap(DateTime date) {
    if (widget.mode == CalendarMode.single) {
      widget.onDateSelected?.call(date);
    } else {
      // Dual mode
      if (widget.isSelectingEndDate) {
        widget.onEndDateSelected?.call(date);
      } else {
        widget.onStartDateSelected?.call(date);
      }
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
''';

const String richTextTemplate = '''
import 'package:flutter/gestures.dart';
import 'package:{{project_name}}/exports.dart';

class CustomRichText extends StatelessWidget {
  const CustomRichText({
    required this.textBefore,
    required this.richText,
    required this.textAfter,
    super.key,
    this.normalTextStyle,
    this.richTextStyle,
    this.richTextColor,
    this.onRichTextTap,
    this.textAlign = TextAlign.center,
    this.noSpace = false,
    this.richTextDecoration,
  });

  final TextStyle? normalTextStyle;
  final TextStyle? richTextStyle;
  final bool noSpace;
  final String textBefore;
  final String textAfter;
  final String richText;
  final Color? richTextColor;
  final VoidCallback? onRichTextTap;
  final TextAlign textAlign;
  final TextDecoration? richTextDecoration;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        text: textBefore,
        style: normalTextStyle ??
            context.l3.copyWith(
              color: AppColors.textSecondary,
            ),
        children: [
          TextSpan(
            text: noSpace ? richText : ' \$richText ',
            style: richTextStyle ??
                context.l1.copyWith(
                  fontSize: 10,
                  color: richTextColor ?? AppColors.blackPrimary,
                  fontWeight: FontWeight.bold,
                  decoration: richTextDecoration,
                ),
            recognizer: TapGestureRecognizer()..onTap = onRichTextTap,
          ),
          TextSpan(
            text: textAfter,
            style: normalTextStyle ??
                context.l3.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
''';

const String searchFieldTemplate = '''
import 'package:flutter/material.dart';

class ActivSearchField extends StatelessWidget {
  const ActivSearchField({
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.onChanged,
    this.cursorColor,
    this.onTap,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final Color? cursorColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      onChanged: onChanged,
      cursorColor: cursorColor,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
''';

const String searchableDropdownTemplate = '''
import 'package:{{project_name}}/exports.dart';

class SearchableDropdown extends StatefulWidget {
  const SearchableDropdown({
    required this.labelText,
    required this.options,
    required this.onChanged,
    this.selectedValue,
    this.hintText,
    this.prefixIconPath,
    this.borderRadius = 100.0,
    this.maxHeight = 200.0,
    this.enabled = true,
    this.validator,
    this.showValidation = false,
    super.key,
  });

  final String labelText;
  final List<String> options;
  final void Function(String) onChanged;
  final String? selectedValue;
  final String? hintText;
  final String? prefixIconPath;
  final double borderRadius;
  final double maxHeight;
  final bool enabled;
  final String? Function(String?)? validator;
  final bool showValidation;

  @override
  State<SearchableDropdown> createState() => SearchableDropdownState();
}

class SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late CustomDropdownCubit _cubit;
  List<String> _filteredOptions = [];
  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  FormFieldState<String>? _formFieldState;

  @override
  void initState() {
    super.initState();
    _cubit = CustomDropdownCubit();
    _filteredOptions = widget.options;

    if (widget.selectedValue != null) {
      _searchController.text = widget.selectedValue!;
    }

    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(SearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.options != oldWidget.options) {
      _filteredOptions = widget.options;
      _filterOptions();
    }

    if (widget.selectedValue != oldWidget.selectedValue) {
      _searchController.text = widget.selectedValue ?? '';
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    _focusNode.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterOptions();
    if (_overlayEntry != null) {
      _showOverlay(); // Rebuild overlay with new filtered options
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _cubit.openDropdown();
      _showOverlay();
    } else {
      // Validate that the entered text matches an option
      _validateSelectedValue();
      _removeOverlay();
    }
  }

  void _filterOptions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOptions = widget.options.where((option) {
        return option.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _validateSelectedValue() {
    final enteredText = _searchController.text.trim();

    // If text is entered but doesn't match any option, clear it
    if (enteredText.isNotEmpty && !widget.options.contains(enteredText)) {
      _searchController.clear();
      _formFieldState?.didChange('');
      widget.onChanged('');
      _cubit.closeDropdown();
      return;
    }

    // If text matches an option, select it
    if (enteredText.isNotEmpty && widget.options.contains(enteredText)) {
      _formFieldState?.didChange(enteredText);
      widget.onChanged(enteredText);
    }

    _cubit.closeDropdown();
  }

  void _selectOption(String option) {
    _searchController.text = option;
    _formFieldState?.didChange(option);
    widget.onChanged(option);
    _cubit.closeDropdown();
    _focusNode.unfocus();
    _removeOverlay();
  }

  void _validateField() {
    if (widget.validator != null && widget.showValidation) {
      final error = widget.validator!(widget.selectedValue);
      _cubit.setError(error);
    } else {
      _cubit.clearError();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    final overlay = Overlay.of(context);
    final renderBox =
        _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

      _overlayEntry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            // Invisible full-screen tap detector to close on outside tap
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  _removeOverlay();
                  _cubit.closeDropdown();
                  _focusNode.unfocus();
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            // The actual dropdown content
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              width: size.width,
              child: Material(
                child: Container(
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.textTertiary),
          ),
          child: _filteredOptions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No cities found',
                    style: context.b2.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  itemCount: _filteredOptions.length,
                  itemBuilder: (context, index) {
                    final option = _filteredOptions[index];
                    final isSelected = widget.selectedValue == option;

                    return InkWell(
                      onTap: () => _selectOption(option),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: context.b2.copyWith(
                                  color: AppColors.blackPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppColors.blackPrimary,
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  AssetPaths.tickIcon,
                                  width: 14,
                                  height: 14,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                 ),
                ),
              ),
            ),
          ],
        ),
      );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Public method to close the dropdown
  void closeDropdown() {
    _removeOverlay();
    _cubit.closeDropdown();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.selectedValue,
      validator: widget.validator,
      builder: (FormFieldState<String> field) {
        _formFieldState = field;
        return BlocProvider.value(
          value: _cubit,
          child: BlocConsumer<CustomDropdownCubit, CustomDropdownState>(
            listener: (context, state) {
              if (widget.showValidation) {
                _validateField();
              }
            },
            builder: (context, state) {
          final hasError = state.errorText != null;
          final isOpen = state.isOpen;

          final borderColor = !widget.enabled
              ? AppColors.textTertiary
              : hasError
                  ? AppColors.error
                  : isOpen
                      ? AppColors.blackPrimary
                      : AppColors.textTertiary;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.labelText,
                style: context.b1.copyWith(color: AppColors.blackPrimary),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (widget.enabled) {
                    if (isOpen) {
                      _removeOverlay();
                      _cubit.closeDropdown();
                      _focusNode.unfocus();
                    } else {
                      _focusNode.requestFocus();
                    }
                  }
                },
                child: Container(
                  key: _dropdownKey,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        if (widget.prefixIconPath != null) ...[
                          SvgPicture.asset(
                            widget.prefixIconPath!,
                            width: 16,
                            colorFilter: ColorFilter.mode(
                              widget.enabled
                                  ? AppColors.blackPrimary
                                  : AppColors.textTertiary,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: SizedBox(
                            height: 20, // Match the height of Text widget
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              enabled: widget.enabled,
                              decoration: InputDecoration(
                                hintText: widget.hintText ?? widget.labelText,
                                hintStyle: context.b2.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              style: context.b2.copyWith(
                                color: AppColors.blackPrimary,
                              ),
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: isOpen ? 0.5 : 0,
                          duration: Duration(milliseconds: 200),
                          child: SvgPicture.asset(
                            AssetPaths.dropdownArrowIcon,
                            colorFilter: ColorFilter.mode(
                              widget.enabled
                                  ? AppColors.blackPrimary
                                  : AppColors.textTertiary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Always reserve fixed space for error when field has validator so layout never shifts
              if (widget.validator != null)
                BlocBuilder<CustomDropdownCubit, CustomDropdownState>(
                  builder: (context, state) {
                    final hasError = state.errorText != null && state.errorText!.isNotEmpty;
                    final showError = widget.showValidation && hasError;
                    return SizedBox(
                      height: 24,
                      child: showError
                          ? Padding(
                              padding: const EdgeInsets.only(top: 6, left: 12),
                              child: Text(
                                state.errorText!,
                                style: context.b3.copyWith(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : const SizedBox.shrink(),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
      },
    );
  }
}
''';

const String sectionTitleTemplate = '''
import 'package:{{project_name}}/exports.dart';

/// Reusable section title widget with consistent styling
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
          padding: padding ??
              EdgeInsets.symmetric(horizontal: 16),
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
''';

const String shimmerLoadingWidgetTemplate = '''
import 'package:flutter/material.dart';
import 'package:{{project_name}}/constants/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingWidget extends StatelessWidget {
  const ShimmerLoadingWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 0.0,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Shimmer.fromColors(
        baseColor: AppColors.backgroundTertiary,
        highlightColor: AppColors.white,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
''';

const String sliderTemplate = '''
import 'package:{{project_name}}/exports.dart';

class FeesSlider extends StatefulWidget {
  const FeesSlider({super.key, this.initialValue = 1, this.onChanged});

  final double initialValue;
  final ValueChanged<double>? onChanged;

  @override
  State<FeesSlider> createState() => _FeesSliderState();
}

class _FeesSliderState extends State<FeesSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Fees',
              style: context.t3.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.blackPrimary,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Text(
              'Amount: \\\$ \${_value.toInt()}',
              style: context.t3.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.blackPrimary,
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: SliderTheme(
            data: SliderThemeData(
              thumbSize: WidgetStateProperty.all(const Size(13, 13)),
              activeTrackColor: AppColors.blackPrimary,
              trackHeight: 4,
              inactiveTrackColor: AppColors.blackPrimary,
              thumbColor: AppColors.blackPrimary,
              overlayColor: AppColors.blackPrimary.withValues(alpha: 0.1),
            ),
            child: Slider(
              year2023: false,
              value: _value,
              min: 1,
              max: 500,
              onChanged: (value) {
                setState(() => _value = value);
                widget.onChanged?.call(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
''';

const String slidingCartNotificationTemplate = '''
import 'package:{{project_name}}/exports.dart';
import 'package:{{project_name}}/utils/helpers/cart_notification_helper.dart';
import 'package:lottie/lottie.dart';

class SlidingCartNotification extends StatefulWidget {
  const SlidingCartNotification({
    required this.productName,
    required this.quantity,
    this.size,
    this.color,
    super.key,
  });

  final String productName;
  final int quantity;
  final String? size;
  final Color? color;

  @override
  State<SlidingCartNotification> createState() =>
      _SlidingCartNotificationState();
}

class _SlidingCartNotificationState extends State<SlidingCartNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    // Start the animation
    _controller.forward();

    // Auto dismiss after display duration
    Future.delayed(Duration(milliseconds: 2500), () {
      if (mounted) {
        _dismissNotification();
      }
    });
  }

  Future<void> _dismissNotification() async {
    await _controller.reverse();
    if (mounted) {
      CartNotificationHelper.dismiss();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      bottom: 100,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: () async {
            // Dismiss the overlay first
            await _dismissNotification();
            // Then navigate to cart
            if (mounted && context.mounted) {
              context.push(AppRoutes.cartScreen);
            }
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 340,
                minHeight: 80,
              ),
              padding: EdgeInsets.only(
                top: 12,
                right: 20,
                bottom: 12,
                left: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.cartNotificationBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(-3, 3),
                ),
              ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lottie animation with error handling
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: Lottie.asset(
                      'assets/lottie/cart.json',
                      repeat: false,
                      animate: true,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to cart icon if Lottie fails
                        return Icon(
                          Icons.shopping_cart,
                          size: 32,
                          color: AppColors.blackPrimary,
                        );
                      },
                      delegates: LottieDelegates(
                        values: [
                          // Target specific grey layers and change to black
                          ValueDelegate.color(
                            const ['Circle BG', '**'],
                            value: AppColors.blackPrimary,
                          ),
                          ValueDelegate.color(
                            const ['Line BG', '**'],
                            value: AppColors.blackPrimary,
                          ),
                          ValueDelegate.color(
                            const ['Line', '**'],
                            value: AppColors.blackPrimary,
                          ),
                          ValueDelegate.color(
                            const ['Circle Mask', '**'],
                            value: AppColors.blackPrimary,
                          ),
                          ValueDelegate.color(
                            const ['Line Masks', '**'],
                            value: AppColors.blackPrimary,
                          ),
                          ValueDelegate.color(
                            const ['Line Masks 2', '**'],
                            value: AppColors.blackPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Text content
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Added to Cart!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                '\${widget.quantity} x \${widget.productName}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.blackPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.size != null) ...[
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  widget.size!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.blackPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                            if (widget.color != null) ...[
                              SizedBox(width: 8),
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black12,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
''';

const String slidingTabTemplate = '''
import 'package:{{project_name}}/exports.dart';

class SlidingTab extends StatefulWidget {
  const SlidingTab({
    required this.labels,
    required this.onTapCallbacks,
    this.height,
    this.width,
    this.selectedColor,
    this.backgroundColor,
    this.borderColor,
    this.initialIndex = 0,
    this.shortenWidth = false,
    this.borderRadius = 100,
    super.key,
  }) : assert(
         labels.length == onTapCallbacks.length &&
             (labels.length == 2 || labels.length == 3),
         'labels and onTapCallbacks must be of equal length and contain either 2 or 3 items.',
       );

  final List<String> labels;
  final List<VoidCallback> onTapCallbacks;
  final double? height;
  final double? width;
  final Color? selectedColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final int initialIndex;
  final bool shortenWidth;
  final double borderRadius;

  @override
  State<SlidingTab> createState() => _SlidingTabState();
}

class _SlidingTabState extends State<SlidingTab> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(SlidingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      selectedIndex = widget.initialIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullWidth = MediaQuery.of(context).size.width;
    final containerWidth = widget.width ?? fullWidth;
    final tabCount = widget.labels.length;

    final tabWidth1 = widget.shortenWidth
        ? containerWidth / (tabCount + 0.5)
        : containerWidth / tabCount;

    final tabWidth2 = widget.shortenWidth
        ? containerWidth / (tabCount + 0.1)
        : containerWidth / tabCount;

    final tabWidth3 = widget.shortenWidth
        ? containerWidth / (tabCount + 0.45)
        : containerWidth / tabCount;

    return Container(
      width: containerWidth,
      height: widget.height ?? 48,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.blackPrimary,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: widget.borderColor != null
            ? Border.all(color: widget.borderColor!)
            : null,
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: Duration(milliseconds: 300),
            alignment: Alignment(
              -1.0 + (2.0 * selectedIndex / (tabCount - 1)),
              0,
            ),
            child: Container(
              width: selectedIndex == 0
                  ? tabWidth1
                  : selectedIndex == 1
                  ? tabWidth2
                  : tabWidth3,
              height: widget.height ?? 48,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: widget.selectedColor ?? AppColors.blackPrimary,
                borderRadius: BorderRadius.circular(widget.borderRadius - 4),
              ),
            ),
          ),
          Row(
            children: List.generate(tabCount, (index) {
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    widget.onTapCallbacks[index]();
                  },
                  child: Container(
                    height: widget.height ?? 48,
                    alignment: Alignment.center,
                    child: Text(
                      widget.labels[index],
                      textAlign: TextAlign.center,
                      style: context.b3,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
''';

const String socialAuthButtonTemplate = '''
import 'package:{{project_name}}/exports.dart';

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
''';

const String stackedImagesWidgetTemplate = '''
import 'package:{{project_name}}/exports.dart';

class RMBStackedImages extends StatelessWidget {
  const RMBStackedImages({
    required this.images,
    required this.size,
    required this.maxImages,
    super.key,
  });

  final List<String> images;
  final double size;
  final int maxImages;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: Stack(
        children: [
          for (int i = 0; i < images.take(maxImages).length; i++)
            Positioned(
              left: i * (size * 0.6),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white),
                ),
                child: CircleAvatar(
                  radius: size / 2,
                  backgroundImage: AssetImage(images[i]),
                  backgroundColor: AppColors.white,
                ),
              ),
            ),
          if (images.length > maxImages)
            Positioned(
              left: maxImages * (size * 0.6),
              child: Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: size * 0.4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blackPrimary,
                  borderRadius: BorderRadius.circular(size / 2),
                  border: Border.all(color: AppColors.white),
                ),
                constraints: BoxConstraints(minHeight: size),
                alignment: Alignment.center,
                child: Text(
                  '+\${images.length - maxImages}',
                  style: context.l3.copyWith(
                    fontSize: size * 0.3,
                    color: AppColors.blackPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
''';

const String starRatingWidgetTemplate = '''
import 'package:{{project_name}}/exports.dart';

class StarRatingWidget extends StatelessWidget {
  const StarRatingWidget({
    required this.rating,
    this.maxRating = 5,
    this.starSize = 16.0,
    this.spacing = 4.0,
    this.showEmptyStars = true,
    super.key,
  });

  /// The user's rating (0 to maxRating)
  final int rating;

  /// Maximum rating value (default: 5)
  final int maxRating;

  /// Size of each star icon
  final double starSize;

  /// Spacing between stars
  final double spacing;

  /// Whether to show empty stars for unfilled ratings
  final bool showEmptyStars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final isFilled = index < rating;
        
        return Padding(
          padding: EdgeInsets.only(
            right: index < maxRating - 1 ? spacing : 0,
          ),
          child: SvgPicture.asset(
            isFilled 
              ? AssetPaths.starFilledIcon 
              : AssetPaths.starUnfilledIcon,
            width: starSize,
            height: starSize,
          ),
        );
      }),
    );
  }
}
''';

const String switchTemplate = '''
import 'package:{{project_name}}/exports.dart';

class RMBSwitch extends StatelessWidget {
  const RMBSwitch({
    required this.switchValue,
    required this.onSwitchChanged,
    this.title,
    this.backgroundColor,
    super.key,
  });

  final String? title;
  final bool switchValue;
  final ValueChanged<bool> onSwitchChanged;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: backgroundColor ?? AppColors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (title != null)
            Text(
              title!,
              style: context.t3.copyWith(color: AppColors.blackPrimary),
            ),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: switchValue,
              onChanged: onSwitchChanged,
              activeColor: AppColors.blackPrimary,
              activeTrackColor: AppColors.blackPrimary,
              inactiveTrackColor: AppColors.blackPrimary,
              inactiveThumbColor: AppColors.blackPrimary,
              trackOutlineColor: WidgetStateProperty.all(
                AppColors.blackPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
''';

const String textButtonTemplate = '''
import 'package:{{project_name}}/exports.dart';

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
        foregroundColor: AppColors.blackPrimary,
        overlayColor: Colors.transparent,
      ),
      child: Text(text, style: textStyle ?? context.h2.copyWith(fontSize: 16)),
    );
  }
}
''';

const String textFieldTemplate = '''
import 'package:{{project_name}}/core/field_validators.dart';
import 'package:{{project_name}}/exports.dart';

/// Types of text fields supported by the CustomTextField widget
enum CustomTextFieldType { email, password, description, number, text, search }

/// Configuration for text field styling and behavior
class TextFieldConfig {
  const TextFieldConfig({
    this.maxLines = 1,
    this.maxLength = 100,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.borderRadius = 100.0,
    this.contentPadding,
    this.inputFormatters,
  });

  final int maxLines;
  final int maxLength;
  final TextInputType keyboardType;
  final bool obscureText;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final List<TextInputFormatter>? inputFormatters;

  /// Predefined configurations for different text field types
  static const TextFieldConfig email = TextFieldConfig(
    keyboardType: TextInputType.emailAddress,
  );

  static const TextFieldConfig password = TextFieldConfig(
    keyboardType: TextInputType.visiblePassword,
    obscureText: true,
  );

  static const TextFieldConfig description = TextFieldConfig(
    maxLines: 5,
    maxLength: 200,
    borderRadius: 18,
    contentPadding: EdgeInsetsDirectional.only(start: 16, top: 24),
  );

  static final TextFieldConfig number = TextFieldConfig(
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  );

  static const TextFieldConfig text = TextFieldConfig();

  static const TextFieldConfig search = TextFieldConfig(
    keyboardType: TextInputType.text,
  );
}

/// Configuration for text field icons
class TextFieldIconConfig {
  const TextFieldIconConfig({
    this.prefixPath,
    this.prefix,
    this.suffixPath,
    this.suffix,
    this.suffixColor,
  });

  final String? prefixPath;
  final Widget? prefix;
  final String? suffixPath;
  final Widget? suffix;
  final Color? suffixColor;
}

/// A highly customizable text field widget with built-in support for common field types
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    required this.controller,
    this.type = CustomTextFieldType.text,
    this.config,
    this.iconConfig,
    this.padding = EdgeInsets.zero,
    this.labelText,
    this.hintText,
    this.hintColor,
    this.validator,
    this.readOnly,
    this.onTap,
    this.onChanged,
    this.enabled = true,
    this.enableRealTimeValidation = true,
    this.showValidation = false,
    this.focusNode,
    this.suffixOnTap,
    this.prefixOnTap,
    this.onSearch,
    this.showSuffixAlways = false,
    this.filterCount,
    this.showFilterIcon = true,
    this.prefix,
    this.backgroundColor,
    this.textStyle,
    this.suffix,
    super.key,
  });

  /// Creates a number text field
  factory CustomTextField.number({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? Function(String?)? validator,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    bool enabled = true,
    bool showValidation = false,
    FocusNode? focusNode,
    TextFieldConfig? config,
    Key? key,
  }) {
    return CustomTextField(
      controller: controller,
      type: CustomTextFieldType.number,
      config: config ?? TextFieldConfig.number,
      labelText: labelText,
      hintText: hintText,
      validator: validator ?? FieldValidators.numberValidator,
      padding: padding,
      enabled: enabled,
      showValidation: showValidation,
      focusNode: focusNode,
      key: key,
    );
  }

  /// Creates a normal text field
  factory CustomTextField.normal({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? Function(String?)? validator,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    bool enabled = true,
    bool enableRealTimeValidation = false,
    bool showValidation = false,
    FocusNode? focusNode,
    Key? key,
  }) {
    return CustomTextField(
      controller: controller,
      config: TextFieldConfig.text,
      labelText: labelText,
      hintText: hintText,
      validator: validator ?? FieldValidators.textValidator,
      padding: padding,
      enabled: enabled,
      enableRealTimeValidation: enableRealTimeValidation,
      showValidation: showValidation,
      focusNode: focusNode,
      key: key,
    );
  }

  /// Creates an email text field
  factory CustomTextField.email({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? Function(String?)? validator,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    bool enabled = true,
    bool enableRealTimeValidation = false,
    FocusNode? focusNode,
    Widget? suffix,
    Color? backgroundColor,
    Key? key,
  }) {
    return CustomTextField(
      controller: controller,
      type: CustomTextFieldType.email,
      config: TextFieldConfig.email,
      labelText: labelText,
      hintText: hintText,
      validator: validator ?? FieldValidators.emailValidator,
      padding: padding,
      enabled: enabled,
      enableRealTimeValidation: enableRealTimeValidation,
      focusNode: focusNode,
      suffix: suffix,
      backgroundColor: backgroundColor,
      key: key,
    );
  }

  /// Creates a password text field
  factory CustomTextField.password({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? Function(String?)? validator,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    bool enabled = true,
    FocusNode? focusNode,
    Key? key,
  }) {
    return CustomTextField(
      controller: controller,
      type: CustomTextFieldType.password,
      config: TextFieldConfig.password,
      labelText: labelText,
      hintText: hintText,
      validator: validator ?? FieldValidators.passwordValidator,
      padding: padding,
      enabled: enabled,
      focusNode: focusNode,
      key: key,
    );
  }

  /// Creates a description text field
  factory CustomTextField.description({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? Function(String?)? validator,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    bool enabled = true,
    bool showValidation = false,
    FocusNode? focusNode,
    Key? key,
  }) {
    return CustomTextField(
      controller: controller,
      type: CustomTextFieldType.description,
      config: TextFieldConfig.description,
      labelText: labelText,
      hintText: hintText,
      validator: validator ?? FieldValidators.textValidator,
      padding: padding,
      enabled: enabled,
      showValidation: showValidation,
      focusNode: focusNode,
      key: key,
    );
  }

  /// Creates a phone number text field
  factory CustomTextField.phone({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? Function(String?)? validator,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    bool enabled = true,
    bool enableRealTimeValidation = false,
    bool showValidation = false,
    FocusNode? focusNode,
    Widget? prefix,
    TextFieldConfig? config,
    Key? key,
  }) {
    return CustomTextField(
      controller: controller,
      type: CustomTextFieldType.number,
      config: config ?? TextFieldConfig.number,
      labelText: labelText,
      hintText: hintText,
      validator: validator ?? FieldValidators.phoneValidator,
      padding: padding,
      enabled: enabled,
      enableRealTimeValidation: enableRealTimeValidation,
      showValidation: showValidation,
      focusNode: focusNode,
      key: key,
      prefix: prefix,
    );
  }

  /// Creates a search text field
  factory CustomTextField.search({
    required TextEditingController controller,
    String? hintText,
    void Function(String)? onChanged,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    bool enabled = true,
    FocusNode? focusNode,
    VoidCallback? suffixOnTap,
    VoidCallback? prefixOnTap,
    VoidCallback? onSearch,
    bool showSuffixAlways = false,
    int? filterCount,
    bool showFilterIcon = true,
    Key? key,
  }) {
    return CustomTextField(
      controller: controller,
      type: CustomTextFieldType.search,
      config: TextFieldConfig.search,
      hintText: hintText,
      onChanged: onChanged,
      padding: padding,
      enabled: enabled,
      focusNode: focusNode,
      suffixOnTap: suffixOnTap,
      prefixOnTap: prefixOnTap,
      onSearch: onSearch,
      showSuffixAlways: showSuffixAlways,
      filterCount: filterCount,
      showFilterIcon: showFilterIcon,
      key: key,
    );
  }

  /// Controller for the text field
  final TextEditingController controller;

  /// Type of text field (determines default configuration)
  final CustomTextFieldType type;

  /// Custom configuration for styling and behavior
  final TextFieldConfig? config;

  /// Configuration for icons
  final TextFieldIconConfig? iconConfig;

  /// Padding around the text field
  final EdgeInsetsGeometry padding;

  /// Label text displayed above the field
  final String? labelText;

  /// Hint text displayed inside the field
  final String? hintText;

  /// Color of the hint text
  final Color? hintColor;

  /// Validation function
  final String? Function(String?)? validator;

  /// Whether the field is read-only
  final bool? readOnly;

  /// Callback when the field is tapped
  final VoidCallback? onTap;

  /// Callback when the text changes
  final void Function(String)? onChanged;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether to validate in real-time
  final bool enableRealTimeValidation;

  /// Optional focus node
  final FocusNode? focusNode;

  /// Callback when the suffix icon is tapped
  final VoidCallback? suffixOnTap;

  /// Callback when the prefix icon is tapped
  final VoidCallback? prefixOnTap;

  /// Callback when search action is triggered (keyboard search button or prefix tap)
  final VoidCallback? onSearch;

  /// Whether to show suffix icon always (for search field)
  final bool showSuffixAlways;

  /// Filter count to display as badge on suffix icon
  final int? filterCount;

  /// Whether to show the filter icon in search field (default true)
  final bool showFilterIcon;

  /// Custom prefix widget (overrides iconConfig.prefixPath)
  final Widget? prefix;

  /// Background color of the text field
  final Color? backgroundColor;

  /// Text style for the input text
  final TextStyle? textStyle;

  /// Custom suffix widget (overrides iconConfig.suffixPath)
  final Widget? suffix;

  /// Controls when validation errors should be shown (typically after form submission)
  final bool showValidation;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final FocusNode _focusNode;
  late final bool _isExternalFocusNode;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _isExternalFocusNode = widget.focusNode != null;
    _focusNode = widget.focusNode ?? FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_focusNode.hasFocus) {
        _focusNode.canRequestFocus = true;
      }
    });
  }

  @override
  void dispose() {
    if (!_isExternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  /// Gets the effective configuration for this text field
  TextFieldConfig get _effectiveConfig {
    return widget.config ?? _getDefaultConfigForType(widget.type);
  }

  /// Gets the effective icon configuration for this text field
  TextFieldIconConfig get _effectiveIconConfig {
    return widget.iconConfig ?? const TextFieldIconConfig();
  }

  /// Gets default configuration based on field type
  TextFieldConfig _getDefaultConfigForType(CustomTextFieldType type) {
    switch (type) {
      case CustomTextFieldType.email:
        return TextFieldConfig.email;
      case CustomTextFieldType.password:
        return TextFieldConfig.password;
      case CustomTextFieldType.description:
        return TextFieldConfig.description;
      case CustomTextFieldType.number:
        return TextFieldConfig.number;
      case CustomTextFieldType.search:
        return TextFieldConfig.search;
      case CustomTextFieldType.text:
        return TextFieldConfig.text;
    }
  }

  /// Handles text changes
  void _onChanged(String value) {
    widget.onChanged?.call(value);
  }

  /// Toggles password visibility
  void _togglePasswordVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  /// Creates the border decoration
  InputBorder _createBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color),
      borderRadius: BorderRadius.all(
        Radius.circular(_effectiveConfig.borderRadius),
      ),
    );
  }

  /// Creates the error border
  InputBorder _createErrorBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.error),
      borderRadius: BorderRadius.all(
        Radius.circular(_effectiveConfig.borderRadius),
      ),
    );
  }

  /// Builds the prefix icon widget
  Widget? _buildPrefixIcon() {
    if (widget.prefix != null) {
      return widget.prefix;
    }
    if (widget.type == CustomTextFieldType.search) {
      return _buildSearchPrefixIcon();
    }

    final iconConfig = _effectiveIconConfig;
    if (iconConfig.prefix != null) {
      return iconConfig.prefix;
    }

    if (iconConfig.prefixPath != null) {
      return _buildIconFromPath(
        iconConfig.prefixPath!,
        const EdgeInsetsDirectional.only(bottom: 8, top: 8, start: 16, end: 8),
      );
    }

    return null;
  }

  /// Builds the search prefix icon
  Widget _buildSearchPrefixIcon() {
    return GestureDetector(
      onTap: widget.prefixOnTap ?? widget.onSearch,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          bottom: 8,
          top: 8,
          start: 16,
          end: 8,
        ),
        child: SvgPicture.asset(AssetPaths.searchIcon),
      ),
    );
  }

  /// Builds the suffix icon widget
  Widget? _buildSuffixIcon() {
    if (widget.suffix != null) {
      return widget.suffix;
    }
    if (widget.type == CustomTextFieldType.search) {
      if (!widget.showFilterIcon) return null;
      return _buildSearchSuffixIcon();
    }

    if (widget.type == CustomTextFieldType.password) {
      return _buildPasswordSuffixIcon();
    }

    final iconConfig = _effectiveIconConfig;
    if (iconConfig.suffix != null) {
      return iconConfig.suffix;
    }

    if (iconConfig.suffixPath != null) {
      return _buildIconFromPath(
        iconConfig.suffixPath!,
        const EdgeInsets.symmetric(horizontal: 12),
        color: iconConfig.suffixColor,
      );
    }

    return null;
  }

  /// Builds the search suffix icon
  Widget _buildSearchSuffixIcon() {
    final shouldShow = widget.showSuffixAlways || _focusNode.hasFocus;

    return Visibility(
      visible: shouldShow,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 8,
          end: 22,
          top: 8,
          bottom: 8,
        ),
        child: FilterIconWidget(
          filterCount: widget.filterCount,
        ),
      ),
    );
  }

  /// Builds the password suffix icon
  Widget _buildPasswordSuffixIcon() {
    return GestureDetector(
      onTap: _togglePasswordVisibility,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SvgPicture.asset(
          _obscureText ? AssetPaths.dummyIcon : AssetPaths.dummyIcon,
        ),
      ),
    );
  }

  /// Builds an icon from asset path with custom padding and color
  Widget _buildIconFromPath(
    String path,
    EdgeInsetsGeometry padding, {
    Color? color,
  }) {
    return Padding(
      padding: padding,
      child: SvgPicture.asset(
        path,
        width: 16,
        colorFilter:
            color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _effectiveConfig;

    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.labelText != null) ...[
            Text(
              widget.labelText!,
              style: context.b1.copyWith(color: AppColors.blackPrimary),
            ),
            const SizedBox(height: 8),
          ],
          ListenableBuilder(
            listenable: Listenable.merge([_focusNode, widget.controller]),
            builder: (context, child) {
              final hasFocus = _focusNode.hasFocus;
              // Check for errors to show error border
              final validationError = widget.showValidation && widget.validator != null
                  ? widget.validator!(widget.controller.text)
                  : null;
              final hasError = validationError != null && validationError.isNotEmpty;
              
              return TextFormField(
                cursorWidth: 1.5,
                cursorHeight: 22,
                controller: widget.controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                readOnly: widget.readOnly ?? false,
                obscureText: config.obscureText ? _obscureText : false,
                obscuringCharacter: '*',
                keyboardType: config.keyboardType,
                textInputAction: widget.type == CustomTextFieldType.search
                    ? TextInputAction.search
                    : TextInputAction.done,
                maxLines: config.maxLines,
                maxLength: config.maxLength,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                inputFormatters: config.inputFormatters,
                style: widget.textStyle ?? context.b2,
                cursorColor: AppColors.blackPrimary,
                autovalidateMode: (widget.enableRealTimeValidation && widget.showValidation)
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                onChanged: _onChanged,
                onFieldSubmitted: widget.type == CustomTextFieldType.search
                    ? (_) => widget.onSearch?.call()
                    : null,
                validator: widget.validator,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  filled: true,
                  fillColor: hasFocus
                      ? AppColors.textFieldBackground
                      : widget.backgroundColor ?? AppColors.white,
                  hintStyle: context.b2.copyWith(
                    color: widget.hintColor ?? AppColors.textSecondary,
                  ),
                  counterText: '',
                  border: _createBorder(_getBorderColorFromFocus(hasFocus, hasError)),
                  enabledBorder: _createBorder(
                    _getBorderColorFromFocus(hasFocus, hasError),
                  ),
                  focusedBorder: _createBorder(
                    _getBorderColorFromFocus(hasFocus, hasError),
                  ),
                  errorBorder: _createErrorBorder(),
                  focusedErrorBorder: _createErrorBorder(),
                  errorStyle: const TextStyle(height: 0, fontSize: 0),
                  prefixIcon: _buildPrefixIcon(),
                  suffixIcon: _buildSuffixIcon() != null
                      ? GestureDetector(
                          onTap: widget.suffixOnTap,
                          child: _buildSuffixIcon(),
                        )
                      : null,
                  contentPadding:
                      config.contentPadding ?? const EdgeInsets.all(12),
                ),
              );
            },
          ),
          // Always reserve fixed space for error when field has validator so layout never shifts
          if (widget.validator != null)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller,
              builder: (context, value, child) {
                final validationError = widget.showValidation
                    ? widget.validator!(value.text)
                    : null;
                final hasError = validationError != null && validationError.isNotEmpty;
                const errorAreaHeight = 24.0;
                // Allow enough height for 2 lines so long messages (e.g. postal code) don't clip
                const errorAreaHeightWithError = 40.0;
                return SizedBox(
                  height: hasError ? errorAreaHeightWithError : errorAreaHeight,
                  child: hasError
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6, left: 12, right: 12),
                          child: Text(
                            validationError,
                            style: context.b3.copyWith(
                              color: AppColors.error,
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Gets the border color based on focus state (for ValueListenableBuilder)
  Color _getBorderColorFromFocus(bool hasFocus, [bool hasError = false]) {
    if (!widget.enabled) return AppColors.textTertiary;
    if (hasError) return AppColors.error;
    if (hasFocus) return AppColors.blackPrimary;
    return AppColors.textTertiary;
  }
}
''';

const String tileTemplate = '''
import 'package:{{project_name}}/exports.dart';

class RMBTile extends StatelessWidget {
  const RMBTile({
    required this.label,
    super.key,
    this.showIcon = false,
    this.onTap,
    this.iconPath,
  });

  final String label;
  final bool showIcon;
  final VoidCallback? onTap;
  final String? iconPath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.blackPrimary,
          borderRadius: BorderRadius.circular(44),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.blackPrimary,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
            if (showIcon)
              if (iconPath!.contains('svg'))
                SvgPicture.asset(iconPath!)
              else
                Image.asset(iconPath!),
          ],
        ),
      ),
    );
  }
}
''';

const String timePickerTemplate = '''
import 'package:flutter/cupertino.dart';
import 'package:{{project_name}}/exports.dart';

class RMBTimePicker extends StatefulWidget {
  const RMBTimePicker({
    required this.onTimeSelected,
    super.key,
    this.initialTime,
  });

  final dynamic Function(DateTime) onTimeSelected;

  final DateTime? initialTime;

  @override
  State<RMBTimePicker> createState() => _RMBTimePickerState();
}

class _RMBTimePickerState extends State<RMBTimePicker> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return SizedBox(
      height: 200,
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        initialDateTime: widget.initialTime ?? now,
        onDateTimeChanged: widget.onTimeSelected,
        backgroundColor: AppColors.white,
      ),
    );
  }
}
''';

const String titleRowTemplate = '''
// import 'package:activ/exports.dart';
// import 'package:activ/l10n/localization_service.dart';
// import 'package:activ/utils/widgets/core_widgets/chips.dart';

// class ActivTitleRowWidget extends StatelessWidget {
//   const ActivTitleRowWidget({
//     required this.titleText,
//     this.onTap,
//     this.buttonText,
//     this.showButton = true,
//     super.key,
//   });

//   final String titleText;
//   final String? buttonText;
//   final VoidCallback? onTap;
//   final bool showButton;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsetsDirectional.symmetric(
//         vertical: 16,
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 titleText,
//                 style: context.b1.copyWith(
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               if (showButton)
//                 ActivChip.secondary(
//                   text: buttonText ?? Localization.viewAll,
//                   textStyle: context.b3.copyWith(
//                     color: AppColors.greenSecondary,
//                   ),
//                   onTap: onTap,
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
''';

// --- Extra widget files (referenced by core widgets export) ---

const String blurOverlayTemplate = '''
import 'dart:ui';

import 'package:{{project_name}}/exports.dart';

class BlurOverlay extends StatelessWidget {
  const BlurOverlay({
    required this.onDismiss,
    super.key,
    this.blurStrength = 6.3,
    this.scrimOpacity = 0.01,
    this.scrimColor = const Color(0xFF40475B),
  });

  final VoidCallback onDismiss;
  final double blurStrength;
  final double scrimOpacity;
  final Color scrimColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onDismiss,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: blurStrength,
              sigmaY: blurStrength,
            ),
            child: SizedBox.expand(
              child: Container(
                color: scrimColor.withValues(alpha: scrimOpacity),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
''';

const String filterIconWidgetTemplate = '''
import 'package:{{project_name}}/exports.dart';

class FilterIconWidget extends StatelessWidget {
  const FilterIconWidget({this.filterCount, this.iconSize = 24.0, super.key});

  final int? filterCount;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          AssetPaths.filterIcon,
          width: iconSize,
          height: iconSize,
        ),
        if (filterCount != null && filterCount! > 0)
          Positioned(
            right: -4,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
              decoration: const BoxDecoration(
                color: AppColors.blackPrimary,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text(
                filterCount!.toString().padLeft(2, '0'),
                style: context.l3.secondary.copyWith(fontSize: 8),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
''';

// --- Extra helper files (referenced by core widgets) ---

const String cartNotificationHelperTemplate = '''
import 'package:flutter/material.dart';
import 'package:{{project_name}}/utils/widgets/core_widgets/sliding_cart_notification.dart';

class CartNotificationHelper {
  static OverlayEntry? _currentOverlay;

  static void showCartNotification({
    required BuildContext context,
    required String productName,
    required int quantity,
    String? size,
    Color? color,
  }) {
    // Remove any existing notification
    _currentOverlay?.remove();

    // Create new overlay entry
    _currentOverlay = OverlayEntry(
      builder: (context) => SlidingCartNotification(
        productName: productName,
        quantity: quantity,
        size: size,
        color: color,
      ),
    );

    // Insert the overlay
    Overlay.of(context).insert(_currentOverlay!);

    // Auto remove after animation
    Future.delayed(const Duration(milliseconds: 3000), () {
      _currentOverlay?.remove();
      _currentOverlay = null;
    });
  }

  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}
''';

const String datetimeHelperTemplate = '''
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Helper class to combine separate date and time controllers
///
/// Example usage:
/// ```dart
/// final dateController = TextEditingController();
/// final timeController = TextEditingController();
///
/// // After user selects date and time via ActivTextField
/// final isoDateTime = DateTimeHelper.combineToIsoString(
///   dateController: dateController,
///   timeController: timeController,
/// );
///
/// if (isoDateTime != null) {
///   // Send to API: "2025-06-15T14:00:00.000Z"
///   print('Combined DateTime: \$isoDateTime');
/// }
/// ```
class DateTimeHelper {
  /// Combines separate date and time controllers into an ISO datetime string
  ///
  /// [dateController] - Controller containing date in "dd/MM/yyyy" format
  /// [timeController] - Controller containing time in "hh:mm AM/PM" format
  ///
  /// Returns: ISO datetime string like "2025-06-15T14:00:00.000Z"
  /// Returns null if either controller is empty or contains invalid data
  static String? combineToIsoString({
    required TextEditingController dateController,
    required TextEditingController timeController,
  }) {
    try {
      final dateText = dateController.text.trim();
      final timeText = timeController.text.trim();

      if (dateText.isEmpty || timeText.isEmpty) {
        return null;
      }

      // Parse date from "dd/MM/yyyy" format
      final dateFormat = DateFormat('dd/MM/yyyy');
      final date = dateFormat.parse(dateText);

      // Parse time from "hh:mm AM/PM" format
      final timeFormat = DateFormat('hh:mm a');
      final time = timeFormat.parse(timeText);

      // Combine date and time
      final combinedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // Convert to UTC and return ISO string
      return combinedDateTime.toIso8601String();
    } catch (e) {
      // Return null if parsing fails
      return null;
    }
  }

  /// Combines date and time controllers into a DateTime object
  ///
  /// [dateController] - Controller containing date in "dd/MM/yyyy" format
  /// [timeController] - Controller containing time in "hh:mm AM/PM" format
  ///
  /// Returns: DateTime object or null if parsing fails
  static DateTime? combineToDateTime({
    required TextEditingController dateController,
    required TextEditingController timeController,
  }) {
    try {
      final dateText = dateController.text.trim();
      final timeText = timeController.text.trim();

      if (dateText.isEmpty || timeText.isEmpty) {
        return null;
      }

      // Parse date from "dd/MM/yyyy" format
      final dateFormat = DateFormat('dd/MM/yyyy');
      final date = dateFormat.parse(dateText);

      // Parse time from "hh:mm AM/PM" format
      final timeFormat = DateFormat('hh:mm a');
      final time = timeFormat.parse(timeText);

      // Combine date and time
      return DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    } catch (e) {
      // Return null if parsing fails
      return null;
    }
  }

  /// Sets separate date and time controllers from an ISO datetime string
  ///
  /// [isoString] - ISO datetime string like "2025-06-15T14:00:00.000Z"
  /// [dateController] - Controller to set date in "dd/MM/yyyy" format
  /// [timeController] - Controller to set time in "hh:mm AM/PM" format
  static void setFromIsoString({
    required String isoString,
    required TextEditingController dateController,
    required TextEditingController timeController,
  }) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();

      // Set date controller
      final dateFormat = DateFormat('dd/MM/yyyy');
      dateController.text = dateFormat.format(dateTime);

      // Set time controller
      final timeFormat = DateFormat('hh:mm a');
      timeController.text = timeFormat.format(dateTime);
    } catch (e) {
      // Clear controllers if parsing fails
      dateController.clear();
      timeController.clear();
    }
  }

  /// Validates if both date and time controllers have valid values
  ///
  /// [dateController] - Controller containing date
  /// [timeController] - Controller containing time
  ///
  /// Returns: true if both controllers have valid values
  static bool isValidDateTimeInput({
    required TextEditingController dateController,
    required TextEditingController timeController,
  }) {
    return combineToDateTime(
          dateController: dateController,
          timeController: timeController,
        ) !=
        null;
  }

  /// Formats a DateTime to a user-friendly display format
  ///
  /// Example: DateTime(2025, 3, 24) -> "24th March, 2025"
  ///
  /// [date] - DateTime to format
  ///
  /// Returns: Formatted string like "24th March, 2025"
  static String formatDateOfBirth(DateTime date) {
    final day = date.day;
    final suffix = _getDaySuffix(day);
    final monthName = DateFormat('MMMM').format(date);
    final year = date.year;

    return '\$day\$suffix \$monthName, \$year';
  }

  /// Gets the ordinal suffix for a day number (st, nd, rd, th)
  static String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// Parses a date string and formats it for display
  ///
  /// [dateString] - ISO date string or any parseable date format
  ///
  /// Returns: Formatted string like "24th March, 2025" or null if parsing fails
  static String? formatDateOfBirthFromString(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      final date = DateTime.parse(dateString);
      return formatDateOfBirth(date);
    } catch (e) {
      return null;
    }
  }

  /// Calculates age from a date of birth
  ///
  /// [dateOfBirth] - Date of birth
  ///
  /// Returns: Age in years
  static int calculateAge(DateTime dateOfBirth) {
    final today = DateTime.now();
    var age = today.year - dateOfBirth.year;

    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }

    return age;
  }
}
''';
