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
import 'package:google_fonts/google_fonts.dart';

extension AppTextStyle on BuildContext {
  // Headers
  TextStyle get h1 => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A1A),
      );

  TextStyle get h2 => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A1A),
      );

  TextStyle get h3 => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      );

  // Titles
  TextStyle get t1 => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      );

  TextStyle get t2 => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      );

  TextStyle get t3 => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      );

  // Body
  TextStyle get b1 => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF1A1A1A),
      );

  TextStyle get b2 => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF1A1A1A),
      );

  TextStyle get b3 => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF1A1A1A),
      );

  // Labels
  TextStyle get l1 => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF666666),
      );

  TextStyle get l2 => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF666666),
      );

  TextStyle get l3 => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF666666),
      );
}
''';

const assetPathsTemplate = '''
class AssetPaths {
  AssetPaths._();

  // Images
  static const String appLogo = 'assets/images/app_logo.png';

  // Vectors
  // static const String homeIcon = 'assets/vectors/home_icon.svg';

  // Lottie
  // static const String loadingAnimation = 'assets/lottie/loading.json';
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
