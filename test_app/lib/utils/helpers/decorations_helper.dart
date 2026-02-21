import 'package:test_app/exports.dart';

class DecorationsHelper {
  DecorationsHelper._();

  static BoxDecoration whiteCard({
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        borderRadius ?? 16,
      ),
    );
  }

  static BoxDecoration bottomSheetTop({
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(
          borderRadius ?? 28,
        ),
      ),
    );
  }

  static BoxDecoration transparentCard({
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
  }) {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(
        borderRadius ?? 16,
      ),
      border: borderColor != null
          ? Border.all(
              color: borderColor,
              width: borderWidth ?? 1,
            )
          : null,
    );
  }

  static BoxDecoration circular({
    Color? color,
    Color? borderColor,
    double? borderWidth,
  }) {
    return BoxDecoration(
      color: color ?? Colors.transparent,
      shape: BoxShape.circle,
      border: borderColor != null
          ? Border.all(
              color: borderColor,
              width: borderWidth ?? 1,
            )
          : null,
    );
  }

  static List<BoxShadow> cardShadow({
    Color? color,
    double? blurRadius,
    double? spreadRadius,
    Offset? offset,
  }) {
    return [
      BoxShadow(
        color: color ?? AppColors.primary.withValues(alpha: 0.1),
        blurRadius: blurRadius ?? 12,
        spreadRadius: spreadRadius ?? 2,
        offset: offset ?? const Offset(0, 2),
      ),
    ];
  }
}
