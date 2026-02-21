// ==================== HELPERS ====================

const dataStateTemplate = '''
import 'package:equatable/equatable.dart';

enum DataStatus {
  initial,
  loading,
  loaded,
  failure,
  pageLoading;

  bool get isInitial => this == DataStatus.initial;

  bool get isNotInitial => !isInitial;

  bool get isLoading => this == DataStatus.loading;

  bool get isNotLoading => !isLoading;

  bool get isLoaded => this == DataStatus.loaded;

  bool get isNotLoaded => !isLoaded;

  bool get isFailure => this == DataStatus.failure;

  bool get isNotFailure => !isFailure;

  bool get isPageLoading => this == DataStatus.pageLoading;

  bool get isPageNotLoading => !isPageLoading;
}

class DataState<T> extends Equatable {
  const DataState({
    this.key = '',
    this.data,
    this.status = DataStatus.initial,
    this.error,
  });

  const DataState.initial({
    this.key = '',
    this.data,
    this.error,
  }) : status = DataStatus.initial;

  const DataState.loading({
    this.key = '',
    this.data,
    this.error,
  }) : status = DataStatus.loading;

  const DataState.pageLoading({
    this.key = '',
    this.data,
    this.error,
  }) : status = DataStatus.pageLoading;

  const DataState.loaded({
    this.key = '',
    this.data,
    this.error,
  }) : status = DataStatus.loaded;

  const DataState.failure({
    this.key = '',
    this.data,
    this.error,
  }) : status = DataStatus.failure;

  final String key;
  final T? data;
  final DataStatus status;
  final dynamic error;

  DataState<T> copyWith({
    String? key,
    T? data,
    DataStatus? status,
    dynamic error,
  }) {
    return DataState<T>(
      key: key ?? this.key,
      data: data ?? this.data,
      status: status ?? this.status,
      error: status?.isLoaded ?? true ? null : error ?? this.error,
    );
  }

  DataState<T> toLoading({String? key, T? data}) =>
      copyWith(key: key, data: data, status: DataStatus.loading);

  DataState<T> toLoaded({String? key, T? data}) =>
      copyWith(key: key, data: data, status: DataStatus.loaded);

  DataState<T> toPageLoading({String? key, T? data}) =>
      copyWith(key: key, data: data, status: DataStatus.pageLoading);

  DataState<T> toFailure({String? key, dynamic error}) =>
      copyWith(key: key, error: error, status: DataStatus.failure);

  String? get errorMessage {
    final dynamic e = error;
    return isFailure
        ? e is String
            ? e
            : e?.toString() ?? 'Something went wrong'
        : null;
  }

  bool get isInitial => status.isInitial;
  bool get isNotInitial => status.isNotInitial;
  bool get isLoading => status.isLoading;
  bool get isNotLoading => status.isNotLoading;
  bool get isLoaded => status.isLoaded;
  bool get isNotLoaded => status.isNotLoaded;
  bool get isFailure => status.isFailure;
  bool get isNotFailure => status.isNotFailure;
  bool get isPageLoading => status.isPageLoading;
  bool get isPageNotLoading => status.isPageNotLoading;

  bool get isEmpty {
    final vData = data;
    return vData == null ||
        vData is List && vData.isEmpty ||
        vData is String && vData.isEmpty;
  }

  bool get isNotEmpty => !isEmpty;
  bool get hasError => error?.toString().isNotEmpty ?? true;
  bool get hasNoError => !hasError;

  @override
  List<Object?> get props => [key, data, status, error];
}
''';

const apiCallStateTemplate = '''
import 'package:equatable/equatable.dart';

enum APICallState {
  initial,
  loading,
  loaded,
  failure;

  bool get isInitial => this == APICallState.initial;

  bool get isLoading => this == APICallState.loading;

  bool get isLoaded => this == APICallState.loaded;

  bool get isFailure => this == APICallState.failure;
}

class APIState<T> extends Equatable {
  const APIState({
    this.data,
    this.state = APICallState.initial,
    this.error,
  });

  final T? data;
  final APICallState state;
  final String? error;

  APIState<T> copyWith({
    T? data,
    APICallState? state,
    String? error,
  }) {
    return APIState(
      data: data ?? this.data,
      state: state ?? this.state,
      error: error ?? this.error,
    );
  }

  bool get isInitial => state.isInitial;

  bool get isLoading => state.isLoading;

  bool get isLoaded => state.isLoaded;

  bool get isFailure => state.isFailure;

  bool get isEmpty {
    return data == null ||
        (data is List && (data! as List).isEmpty) ||
        (data is Map && (data! as Map).isEmpty);
  }

  bool get isNotEmpty => !isEmpty;

  bool get hasError => error?.isNotEmpty ?? false;

  APIState<T> toInitial() => copyWith(state: APICallState.initial);

  APIState<T> toLoading() => copyWith(state: APICallState.loading);

  APIState<T> toLoaded({T? data}) =>
      copyWith(data: data, state: APICallState.loaded);

  APIState<T> toFailure({String? error}) =>
      copyWith(state: APICallState.failure, error: error);

  @override
  List<Object?> get props => [data, state, error];
}
''';

const repositoryResponseTemplate = '''
class RepositoryResponse<T> {
  RepositoryResponse({
    required this.isSuccess,
    this.data,
    this.message,
  });

  final bool isSuccess;
  final T? data;
  final String? message;
}
''';

const loggerHelperTemplate = '''
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      lineLength: 5000,
      colors: false,
      methodCount: 0,
      errorMethodCount: 20,
    ),
  );

  static void info(String message) {
    _logger.i(message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void debug(String message) {
    _logger.d(message);
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void verbose(String message) {
    _logger.t(message);
  }
}
''';

const toastHelperTemplate = '''
import 'package:{{project_name}}/exports.dart';
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
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
    );
  }
}
''';

const typedefTemplate = '''
typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<Map<String, dynamic>>;
''';

const focusHandlerTemplate = '''
import 'package:flutter/material.dart';

class FocusHandler extends StatelessWidget {
  const FocusHandler({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: child,
    );
  }
}
''';

const stringHelperTemplate = '''
extension StringHelpers on String {
  String get toLetterCase =>
      length > 0 ? '\\\${this[0].toUpperCase()}\\\${substring(1).toLowerCase()}' : '';

  String get toTitleCase => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toLetterCase)
      .join(' ');

  String sPluralise(num number) => (number == 1) ? this : '\\\${this}s';
}

extension StringListHelper on List<String> {
  String get toBulletedString => map((item) => '\\u2022 \\\$item').join('\\n\\n');

  String bulletedString({String gap = '\\n'}) =>
      map((item) => '\\u2022 \\\$item').join(gap);
}

extension ImagePathHelper on String {
  bool get isSvg => endsWith('.svg');

  bool get isWebp => endsWith('.webp');
}
''';

const colorHelperTemplate = '''
import 'package:flutter/material.dart';

class ColorHelper {
  static String colorToName(Color color) {
    final value = color.value;
    switch (value) {
      case 0xFFFFFFFF:
        return 'White';
      case 0xFFFF0000:
        return 'Red';
      case 0xFFFFFF00:
        return 'Yellow';
      case 0xFF0000FF:
        return 'Blue';
      case 0xFF90EE90:
        return 'Green';
      case 0xFF800080:
        return 'Purple';
      case 0xFF00FFFF:
        return 'Cyan';
      case 0xFF8B0000:
        return 'Dark Red';
      default:
        return 'Unknown';
    }
  }

  static Color nameToColor(String name) {
    if (name.trim().isEmpty) {
      return Colors.grey;
    }
    switch (name.toLowerCase().trim()) {
      case 'black':
        return const Color(0xFF0D121C);
      case 'white':
        return const Color(0xFFFFFFFF);
      case 'red':
        return const Color(0xFFFF0000);
      case 'yellow':
        return const Color(0xFFFFFF00);
      case 'blue':
        return const Color(0xFF0000FF);
      case 'green':
        return const Color(0xFF90EE90);
      case 'purple':
        return const Color(0xFF800080);
      case 'cyan':
        return const Color(0xFF00FFFF);
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'navy':
        return const Color(0xFF000080);
      case 'beige':
        return const Color(0xFFF5F5DC);
      case 'cream':
        return const Color(0xFFFFFDD0);
      case 'maroon':
        return const Color(0xFF800000);
      case 'teal':
        return const Color(0xFF008080);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'coral':
        return const Color(0xFFFF7F50);
      case 'mint':
        return const Color(0xFF98FF98);
      case 'lavender':
        return const Color(0xFFE6E6FA);
      default:
        return const Color(0xFF0D121C);
    }
  }
}
''';

const decorationsHelperTemplate = '''
import 'package:{{project_name}}/exports.dart';

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
''';

const layoutHelperTemplate = '''
import 'package:flutter/material.dart';

class LayoutHelper {
  LayoutHelper._();

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static int calculateGridColumns(
    BuildContext context, {
    double minItemWidth = 160,
    double padding = 32,
    double spacing = 8,
    int minColumns = 2,
    int maxColumns = 4,
  }) {
    final availableWidth = screenWidth(context) - padding;
    final count =
        ((availableWidth + spacing) / (minItemWidth + spacing)).floor();
    return count.clamp(minColumns, maxColumns);
  }
}
''';

// ==================== CORE WIDGETS ====================

const coreWidgetsExportTemplate = '''
export 'app_bar.dart';
export 'bottom_sheet.dart';
export 'button.dart';
export 'cached_network_image.dart';
export 'confirmation_dialog.dart';
export 'empty_state_widget.dart';
export 'icon_button.dart';
export 'loading_widget.dart';
export 'outline_button.dart';
export 'paginated_list_view.dart';
export 'retry_widget.dart';
export 'search_field.dart';
export 'section_title.dart';
export 'shimmer_loading_widget.dart';
export 'social_auth_button.dart';
export 'text_button.dart';
export 'text_field.dart';
''';

const customAppBarTemplate = '''
import 'package:{{project_name}}/exports.dart';

/// Universal round, fixed-size back button for app bars.
class AppBarBackButton extends StatelessWidget {
  const AppBarBackButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppBarCircleButton(
      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
      onPressed: onPressed ?? () => context.pop(),
      backgroundColor: Colors.white,
    );
  }
}

/// Universal round, fixed-size circle button for app bar leading/actions.
class AppBarCircleButton extends StatelessWidget {
  const AppBarCircleButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.backgroundColor,
    this.foregroundColor,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    const double size = 40;
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        style: IconButton.styleFrom(
          minimumSize: Size(size, size),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const CircleBorder(),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
      ),
    );
  }
}

const EdgeInsets _appBarLeadingPadding = EdgeInsets.only(
  left: 16,
  bottom: 8,
  top: 8,
);

/// Custom AppBar widget matching the app design pattern.
PreferredSizeWidget customAppBar({
  required BuildContext context,
  required String title,
  VoidCallback? onBackPressed,
  List<Widget>? actions,
  bool showBackButton = true,
  double? toolbarHeight,
  Widget? leading,
  Widget? titleWidget,
}) {
  return AppBar(
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    forceMaterialTransparency: true,
    toolbarHeight: toolbarHeight,
    leadingWidth: 16 + 40,
    leading: showBackButton
        ? (leading ??
            Padding(
              padding: _appBarLeadingPadding,
              child: AppBarBackButton(onPressed: onBackPressed),
            ))
        : null,
    title: titleWidget ??
        Text(
          title,
          style: context.t1.copyWith(fontSize: 16),
        ),
    actions: actions,
  );
}
''';

const customButtonTemplate = '''
import 'package:{{project_name}}/exports.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    super.key,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.textOnPrimary,
    this.disabledTextColor,
    this.disabledBackgroundColor,
    this.borderRadius = 100,
    EdgeInsetsGeometry? padding,
    this.fontWeight = FontWeight.w600,
    this.splashColor = Colors.black12,
    this.fontSize = 16,
    this.prefixIcon,
    this.suffixIcon,
    EdgeInsetsGeometry? outsidePadding,
    this.isExpanded = true,
    this.iconSpacing,
    this.disabled = false,
    this.loadingColor = AppColors.textOnPrimary,
    this.borderColor,
    this.borderWidth = 1.0,
    this.textStyle,
    this.hasShadow = false,
  })  : padding = padding ??
            const EdgeInsetsDirectional.symmetric(
              vertical: 12,
              horizontal: 24,
            ),
        outsidePadding = outsidePadding ?? const EdgeInsetsDirectional.all(4);

  /// Primary button - Dark background with light text
  CustomButton.primary({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    super.key,
    this.prefixIcon,
    this.suffixIcon,
    EdgeInsets? outsidePadding,
    this.isExpanded = true,
    this.iconSpacing,
    this.disabled = false,
    this.hasShadow = false,
  })  : backgroundColor = AppColors.primary,
        textColor = AppColors.textOnPrimary,
        disabledTextColor = AppColors.textTertiary,
        disabledBackgroundColor = AppColors.disabled,
        borderRadius = 100,
        padding = const EdgeInsetsDirectional.symmetric(
          vertical: 16,
          horizontal: 24,
        ),
        fontWeight = FontWeight.w600,
        splashColor = Colors.black12,
        fontSize = 16,
        loadingColor = AppColors.textOnPrimary,
        borderColor = AppColors.primary,
        borderWidth = 1.0,
        textStyle = null,
        outsidePadding = outsidePadding ?? const EdgeInsetsDirectional.all(4);

  /// Secondary button - Light background with dark text and border
  const CustomButton.secondary({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    super.key,
    this.prefixIcon,
    this.suffixIcon,
    this.outsidePadding = const EdgeInsetsDirectional.all(4),
    this.isExpanded = true,
    this.iconSpacing,
    this.disabled = false,
    this.hasShadow = false,
    this.padding = const EdgeInsetsDirectional.symmetric(
      vertical: 16,
      horizontal: 24,
    ),
    this.borderWidth = 1.0,
    this.textStyle,
    this.splashColor = Colors.black12,
  })  : backgroundColor = Colors.white,
        textColor = AppColors.primary,
        disabledTextColor = AppColors.textTertiary,
        disabledBackgroundColor = AppColors.borderSecondary,
        borderRadius = 100,
        fontWeight = FontWeight.w600,
        fontSize = 16,
        loadingColor = AppColors.primary,
        borderColor = AppColors.primary;

  /// Tertiary button - Text-only button with no background or border
  const CustomButton.tertiary({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    super.key,
    this.prefixIcon,
    this.suffixIcon,
    this.outsidePadding = const EdgeInsetsDirectional.all(4),
    this.isExpanded = true,
    this.iconSpacing,
    this.disabled = false,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
  })  : backgroundColor = Colors.transparent,
        textColor = AppColors.primary,
        disabledTextColor = AppColors.textTertiary,
        disabledBackgroundColor = Colors.transparent,
        borderRadius = 100,
        padding = const EdgeInsetsDirectional.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        splashColor = Colors.black12,
        loadingColor = AppColors.primary,
        borderColor = null,
        borderWidth = 0.0,
        textStyle = null,
        hasShadow = false;

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final FontWeight fontWeight;
  final Color splashColor;
  final double fontSize;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? outsidePadding;
  final bool isExpanded;
  final double? iconSpacing;
  final bool disabled;
  final Color? disabledTextColor;
  final Color? disabledBackgroundColor;
  final Color loadingColor;
  final Color? borderColor;
  final double borderWidth;
  final TextStyle? textStyle;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    final effectiveDisabledBackgroundColor =
        disabledBackgroundColor ?? AppColors.primary;
    final effectiveDisabledTextColor =
        disabledTextColor ?? Colors.white.withValues(alpha: 0.5);

    final buttonContent = TextButton(
      onPressed: (isLoading || disabled) ? null : onPressed,
      style: TextButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        backgroundColor:
            disabled ? effectiveDisabledBackgroundColor : backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderColor != null
              ? BorderSide(
                  color: disabled
                      ? borderColor!.withValues(alpha: 0.5)
                      : borderColor!,
                  width: borderWidth,
                )
              : BorderSide.none,
        ),
        splashFactory: InkRipple.splashFactory,
        overlayColor: splashColor,
      ),
      child: Padding(
        padding: padding,
        child: isLoading
            ? SizedBox(
                height: 23,
                width: 23,
                child: LoadingWidget(color: textColor),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    SizedBox(width: iconSpacing ?? 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: textStyle ??
                          context.h2.copyWith(
                            color: disabled
                                ? effectiveDisabledTextColor
                                : textColor,
                            fontWeight: fontWeight,
                            fontSize: fontSize,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    SizedBox(width: iconSpacing ?? 8),
                    suffixIcon!,
                  ],
                ],
              ),
      ),
    );

    final Widget buttonWidget = Padding(
      padding: outsidePadding ?? EdgeInsets.zero,
      child: isExpanded
          ? Row(children: [Expanded(child: buttonContent)])
          : buttonContent,
    );

    if (hasShadow) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 4),
              blurRadius: 15,
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
          ],
        ),
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}
''';

const customOutlineButtonTemplate = '''
import 'package:{{project_name}}/exports.dart';

class CustomOutlineButton extends StatelessWidget {
  CustomOutlineButton({
    required this.text,
    required this.onPressed,
    required this.isLoading,
    super.key,
    this.borderColor = AppColors.primary,
    this.textColor = AppColors.primary,
    this.disabledTextColor = AppColors.textTertiary,
    this.disabledBorderColor,
    this.borderRadius = 100,
    EdgeInsets? padding,
    this.fontWeight = FontWeight.w600,
    this.splashColor = Colors.black12,
    this.fontSize = 16,
    this.prefixIcon,
    this.suffixIcon,
    EdgeInsets? outsidePadding,
    this.isExpanded = true,
    this.iconSpacing,
    this.disabled = false,
    this.loadingColor,
    this.borderWidth = 1.5,
  })  : padding = padding ??
            const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 14,
            ),
        outsidePadding = outsidePadding ?? const EdgeInsets.all(4);

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color borderColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final FontWeight fontWeight;
  final Color splashColor;
  final double fontSize;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsets? outsidePadding;
  final bool isExpanded;
  final double? iconSpacing;
  final bool disabled;
  final Color disabledTextColor;
  final Color? disabledBorderColor;
  final Color? loadingColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = disabled
        ? (disabledBorderColor ?? borderColor.withValues(alpha: 0.5))
        : borderColor;

    final button = TextButton(
      onPressed: (isLoading || disabled) ? null : onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsetsDirectional.zero,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: effectiveBorderColor, width: borderWidth),
        ),
        splashFactory: InkRipple.splashFactory,
        overlayColor: splashColor,
      ),
      child: Padding(
        padding: padding,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: LoadingWidget(color: loadingColor ?? textColor),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    SizedBox(width: iconSpacing ?? 8),
                  ],
                  Text(
                    text,
                    style: context.b1.copyWith(
                      color: disabled ? disabledTextColor : textColor,
                      fontWeight: fontWeight,
                      fontSize: fontSize,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    SizedBox(width: iconSpacing ?? 8),
                    suffixIcon!,
                  ],
                ],
              ),
      ),
    );

    return Padding(
      padding: outsidePadding ?? EdgeInsetsDirectional.zero,
      child: isExpanded ? Row(children: [Expanded(child: button)]) : button,
    );
  }
}
''';

const customTextButtonTemplate = '''
import 'package:{{project_name}}/exports.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    required this.onPressed,
    required this.text,
    this.textStyle,
    super.key,
  });

  final VoidCallback onPressed;
  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        splashFactory: NoSplash.splashFactory,
        foregroundColor: AppColors.primary,
        overlayColor: Colors.transparent,
      ),
      child: Text(text, style: textStyle ?? context.h2.copyWith(fontSize: 16)),
    );
  }
}
''';

const customIconButtonTemplate = '''
import 'package:{{project_name}}/exports.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    this.icon,
    this.onPressed,
    this.backgroundColor = Colors.white,
    this.iconColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
    this.borderColor = AppColors.textTertiary,
    this.splashColor = Colors.black12,
    this.outsidePadding = EdgeInsetsDirectional.zero,
    this.iconPadding,
    this.borderWidth = 1,
    this.isLoading = false,
    this.shrinkTargetSize = true,
    super.key,
  });

  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color? iconColor;
  final BorderRadiusGeometry borderRadius;
  final Color borderColor;
  final Color splashColor;
  final Widget? icon;
  final double? iconPadding;
  final EdgeInsetsDirectional outsidePadding;
  final bool isLoading;
  final double borderWidth;
  final bool shrinkTargetSize;

  @override
  Widget build(BuildContext context) {
    final Widget iconButtonWidget = IconButton(
      onPressed: isLoading == true ? null : onPressed,
      icon: isLoading
          ? const LoadingWidget(size: 18)
          : icon ?? const Icon(Icons.arrow_back_ios_new, size: 18),
      color: iconColor,
      style: IconButton.styleFrom(
        tapTargetSize: shrinkTargetSize
            ? MaterialTapTargetSize.shrinkWrap
            : MaterialTapTargetSize.padded,
        padding: EdgeInsetsDirectional.all(iconPadding ?? 8),
        minimumSize: Size.zero,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: borderColor, width: borderWidth),
        ),
      ),
    );

    return Padding(padding: outsidePadding, child: iconButtonWidget);
  }
}
''';

const customTextFieldTemplate = '''
import 'package:{{project_name}}/exports.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: context.l1),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          focusNode: focusNode,
          textInputAction: textInputAction,
          style: context.b1,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.b1.copyWith(color: AppColors.textTertiary),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderPrimary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderPrimary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
''';

const searchFieldTemplate = '''
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.onChanged,
    this.cursorColor,
    this.onTap,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final Color? cursorColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      onChanged: onChanged,
      cursorColor: cursorColor,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
''';

const loadingWidgetTemplate = '''
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:{{project_name}}/exports.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.size = 24,
    this.color = AppColors.primary,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: Platform.isIOS
            ? CupertinoActivityIndicator(color: color)
            : CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 1.5,
              ),
      ),
    );
  }
}
''';

const shimmerLoadingWidgetTemplate = '''
import 'package:{{project_name}}/exports.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingWidget extends StatelessWidget {
  const ShimmerLoadingWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 0.0,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
''';

const retryWidgetTemplate = '''
import 'package:{{project_name}}/exports.dart';

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
''';

const emptyStateWidgetTemplate = '''
import 'package:{{project_name}}/exports.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.title,
    this.subtitle,
    this.iconPath,
    this.iconBgColor,
    this.buttonText,
    this.onButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    this.showSecondaryButton = false,
    this.iconColor,
    this.iconWidget,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? iconPath;
  final Color? iconBgColor;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;
  final bool showSecondaryButton;
  final Color? iconColor;
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconWidget != null && iconPath == null) ...[
            iconWidget!,
          ] else if (iconPath != null && iconWidget == null) ...[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconBgColor ?? AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath!,
                  width: 40,
                  height: 40,
                  colorFilter: iconColor != null
                      ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            title,
            style: context.h3.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: context.b2.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
          if (buttonText != null || showSecondaryButton) ...[
            const SizedBox(height: 32),
            if (showSecondaryButton && secondaryButtonText != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomButton(
                      text: buttonText ?? '',
                      onPressed: onButtonPressed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: secondaryButtonText!,
                      onPressed: onSecondaryButtonPressed,
                    ),
                  ),
                ],
              ),
            ] else if (buttonText != null) ...[
              CustomButton(text: buttonText!, onPressed: onButtonPressed),
            ],
          ],
        ],
      ),
    );
  }
}
''';

const confirmationDialogTemplate = '''
import 'package:{{project_name}}/exports.dart';

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
''';

const sectionTitleTemplate = '''
import 'package:{{project_name}}/exports.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    required this.title,
    this.padding,
    this.bottomSpacing,
    super.key,
  });

  final String title;
  final EdgeInsets? padding;
  final double? bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: context.t1.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: bottomSpacing ?? 16),
      ],
    );
  }
}
''';

const cachedNetworkImageTemplate = '''
import 'package:cached_network_image/cached_network_image.dart';
import 'package:{{project_name}}/exports.dart';
import 'package:shimmer/shimmer.dart';

class CustomCachedImageWidget extends StatelessWidget {
  const CustomCachedImageWidget({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl.trim();
    if (trimmedUrl.isEmpty) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(0),
        child: Container(
          width: width,
          height: height,
          color: AppColors.shimmerBase,
          child: Icon(
            Icons.image_outlined,
            size: (width != null && height != null)
                ? (width! < height! ? width! * 0.5 : height! * 0.5)
                : 24,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(0),
      child: CachedNetworkImage(
        imageUrl: trimmedUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: AppColors.shimmerBase,
          highlightColor: AppColors.shimmerHighlight,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: borderRadius ?? BorderRadius.zero,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: AppColors.shimmerBase,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
''';

const socialAuthButtonTemplate = '''
import 'package:{{project_name}}/exports.dart';

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.iconPath,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? iconPath;

  @override
  Widget build(BuildContext context) {
    return CustomButton.secondary(
      text: text,
      onPressed: isLoading ? null : onPressed,
      isLoading: isLoading,
      prefixIcon: iconPath != null
          ? SvgPicture.asset(
              iconPath!,
              width: 20,
              height: 20,
            )
          : null,
      iconSpacing: 12,
    );
  }
}
''';

const bottomSheetTemplate = '''
import 'package:{{project_name}}/exports.dart';

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
''';

const paginatedListViewTemplate = '''
import 'package:{{project_name}}/exports.dart';

class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMoreData,
    super.key,
    this.emptyTitle = 'No items found',
    this.emptySubtitle = 'Check back later for more content',
    this.emptyIcon,
    this.errorMessage,
    this.onRetry,
    this.separatorBuilder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.loadMoreThreshold = 200,
    this.refreshIndicatorColor,
    this.refreshIndicatorBackgroundColor,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreData;
  final String emptyTitle;
  final String emptySubtitle;
  final String? emptyIcon;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double loadMoreThreshold;
  final Color? refreshIndicatorColor;
  final Color? refreshIndicatorBackgroundColor;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent -
                widget.loadMoreThreshold &&
        !widget.isLoadingMore &&
        widget.hasMoreData &&
        widget.items.isNotEmpty) {
      widget.onLoadMore();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: EmptyStateWidget(
          title: widget.emptyTitle,
          subtitle: widget.emptySubtitle,
          iconPath: widget.emptyIcon,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: RetryWidget(
        message: widget.errorMessage ?? 'Something went wrong',
        onRetry: widget.onRetry ?? widget.onRefresh,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: LoadingWidget(),
    );
  }

  Widget _buildListView() {
    final itemCount = widget.items.length + (widget.isLoadingMore ? 1 : 0);

    return RefreshIndicator.adaptive(
      onRefresh: widget.onRefresh,
      color: widget.refreshIndicatorColor,
      backgroundColor: widget.refreshIndicatorBackgroundColor,
      child: ListView.separated(
        controller: _scrollController,
        padding: widget.padding,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        itemCount: itemCount,
        separatorBuilder:
            widget.separatorBuilder ??
            (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsetsDirectional.all(16),
                child: LoadingWidget(),
              ),
            );
          }

          final item = widget.items[index];
          return widget.itemBuilder(context, item, index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.errorMessage != null && widget.items.isEmpty) {
      return _buildErrorState();
    }

    if (widget.isLoading && widget.items.isEmpty) {
      return _buildLoadingState();
    }

    if (widget.items.isEmpty && !widget.isLoading) {
      return _buildEmptyState();
    }

    return _buildListView();
  }
}

class PaginatedGridView<T> extends StatefulWidget {
  const PaginatedGridView({
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMoreData,
    required this.gridDelegate,
    super.key,
    this.emptyTitle = 'No items found',
    this.emptySubtitle = 'Check back later for more content',
    this.emptyIcon,
    this.errorMessage,
    this.onRetry,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.loadMoreThreshold = 200,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreData;
  final SliverGridDelegate gridDelegate;
  final String emptyTitle;
  final String emptySubtitle;
  final String? emptyIcon;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double loadMoreThreshold;

  @override
  State<PaginatedGridView<T>> createState() => _PaginatedGridViewState<T>();
}

class _PaginatedGridViewState<T> extends State<PaginatedGridView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent -
                widget.loadMoreThreshold &&
        !widget.isLoadingMore &&
        widget.hasMoreData &&
        widget.items.isNotEmpty) {
      widget.onLoadMore();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: EmptyStateWidget(
          title: widget.emptyTitle,
          subtitle: widget.emptySubtitle,
          iconPath: widget.emptyIcon,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: RetryWidget(
        message: widget.errorMessage ?? 'Something went wrong',
        onRetry: widget.onRetry ?? widget.onRefresh,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: LoadingWidget(),
    );
  }

  Widget _buildGridView() {
    return RefreshIndicator.adaptive(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: widget.physics,
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: widget.gridDelegate,
              padding: widget.padding,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return widget.itemBuilder(context, item, index);
              },
            ),
            if (widget.isLoadingMore && widget.items.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: LoadingWidget(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.errorMessage != null && widget.items.isEmpty) {
      return _buildErrorState();
    }

    if (widget.isLoading && widget.items.isEmpty) {
      return _buildLoadingState();
    }

    if (widget.items.isEmpty && !widget.isLoading) {
      return _buildEmptyState();
    }

    return _buildGridView();
  }
}
''';

// ==================== RESPONSE MODELS ====================

const responseDataModelTemplate = '''
class ResponseDataModel<T> {
  ResponseDataModel({
    this.data,
    this.message,
    this.success = false,
  });

  final T? data;
  final String? message;
  final bool success;
}
''';

const apiResponseParserTemplate = '''
import 'package:dio/dio.dart';

class ApiResponseParser {
  ApiResponseParser._();

  static T? parse<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final responseData = data['data'];
      if (responseData is Map<String, dynamic>) {
        return fromJson(responseData);
      }
    }
    return null;
  }

  static List<T> parseList<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final responseData = data['data'];
      if (responseData is List) {
        return responseData
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }
}
''';
