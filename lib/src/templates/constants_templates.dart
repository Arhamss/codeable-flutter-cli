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
  static const whitePrimary = Color(0xFFFCFCFC);
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

  // Additional Colors
  static const grayscale70 = Color(0xFF78828A);
  static const strokeLight = Color(0xFFF6F6F6);

  // Semantic Colors
  static const success = Color(0xFF22C661);
  static const warning = Color(0xFFFFD336);
  static const info = Color(0xFF2196F3);

  static const borderSecondary = Color(0xFFF0F0F0);

  // Shadow Colors
  static const shadowLight = Color(0x1A000000);
  static const shadowMedium = Color(0x40000000);
  static const shadowDark = Color(0x80000000);

  // Additional UI Colors
  static const cartNotificationBackground = Color(0xFFEFE8DF);
  static const blurOverlayScrim = Color(0xFF40475B);
  static const buttonDisabledText = Color(0x80FFFFFF);

  // Misc
  static const divider = Color(0xFFE0E0E0);
  static const shimmerBase = Color(0xFFE0E0E0);
  static const shimmerHighlight = Color(0xFFF5F5F5);
  static const disabled = Color(0xFFBDBDBD);
}
''';

const appTextStyleTemplate = r'''
import 'package:flutter/material.dart';
import 'package:{{project_name}}/constants/app_colors.dart';

/// Font family constants used throughout the app.
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
    double? height,
  }) {
    return TextStyle(
      fontFamily: AppFonts.heading,
      fontSize: size,
      fontWeight: weight,
      fontStyle: fontStyle,
      color: color,
      height: height,
    );
  }

  TextStyle _body(
    double size,
    FontWeight weight, {
    Color color = AppColors.textPrimary,
    FontStyle fontStyle = FontStyle.normal,
    double? height,
  }) {
    return TextStyle(
      fontFamily: AppFonts.body,
      fontSize: size,
      fontWeight: weight,
      fontStyle: fontStyle,
      color: color,
      height: height,
    );
  }

  // ─── Headlines (BBBPoppins) ───

  TextStyle get h1 => _heading(40, FontWeight.w700, height: 1);
  TextStyle get h2 => _heading(28, FontWeight.w700);
  TextStyle get h3 => _heading(24, FontWeight.w600);

  // ─── Titles (BBBPoppins) ───

  TextStyle get t1 => _heading(20, FontWeight.w600);
  TextStyle get t2 => _heading(18, FontWeight.w600);
  TextStyle get t3 => _heading(16, FontWeight.w600);

  // ─── Body (SFProRounded) ───

  TextStyle get b1 => _body(16, FontWeight.w600);
  TextStyle get b2 => _body(14, FontWeight.w400);
  TextStyle get b3 => _body(12, FontWeight.w600);

  // ─── Labels (SFProRounded) ───

  TextStyle get l1 => _body(14, FontWeight.w600);
  TextStyle get l2 => _body(12, FontWeight.w500);
  TextStyle get l3 => _body(10, FontWeight.w400);

  // ─── Weight variants & italics ───

  TextStyle get thickText => _body(18, FontWeight.w800);
  TextStyle get lightText => _body(18, FontWeight.w300);
  TextStyle get extraLightText => _body(18, FontWeight.w200);
  TextStyle get italicBody => _body(
    14,
    FontWeight.w400,
    fontStyle: FontStyle.italic,
  );
}

extension TextStyleSecondary on TextStyle {
  TextStyle get secondary => copyWith(color: AppColors.white);

  TextStyle get tertiary => copyWith(color: AppColors.textTertiary);
}

/// Alias on TextStyle so you can write `.withStyle(...)` if you prefer
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

  /// SVG Icons
  static const homeNavbarSelectedIcon = 'assets/vectors/home_selected.svg';
  static const homeNavbarUnselectedIcon = 'assets/vectors/home_unselected.svg';
  static const ordersNavbarSelectedIcon = 'assets/vectors/orders_selected.svg';
  static const ordersNavbarUnselectedIcon =
      'assets/vectors/orders_unselected.svg';
  static const profileNavbarSelectedIcon =
      'assets/vectors/profile_selected.svg';
  static const profileNavbarUnselectedIcon =
      'assets/vectors/profile_unselected.svg';
  static const cartNavbarUnselectedIcon = 'assets/vectors/cart_unselected.svg';
  static const tickIcon = 'assets/vectors/tick_icon.svg';
  static const errorIcon = 'assets/vectors/error_icon.svg';
  static const searchIcon = 'assets/vectors/search_icon.svg';
  static const filterIcon = 'assets/vectors/filter_icon.svg';
  static const favoriteSelectedIcon =
      'assets/vectors/favorite_selected_icon.svg';
  static const favoriteUnselectedIcon =
      'assets/vectors/favorite_unselected_icon.svg';
  static const arrowLeftIcon = 'assets/vectors/arrow_left_icon.svg';
  static const dropdownArrowIcon = 'assets/vectors/dropdown_arrow_icon.svg';
  static const crossIcon = 'assets/vectors/cross_icon.svg';
  static const cartIcon = 'assets/vectors/cart_icon.svg';
  static const minusIcon = 'assets/vectors/minus_icon.svg';
  static const plusIcon = 'assets/vectors/plus_icon.svg';
  static const editProfileIcon = 'assets/vectors/edit_profile_icon.svg';
  static const savedAddressIcon = 'assets/vectors/saved_address_icon.svg';
  static const paymentMethodIcon = 'assets/vectors/payment_method_icon.svg';
  static const wishlistIcon = 'assets/vectors/wishlist_icon.svg';
  static const privacyPolicyIcon = 'assets/vectors/privacy_policy_icon.svg';
  static const logoutIcon = 'assets/vectors/logout_icon.svg';
  static const helpAndSupportIcon = 'assets/vectors/help_and_support_icon.svg';
  static const deleteAccountIcon = 'assets/vectors/delete_account_icon.svg';
  static const arrowRightIcon = 'assets/vectors/arrow_right_icon.svg';
  static const editIcon = 'assets/vectors/edit_icon.svg';
  static const pkFlagIcon = 'assets/vectors/pk_flag_icon.svg';
  static const arrowDownIcon = 'assets/vectors/arrow_down_icon.svg';
  static const arrowUpIcon = 'assets/vectors/arrow_up_icon.svg';
  static const calendarIcon = 'assets/vectors/calendar_icon.svg';
  static const galleryIcon = 'assets/vectors/gallery_icon.svg';
  static const cameraIcon = 'assets/vectors/camera_icon.svg';
  static const locationIcon = 'assets/vectors/location_icon.svg';
  static const trashIcon = 'assets/vectors/trash_icon.svg';
  static const editAddressIcon = 'assets/vectors/edit_address_icon.svg';
  static const masterCardLogoIcon = 'assets/vectors/mastercard_logo.svg';
  static const visaLogoIcon = 'assets/vectors/visacard_logo.svg';
  static const promoCodeIcon = 'assets/vectors/promo_code_icon.svg';
  static const creditCardIcon = 'assets/vectors/credit_card_icon.svg';
  static const cashOnDeliveryIcon = 'assets/vectors/cash_on_delivery_icon.svg';
  static const easyPaisaIcon = 'assets/vectors/easypaisa_icon.svg';
  static const starFilledIcon = 'assets/vectors/star_filled_icon.svg';
  static const starUnfilledIcon = 'assets/vectors/star_empty_icon.svg';
  static const googleIcon = 'assets/vectors/google_icon.svg';
  static const appleIcon = 'assets/vectors/apple_icon.svg';
  static const googleSvg = 'assets/vectors/google_logo.svg';
  static const appleSvg = 'assets/vectors/apple_logo.svg';

  /// PNG Images
  static const appLogo = 'assets/images/app_logo.png';
  static const productPlaceholder = 'assets/images/product_placeholder.png';
  static const loginImage = 'assets/images/login_image.jpg';
  static const profileImageIcon = 'assets/images/profile_image.svg';

  /// Dummy Asset
  static const dummyIcon = 'assets/images/dummy.png';
}
''';

const constantsTemplate = r'''
class AppConstants {
  AppConstants._();

  static const String appName = '{{ProjectName}}';
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
