import 'package:test_app/exports.dart';

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
              foregroundColor: Colors.white,
              backgroundColor: AppColors.error,
            ),
            child: Text(
              'Retry',
              style: context.b2.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
