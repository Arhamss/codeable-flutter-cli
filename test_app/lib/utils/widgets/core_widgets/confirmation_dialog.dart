import 'package:test_app/exports.dart';

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 8),
              blurRadius: 32,
              color: AppColors.primary.withValues(alpha: 0.1),
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
                        : AppColors.primary.withValues(alpha: 0.1),
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
                  color: AppColors.textPrimary,
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
                  color: AppColors.textSecondary,
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
                        : AppColors.primary,
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
                    textColor: AppColors.primary,
                    backgroundColor: Colors.white,
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
      barrierColor: AppColors.primary.withValues(alpha: 0.6),
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
