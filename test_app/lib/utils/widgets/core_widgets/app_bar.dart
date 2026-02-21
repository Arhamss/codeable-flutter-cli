import 'package:test_app/exports.dart';

/// Universal round, fixed-size back button for app bars.
class AppBarBackButton extends StatelessWidget {
  const AppBarBackButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppBarCircleButton(
      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
      onPressed: onPressed ?? () => context.pop(),
      backgroundColor: Colors.white,
    );
  }
}

/// Universal round, fixed-size circle button for app bar leading/actions.
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

const EdgeInsets _appBarLeadingPadding = EdgeInsets.only(
  left: 16,
  bottom: 8,
  top: 8,
);

/// Custom AppBar widget matching the app design pattern.
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
    leadingWidth: 16 + 40,
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
