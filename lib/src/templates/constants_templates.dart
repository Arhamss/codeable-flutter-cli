const appColorsTemplate = '''
import 'dart:ui';

abstract class AppColors {
  // ── Background & Surfaces ──
  static const background = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF1F3F6);
  static const surfaceMuted = Color(0xFFE7EBEF);
  static const navBar = Color(0xFFFFFFFF);

  // ── Primary ──
  static const primary = Color(0xFF0D121C);
  static const primaryLight = Color(0xFF2A3240);
  static const primaryMuted = Color(0xFF4A5568);
  static const primarySoft = Color(0xFFE8EBF0);

  // ── Text ──
  static const textPrimary = Color(0xFF0D121C);
  static const textOnPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF697586);
  static const textTertiary = Color(0xFF9AA4B2);

  // ── Status ──
  static const success = Color(0xFF22C661);
  static const error = Color(0xFFE8534E);
  static const warning = Color(0xFFE8A83D);
  static const info = Color(0xFF3B82F6);

  // ── Borders & Dividers ──
  static const border = Color(0xFFE1E5EA);
  static const divider = Color(0xFFECEFF2);

  // ── Shadows ──
  static const shadowLight = Color(0x0F000000);
  static const shadowMedium = Color(0x1A000000);

  // ── Misc ──
  static const disabled = Color(0xFFBDBDBD);
  static const transparent = Color(0x00000000);

  // ── Overlays ──
  static const overlayText = Color(0xFFFFFFFF);
  static const overlayTextMuted = Color(0xB3FFFFFF);
  static const overlayScrim = Color(0xFF000000);
}
''';

const appTextStyleTemplate = '''
import 'package:flutter/material.dart';
import 'package:{{project_name}}/constants/app_colors.dart';

abstract class AppFonts {
  static const heading = 'BBBPoppins';
  static const body = 'SFProRounded';
}

extension AppTextStyle on BuildContext {
  TextStyle _heading(
    double size,
    FontWeight weight, {
    Color color = AppColors.textPrimary,
    FontStyle fontStyle = FontStyle.normal,
    double height = 1.3,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: AppFonts.heading,
      fontSize: size,
      fontWeight: weight,
      fontStyle: fontStyle,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  TextStyle _body(
    double size,
    FontWeight weight, {
    Color color = AppColors.textPrimary,
    FontStyle fontStyle = FontStyle.normal,
    double height = 1.3,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: AppFonts.body,
      fontSize: size,
      fontWeight: weight,
      fontStyle: fontStyle,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  TextStyle get display => _heading(43, FontWeight.w400, height: 1.2);

  TextStyle get h1 => _heading(32, FontWeight.w400, height: 1.2);
  TextStyle get h1Medium => _heading(32, FontWeight.w500, height: 1.2);
  TextStyle get h1Bold => _heading(32, FontWeight.w700, height: 1.2);

  TextStyle get h2 => _heading(28, FontWeight.w400, height: 1.2);
  TextStyle get h2Medium => _heading(28, FontWeight.w500, height: 1.2);
  TextStyle get h2Bold => _heading(28, FontWeight.w700, height: 1.2);

  TextStyle get h3 => _heading(24, FontWeight.w400);
  TextStyle get h3Medium => _heading(24, FontWeight.w500);
  TextStyle get h3Bold => _heading(24, FontWeight.w700);

  TextStyle get h4 => _heading(20, FontWeight.w400);
  TextStyle get h4Medium => _heading(20, FontWeight.w500);
  TextStyle get h4Bold => _heading(20, FontWeight.w700);

  TextStyle get h5 => _heading(18, FontWeight.w400);
  TextStyle get h5Medium => _heading(18, FontWeight.w500);
  TextStyle get h5Bold => _heading(18, FontWeight.w700);

  TextStyle get p1 => _body(16, FontWeight.w400);
  TextStyle get p1Medium => _body(16, FontWeight.w500);
  TextStyle get p1Bold => _body(16, FontWeight.w700);

  TextStyle get p2 => _body(14, FontWeight.w400);
  TextStyle get p2Medium => _body(14, FontWeight.w500);
  TextStyle get p2Bold => _body(14, FontWeight.w700);

  TextStyle get caption => _body(12, FontWeight.w400);
  TextStyle get captionMedium => _body(12, FontWeight.w500);
  TextStyle get captionBold => _body(12, FontWeight.w700);

  TextStyle get overline => _body(10, FontWeight.w400);
}

extension TextStyleModifiers on TextStyle {
  TextStyle get primary => copyWith(color: AppColors.blackPrimary);
  TextStyle get secondary => copyWith(color: AppColors.white);
  TextStyle get light => copyWith(color: AppColors.textSecondary);
  TextStyle get hint => copyWith(color: AppColors.textTertiary);
}

extension TextStyleWithStyle on TextStyle {
  TextStyle withStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    FontStyle? fontStyle,
    String? fontFamily,
  }) {
    return copyWith(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
    );
  }
}
''';

const assetPathsTemplate = '''
class AssetPaths {
  const AssetPaths._();

  static const arrowLeftIcon = 'assets/vectors/arrow_left_icon.svg';
  static const googleIcon = 'assets/vectors/google_icon.svg';
  static const appleIcon = 'assets/vectors/apple_icon.svg';
  static const successIcon = 'assets/vectors/success_icon.svg';
  static const errorIcon = 'assets/vectors/error_icon.svg';
  static const infoIcon = 'assets/vectors/info_icon.svg';
  static const emblemDark = 'assets/vectors/emblem_dark.svg';
  static const emblemWhite = 'assets/vectors/emblem_white.svg';
  static const codeableDark = 'assets/vectors/codeable_dark.svg';
  static const codeableWhite = 'assets/vectors/codeable_white.svg';
  static const imageIcon = 'assets/vectors/image_icon.svg';

  /// Add SVG/PNG sources for these paths under `assets/vectors/` and `assets/images/`.
  static const tickIcon = 'assets/vectors/tick_icon.svg';
  static const searchIcon = 'assets/vectors/search_icon.svg';
  static const filterIcon = 'assets/vectors/filter_icon.svg';
  static const dropdownArrowIcon = 'assets/vectors/dropdown_arrow_icon.svg';
  static const starFilledIcon = 'assets/vectors/star_filled_icon.svg';
  static const starUnfilledIcon = 'assets/vectors/star_empty_icon.svg';
  static const dummyIcon = 'assets/images/dummy.png';
}
''';

const constantsTemplate = '''
class AppConstants {
  AppConstants._();

  static const String appName = '{{app_name}}';
  static const String privacyPolicy = 'https://example.com/privacy';
  static const String brandPlaceHolder = 'assets/images/placeholder_brand.png';
  static const String productPlaceHolder =
      'assets/images/product_placeholder.png';

  static const paginationLimit = 16;
  static const seeAllLimit = 1;

  static const int addressFieldMaxLength = 100;
  static const int phoneFieldMaxLength = 15;
  static const int defaultShippingCost = 250;
}
''';

const constantsExportTemplate = '''
export 'app_colors.dart';
export 'app_text_style.dart';
export 'asset_paths.dart';
export 'constants.dart';
''';
