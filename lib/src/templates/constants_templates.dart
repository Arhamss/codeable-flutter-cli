const appColorsTemplate = '''
import 'dart:ui';

abstract class AppColors {
  static const invalidLocationTooltip = Color(0xffFFF0EB);
  static const locationToolTipBorder = Color(0xffFF5136);
  static const positiveBottomStatusBorder = Color(0xff22C661);
  static const positiveBottomStatusBackground = Color(0xffE4F7EB);
  static const warningBottomStatusBorder = Color(0xffFFD336);
  static const warningBottomStatusBackground = Color(0xffFFFBEB);

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const error = Color(0xFFFF1E00);
  static const blackPrimary = Color(0xFF0D121C);
  static const blackPrimaryShade = Color(0xFF000000);
  static const secondaryMain = Color(0xFF454545);
  static const whitePrimary = Color(0xFFFCFCFC);
  static const neutral700 = Color(0xFF979A9C);

  /// Used by [UserAvatar]. First entry is the default (when [seed] is null).
  /// Remaining entries are picked deterministically by `seed.hashCode`.
  static const avatarGradients = [
    [blackPrimary, blackPrimaryShade],
    [Color(0xFFFE835F), Color(0xFFFF5668)],
    [Color(0xFFBC7AFA), Color(0xFFA84EFB)],
    [Color(0xFF9383FA), Color(0xFF7C69F9)],
    [Color(0xFFFFB367), Color(0xFFFF9831)],
    [Color(0xFF74BBFA), Color(0xFF3CA4FF)],
  ];
  static const textPrimary = Color(0xFF0D121C);
  static const textOnPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF697586);
  static const textFieldBackground = Color(0xFFF5F8FF);
  static const textTertiary = Color(0xFF9AA4B2);
  static const backgroundPrimary = Color(0xFFF5F5F5);
  static const backgroundTertiary = Color(0xFFEEF2F6);
  static const blackTertiary = Color(0xFF454545);
  static const red = Color(0xFFF37373);
  static const filterHandleBar = Color(0xFFCDD5DF);
  static const activePriceSlider = Color(0xFF595959);
  static const borderPrimary = Color(0xFFD9D9D9);
  static const creamWhite = Color(0xFFEFE9DF);
  static const brown = Color(0xFFAD4E28);
  static const blackQuaternary = Color(0xFF262626);
  static const activeDot = Color(0xFF8C8C8C);
  static const grayModern600 = Color(0xFF4B5565);
  static const masterCardBackground = Color(0xFF171725);
  static const additionalWhite = Color(0xFFFEFEFE);
  static const dividerGrey = Color(0xFFDFE1E7);
  static const paymentIconBackground = Color(0xFFF6F8FA);
  static const blackLight = Color(0xFFF0F0F0);
  static const shipped = Color(0xFFFBFDCC);
  static const delivered = Color(0xFFA3FFC6);
  static const grayscale70 = Color(0xFF78828A);
  static const strokeLight = Color(0xFFF6F6F6);
  static const success = Color(0xFF22C661);
  static const warning = Color(0xFFFFD336);
  static const info = Color(0xFF2196F3);
  static const borderSecondary = Color(0xFFF0F0F0);
  static const shadowLight = Color(0x1A000000);
  static const shadowMedium = Color(0x40000000);
  static const shadowDark = Color(0x80000000);
  static const cartNotificationBackground = Color(0xFFEFE8DF);
  static const blurOverlayScrim = Color(0xFF40475B);
  static const buttonDisabledText = Color(0x80FFFFFF);
  static const divider = Color(0xFFE0E0E0);
  static const shimmerBase = Color(0xFFE0E0E0);
  static const shimmerHighlight = Color(0xFFF5F5F5);
  static const disabled = Color(0xFFBDBDBD);
}
''';

const appTextStyleTemplate = r'''
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

const constantsTemplate = r'''
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
