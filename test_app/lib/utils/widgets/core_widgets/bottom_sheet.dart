import 'package:test_app/exports.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({
    required this.title,
    this.subtitle,
    this.imageWidget,
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
  final String? subtitle;
  final Widget? imageWidget;
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
    String? subtitle,
    Widget? imageWidget,
    String? buttonOneText,
    String? buttonTwoText,
    VoidCallback? buttonOneOnTap,
    VoidCallback? buttonTwoOnTap,
    Color? buttonOneColor,
    Color? buttonTwoColor,
    Color? buttonOneTextColor,
    Color? buttonTwoTextColor,
    double? height,
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
        final bottomPadding =
            safeAreaBottom ? mediaQuery.padding.bottom : 0.0;
        final contentHeight = height != null
            ? (mediaQuery.size.height - mediaQuery.viewPadding.top) * height
            : null;
        final totalHeight =
            contentHeight != null ? contentHeight + bottomPadding : null;

        return Padding(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: Container(
            height: totalHeight,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
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
                    title: title,
                    subtitle: subtitle,
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
                color: AppColors.disabled,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 16),
            if (imageWidget != null) ...[
              imageWidget!,
              const SizedBox(height: 20),
            ],
            Text(title, style: context.t1),
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
                          textColor:
                              buttonOneTextColor ?? AppColors.textOnPrimary,
                          backgroundColor:
                              buttonOneColor ?? AppColors.primary,
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
                          textColor:
                              buttonTwoTextColor ?? AppColors.textOnPrimary,
                          onPressed: buttonTwoOnTap,
                          isLoading: isLoading,
                          backgroundColor:
                              buttonTwoColor ?? AppColors.error,
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
                      textColor:
                          buttonOneTextColor ?? AppColors.textOnPrimary,
                      backgroundColor:
                          buttonOneColor ?? AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      padding: const EdgeInsetsDirectional.symmetric(
                        vertical: 12,
                      ),
                      text: buttonTwoText ?? '',
                      textColor:
                          buttonTwoTextColor ?? AppColors.textOnPrimary,
                      onPressed: buttonTwoOnTap,
                      isLoading: isLoading,
                      backgroundColor:
                          buttonTwoColor ?? AppColors.error,
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
