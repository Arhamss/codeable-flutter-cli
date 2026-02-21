import 'package:test_app/exports.dart';
import 'package:toastification/toastification.dart';

class ToastHelper {
  static void showErrorToast(String? message) {
    toastification.show(
      type: ToastificationType.error,
      backgroundColor: AppColors.error,
      borderRadius: BorderRadius.circular(48),
      borderSide: BorderSide.none,
      icon: const Icon(
        Icons.cancel_outlined,
        color: AppColors.textOnPrimary,
        size: 18,
      ),
      title: Text(
        message ?? 'Something went wrong. Please try again later.',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: AppColors.textOnPrimary,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      closeButton: const ToastCloseButton(
        showType: CloseButtonShowType.none,
      ),
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
    );
  }

  static void showSuccessToast(String message) {
    toastification.show(
      type: ToastificationType.success,
      backgroundColor: AppColors.positiveBottomStatusBackground,
      borderRadius: BorderRadius.circular(48),
      borderSide: BorderSide.none,
      icon: const Icon(
        Icons.check_circle_outline,
        color: AppColors.success,
        size: 18,
      ),
      title: Text(
        message,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      closeButton: const ToastCloseButton(
        showType: CloseButtonShowType.none,
      ),
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
    );
  }

  static void showInfoToast(String message) {
    toastification.show(
      type: ToastificationType.info,
      backgroundColor: AppColors.warningBottomStatusBackground,
      borderRadius: BorderRadius.circular(48),
      borderSide: BorderSide.none,
      icon: const Icon(
        Icons.info_outline,
        color: AppColors.warning,
        size: 18,
      ),
      title: Text(
        message,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      closeButton: const ToastCloseButton(
        showType: CloseButtonShowType.none,
      ),
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
    );
  }

  static void showWarningToast(String message) {
    toastification.show(
      type: ToastificationType.warning,
      backgroundColor: AppColors.warningBottomStatusBackground,
      borderRadius: BorderRadius.circular(48),
      borderSide: BorderSide.none,
      icon: const Icon(
        Icons.warning_amber_outlined,
        color: AppColors.warning,
        size: 18,
      ),
      title: Text(
        message,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      closeButton: const ToastCloseButton(
        showType: CloseButtonShowType.none,
      ),
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
    );
  }
}
