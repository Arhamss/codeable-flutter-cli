const appColorsTemplate = '''
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF000000);
  static const Color secondary = Color(0xFF666666);
  static const Color accent = Color(0xFF2196F3);

  // Background
  static const Color backgroundPrimary = Color(0xFFF5F5F5);
  static const Color backgroundSecondary = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border
  static const Color borderPrimary = Color(0xFFE0E0E0);
  static const Color borderSecondary = Color(0xFFF0F0F0);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  static const Color red = Color(0xFFF44336);

  // Status backgrounds
  static const Color positiveBottomStatusBackground = Color(0xFFE8F5E9);
  static const Color warningBottomStatusBackground = Color(0xFFFFF8E1);

  // Misc
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color disabled = Color(0xFFBDBDBD);
}
''';

const appTextStyleTemplate = '''
import 'package:flutter/material.dart';
import 'package:{{project_name}}/constants/app_colors.dart';

const String _fontFamily = 'DMSans';

extension AppTextStyle on BuildContext {
  // Headers
  TextStyle get h1 => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  TextStyle get h2 => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  TextStyle get h3 => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // Titles
  TextStyle get t1 => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  TextStyle get t2 => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  TextStyle get t3 => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // Body
  TextStyle get b1 => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  TextStyle get b2 => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  TextStyle get b3 => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  // Labels
  TextStyle get l1 => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  TextStyle get l2 => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  TextStyle get l3 => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );
}
''';

const assetPathsTemplate = '''
class AssetPaths {
  AssetPaths._();

  // Images
  static const String appLogo = 'assets/images/app_logo.png';

  // SVGs
  // static const String homeIcon = 'assets/svgs/home_icon.svg';

  // Animations
  // static const String loadingAnimation = 'assets/animation/loading.json';
}
''';

const constantsTemplate = '''
class AppConstants {
  AppConstants._();

  static const String appName = '{{ProjectName}}';
  static const int paginationLimit = 16;
}
''';

const constantsExportTemplate = '''
export 'app_colors.dart';
export 'app_text_style.dart';
export 'asset_paths.dart';
export 'constants.dart';
''';
