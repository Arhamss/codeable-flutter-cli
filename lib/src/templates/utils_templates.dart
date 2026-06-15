// ==================== HELPERS ====================

const dataStateTemplate = '''
import 'package:equatable/equatable.dart';
import 'package:{{project_name}}/l10n/localization_service.dart';

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
            : e?.toString() ?? Localization.somethingWentWrong
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
  bool get hasError => error?.toString().isNotEmpty ?? false;
  bool get hasNoError => !hasError;

  DataState<R> map<R>(R Function(T) transform) {
    return DataState<R>(
      key: key,
      data: data != null ? transform(data as T) : null,
      status: status,
      error: error,
    );
  }

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
import 'package:dio/dio.dart';
import 'package:{{project_name}}/core/api_service/app_api_exception.dart';
import 'package:{{project_name}}/l10n/localization_service.dart';
import 'package:{{project_name}}/utils/helpers/logger_helper.dart';

class RepositoryResponse<T> {
  RepositoryResponse({
    required this.isSuccess,
    this.data,
    this.message,
    this.details,
    this.isCancelled = false,
  });

  final bool isSuccess;
  final T? data;
  final String? message;
  final List<dynamic>? details;
  final bool isCancelled;
}

Future<RepositoryResponse<T>> execute<T>(
  Future<T> Function() action,
) async {
  try {
    final data = await action();
    return RepositoryResponse(isSuccess: true, data: data);
  } on DioException catch (e, s) {
    if (e.type == DioExceptionType.cancel) {
      return RepositoryResponse(isSuccess: false, isCancelled: true);
    }
    AppLogger.error('Dio error', e, s);
    return RepositoryResponse(
      isSuccess: false,
      message: extractApiErrorMessage(e, Localization.somethingWentWrong),
    );
  } on AppApiException catch (e) {
    return RepositoryResponse(
      isSuccess: false,
      message: e.message,
      details: e.details,
    );
  } catch (e, s) {
    AppLogger.error('Unexpected error', e, s);
    return RepositoryResponse(
      isSuccess: false,
      message: Localization.somethingWentWrong,
    );
  }
}
''';

const loggerHelperTemplate = r"""
import 'dart:convert';

import 'package:flutter/foundation.dart';

const _sensitiveKeys = {
  'password',
  'token',
  'accesstoken',
  'refreshtoken',
  'otp',
  'authorization',
  'cookie',
  'set-cookie',
  'x-api-key',
  'cardnumber',
  'cvv',
  'pin',
};

bool _isSensitiveKey(String key) {
  final lower = key.toLowerCase();
  return _sensitiveKeys.any(lower.contains);
}

dynamic _redact(dynamic value) {
  if (value is Map) {
    return value.map<dynamic, dynamic>((dynamic k, dynamic v) {
      if (k is String && _isSensitiveKey(k)) {
        return MapEntry<dynamic, dynamic>(k, '***');
      }
      return MapEntry<dynamic, dynamic>(k, _redact(v));
    });
  }
  if (value is List) {
    return value.map<dynamic>(_redact).toList();
  }
  return value;
}

class AppLogger {
  AppLogger._();

  static const _w = 60;
  static const _encoder = JsonEncoder.withIndent('  ');

  static void debug(String message) {
    if (kDebugMode) debugPrint('  🔹 $message');
  }

  static void info(String message) {
    if (kDebugMode) debugPrint('  🔵 $message');
  }

  static void warning(String message) {
    if (!kDebugMode) return;
    final buf = StringBuffer()
      ..writeln('  ┌${'─' * _w}')
      ..writeln('  │ ⚠️ $message')
      ..write('  └${'─' * _w}');
    debugPrint(buf.toString());
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    final buf = StringBuffer()
      ..writeln('  ┌${'─' * _w}')
      ..writeln('  │ ❌ $message');

    if (error != null) {
      buf.writeln('  │    $error');
    }

    if (stackTrace != null) {
      buf.writeln('  ├${'─' * _w}');
      final frames = stackTrace
          .toString()
          .split('\n')
          .where(
            (l) =>
                l.trim().isNotEmpty &&
                !l.contains('dart:') &&
                !l.contains('package:flutter/') &&
                !l.contains('package:bloc/') &&
                !l.contains('package:dio/'),
          )
          .take(5);
      for (final frame in frames) {
        buf.writeln('  │ ${frame.trim()}');
      }
    }

    buf.write('  └${'─' * _w}');
    debugPrint(buf.toString());
  }

  static void verbose(String message) {
    if (kDebugMode) debugPrint('  ⚪ $message');
  }

  static String _maskToken(String token) {
    if (token.length <= 12) return '***';
    return '${token.substring(0, 6)}…${token.substring(token.length - 4)}';
  }

  static void authToken(String? token) {
    if (!kDebugMode || token == null || token.isEmpty) return;
    final buf = StringBuffer()
      ..writeln()
      ..writeln('  ╔${'═' * _w}')
      ..writeln('  ║ 🔑 Auth Token')
      ..writeln('  ╟${'─' * _w}')
      ..writeln('  ║   ${_maskToken(token)}')
      ..write('  ╚${'═' * _w}');
    debugPrint(buf.toString(), wrapWidth: 1024);
  }

  static void apiRequest({
    required String method,
    required Uri uri,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParams,
    dynamic body,
  }) {
    if (!kDebugMode) return;

    final buf = StringBuffer()
      ..writeln()
      ..writeln('  ╔${'═' * _w}')
      ..writeln('  ║ ➜ $method  ${uri.path}')
      ..writeln('  ║   $uri');

    if (headers != null && headers.isNotEmpty) {
      buf.writeln('  ╟${'─' * _w}');
      for (final e in headers.entries) {
        if (e.key.toLowerCase() == 'authorization') continue;
        final value = _isSensitiveKey(e.key) ? '***' : e.value;
        buf.writeln('  ║   ${e.key}: $value');
      }
    }

    if (queryParams != null && queryParams.isNotEmpty) {
      buf
        ..writeln('  ╟${'─' * _w}')
        ..writeln('  ║ Query:');
      for (final e in queryParams.entries) {
        buf.writeln('  ║   ${e.key}: ${e.value}');
      }
    }

    if (body != null) {
      buf.writeln('  ╟${'─' * _w}');
      _writeBlock(buf, _prettyJson(body), '║');
    }

    buf.write('  ╚${'═' * _w}');
    debugPrint(buf.toString());
  }

  static void apiResponse({
    required String method,
    required String path,
    required int statusCode,
    required int elapsedMs,
    dynamic body,
  }) {
    if (!kDebugMode) return;

    final buf = StringBuffer()
      ..writeln()
      ..writeln('  ┌${'─' * _w}')
      ..writeln('  │ ✅ $statusCode  $method $path  ⏱ ${elapsedMs}ms');

    if (body != null) {
      buf.writeln('  ├${'─' * _w}');
      _writeBlock(buf, _prettyJson(body), '│');
    }

    buf.write('  └${'─' * _w}');
    debugPrint(buf.toString());
  }

  static void apiError({
    required String method,
    required String path,
    required int statusCode,
    required int elapsedMs,
    dynamic body,
    String? errorMessage,
  }) {
    if (!kDebugMode) return;

    final buf = StringBuffer()
      ..writeln()
      ..writeln('  ┏${'━' * _w}')
      ..writeln('  ┃ ❌ $statusCode  $method $path  ⏱ ${elapsedMs}ms');

    if (errorMessage != null) {
      buf.writeln('  ┃ $errorMessage');
    }

    if (body != null) {
      buf.writeln('  ┣${'━' * _w}');
      _writeBlock(buf, _prettyJson(body), '┃');
    }

    buf.write('  ┗${'━' * _w}');
    debugPrint(buf.toString());
  }

  static String _prettyJson(dynamic data) {
    try {
      final object = data is String ? jsonDecode(data) : data;
      return _encoder.convert(_redact(object));
    } catch (_) {
      return data.toString();
    }
  }

  static void _writeBlock(StringBuffer buf, String text, String border) {
    for (final line in text.split('\n')) {
      buf.writeln('  $border   $line');
    }
  }
}
""";

const toastHelperTemplate = '''
import 'package:toastification/toastification.dart';
import 'package:{{project_name}}/exports.dart';
import 'package:{{project_name}}/l10n/localization_service.dart';

class ToastHelper {
  ToastHelper._();

  static const _toastDuration = Duration(seconds: 3);
  static const _toastIconSize = 24.0;
  static const _toastRadius = 48.0;

  static void _show({
    required ToastificationType type,
    required Color background,
    required String iconPath,
    required String message,
  }) {
    toastification.show(
      type: type,
      backgroundColor: background,
      borderRadius: BorderRadius.circular(_toastRadius),
      borderSide: BorderSide.none,
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
      icon: Padding(
        padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
        child: SvgPicture.asset(
          iconPath,
          height: _toastIconSize,
          width: _toastIconSize,
          colorFilter: const ColorFilter.mode(AppColors.textOnPrimary, BlendMode.srcIn),
        ),
      ),
      title: Text(
        message,
        style: const TextStyle(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: AppColors.textOnPrimary,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      autoCloseDuration: _toastDuration,
      alignment: Alignment.topCenter,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
      showProgressBar: false,
    );
  }

  static void showErrorToast(String? message) {
    _show(
      type: ToastificationType.error,
      background: AppColors.error,
      iconPath: AssetPaths.errorIcon,
      message: message ?? Localization.somethingWentWrong,
    );
  }

  static void showSuccessToast(String message) {
    _show(
      type: ToastificationType.success,
      background: AppColors.success,
      iconPath: AssetPaths.successIcon,
      message: message,
    );
  }

  static void showInfoToast(String message) {
    _show(
      type: ToastificationType.info,
      background: AppColors.info,
      iconPath: AssetPaths.infoIcon,
      message: message,
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

const stringHelperTemplate = r'''
extension StringHelpers on String {
  /// Capitalises the first letter and lower-cases the rest.
  /// Note: this lower-cases the remainder, so acronyms like "NASA"
  /// become "Nasa". Avoid on strings whose casing must be preserved.
  String get toLetterCase =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  /// Title-cases each space-separated word via [toLetterCase].
  /// Note: inherits [toLetterCase]'s behaviour of lower-casing the
  /// remainder of each word, so acronyms are not preserved.
  String get toTitleCase => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toLetterCase)
      .join(' ');

  String sPluralise(num number) => (number == 1) ? this : '${this}s';
}

extension StringListHelper on List<String> {
  String get toBulletedString => map((item) => '\u2022 $item').join('\n\n');

  String bulletedString({String gap = '\n'}) =>
      map((item) => '\u2022 $item').join(gap);
}

extension ImagePathHelper on String {
  bool get isSvg => endsWith('.svg');

  bool get isWebp => endsWith('.webp');
}
''';

const colorHelperTemplate = '''
import 'package:flutter/material.dart';
import 'package:{{project_name}}/constants/app_colors.dart';

class ColorHelper {
  ColorHelper._();

  /// Canonical name -> color map driving both [nameToColor] and [colorToName].
  static final Map<String, Color> _namedColors = {
    'White': const Color(0xFFFFFFFF),
    'Red': const Color(0xFFFF0000),
    'Yellow': const Color(0xFFFFFF00),
    'Blue': const Color(0xFF0000FF),
    'Green': const Color(0xFF90EE90),
    'Purple': const Color(0xFF800080),
    'Cyan': const Color(0xFF00FFFF),
    'Dark Red': const Color(0xFF8B0000),
    'Black': AppColors.primary,
    'Orange': Colors.orange,
    'Pink': Colors.pink,
    'Brown': Colors.brown,
    'Grey': Colors.grey,
    'Navy': const Color(0xFF000080),
    'Beige': const Color(0xFFF5F5DC),
    'Cream': const Color(0xFFFFFDD0),
    'Maroon': const Color(0xFF800000),
    'Teal': const Color(0xFF008080),
    'Gold': const Color(0xFFFFD700),
    'Silver': const Color(0xFFC0C0C0),
    'Coral': const Color(0xFFFF7F50),
    'Mint': const Color(0xFF98FF98),
    'Lavender': const Color(0xFFE6E6FA),
  };

  static String colorToName(Color color) {
    for (final entry in _namedColors.entries) {
      if (entry.value.toARGB32() == color.toARGB32()) return entry.key;
    }
    return 'Unknown';
  }

  static Color nameToColor(String name) {
    final key = name.trim().toLowerCase();
    if (key.isEmpty) return Colors.grey;
    if (key == 'gray') return Colors.grey;
    for (final entry in _namedColors.entries) {
      if (entry.key.toLowerCase() == key) return entry.value;
    }
    return AppColors.textPrimary;
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

const hapticHelperTemplate = '''
import 'package:flutter/services.dart';

class AppHaptics {
  AppHaptics._();

  static void success() => HapticFeedback.mediumImpact();

  static void error() => HapticFeedback.heavyImpact();

  static void tap() => HapticFeedback.lightImpact();

  static void toggle() => HapticFeedback.selectionClick();

  static void destructive() => HapticFeedback.heavyImpact();
}
''';

const urlHelperTemplate = r"""
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:{{project_name}}/utils/helpers/logger_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  static Future<void> launchMapsWithCoordinates({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    try {
      final encodedLabel = label != null ? Uri.encodeComponent(label) : '';
      Uri uri;

      if (Platform.isIOS) {
        uri = Uri.parse(
          'maps://?daddr=$latitude,$longitude${label != null ? '&q=$encodedLabel' : ''}',
        );
      } else {
        uri = Uri.parse(
          'geo:$latitude,$longitude?q=$latitude,$longitude${label != null ? '($encodedLabel)' : ''}',
        );
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        final webUri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
        );
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } else {
          debugPrint('Could not launch maps');
        }
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }

  static Future<void> launchWebsite(String urlString) async {
    try {
      var url = urlString;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppLogger.warning('Could not launch $url');
      }
    } catch (e, s) {
      AppLogger.error('Error launching URL', e, s);
    }
  }
}
""";

const responsiveHelperTemplate = """
import 'package:flutter/material.dart';

class ResponsiveHelper {
  ResponsiveHelper._();

  static const double smallMobileBreakpoint = 380;
  static const double mobileBreakpoint = 600;

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isSmallMobile(BuildContext context) {
    return screenWidth(context) < smallMobileBreakpoint;
  }

  static bool isMobile(BuildContext context) {
    return screenWidth(context) < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= mobileBreakpoint;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static DeviceType getDeviceType(BuildContext context) {
    if (isSmallMobile(context)) return DeviceType.smallMobile;
    if (isMobile(context)) return DeviceType.mobile;
    return DeviceType.tablet;
  }

  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? smallMobile,
  }) {
    if (isTablet(context)) return tablet ?? mobile;
    if (isSmallMobile(context)) return smallMobile ?? mobile;
    return mobile;
  }

  static double fontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? smallMobile,
  }) {
    return responsive<double>(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.1,
      smallMobile: smallMobile ?? mobile * 0.9,
    );
  }

  static EdgeInsets padding(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? smallMobile,
  }) {
    return responsive<EdgeInsets>(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.2,
      smallMobile: smallMobile ?? mobile * 0.8,
    );
  }

  static double widthPercent(BuildContext context, double percent) {
    return screenWidth(context) * (percent / 100);
  }

  static double heightPercent(BuildContext context, double percent) {
    return screenHeight(context) * (percent / 100);
  }

  static double responsiveSize(BuildContext context, double baseSize) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final scaleFactor = shortestSide / 375;
    return baseSize * scaleFactor;
  }

  static int getGridColumnCount(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int smallMobile = 1,
  }) {
    return responsive<int>(
      context,
      mobile: mobile,
      tablet: tablet,
      smallMobile: smallMobile,
    );
  }
}

enum DeviceType { smallMobile, mobile, tablet }

extension ResponsiveExtension on BuildContext {
  bool get isSmallMobile => ResponsiveHelper.isSmallMobile(this);
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  DeviceType get deviceType => ResponsiveHelper.getDeviceType(this);
  double get screenWidth => ResponsiveHelper.screenWidth(this);
  double get screenHeight => ResponsiveHelper.screenHeight(this);
  bool get isLandscape => ResponsiveHelper.isLandscape(this);
  bool get isPortrait => ResponsiveHelper.isPortrait(this);
}
""";

const imageConversionHelperTemplate = r"""
import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImageConversionHelper {
  const ImageConversionHelper._();

  static const _mimeTypes = {
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'webp': 'image/webp',
    'gif': 'image/gif',
    'heic': 'image/heic',
  };

  static Future<List<String>> convertToBase64(List<XFile> images) async {
    final result = <String>[];
    for (final image in images) {
      final bytes = await File(image.path).readAsBytes();
      final base64 = base64Encode(bytes);
      final ext = image.path.toLowerCase().split('.').last;
      final mimeType = _mimeTypes[ext] ?? 'application/octet-stream';
      result.add('data:$mimeType;base64,$base64');
    }
    return result;
  }
}
""";

const phoneNumberParserTemplate = r'''
class PhoneNumberParser {
  PhoneNumberParser._();

  static Map<String, String> parsePhoneNumber(String phoneNumber) {
    try {
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      if (cleanNumber.startsWith('+')) {
        for (var i = 2; i <= 5; i++) {
          if (i <= cleanNumber.length) {
            final potentialCountryCode = cleanNumber.substring(1, i);
            final remainingNumber = cleanNumber.substring(i);

            if (_isValidCountryCode(potentialCountryCode) &&
                remainingNumber.isNotEmpty) {
              return {
                'countryCode': potentialCountryCode,
                'nationalNumber': remainingNumber,
              };
            }
          }
        }
      }

      return {
        'countryCode': '',
        'nationalNumber': cleanNumber,
      };
    } catch (e) {
      return {
        'countryCode': '',
        'nationalNumber': phoneNumber,
      };
    }
  }

  static const _dialingCodes = <String>{
    '1', '7', '20', '27', '30', '31', '32', '33', '34', '36', '39',
    '40', '41', '43', '44', '45', '46', '47', '48', '49', '51', '52',
    '53', '54', '55', '56', '57', '58', '60', '61', '62', '63', '64',
    '65', '66', '81', '82', '84', '86', '90', '91', '92', '93', '94',
    '95', '98', '212', '213', '216', '218', '234', '351', '353', '358',
    '370', '371', '372', '380', '420', '421', '852', '853', '855',
    '856', '880', '886', '960', '961', '962', '963', '964', '965',
    '966', '967', '968', '971', '972', '973', '974', '975', '976',
    '977', '992', '993', '994', '995', '996', '998',
  };

  static bool _isValidCountryCode(String code) => _dialingCodes.contains(code);
}
''';

const extractFileFromUrlHelperTemplate = '''
String getFileNameFromUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  try {
    return Uri.parse(url).pathSegments.last;
  } catch (_) {
    return url.split('/').last;
  }
}
''';

const priceFormatterTemplate = r'''
const _priceDecimalDigits = 2;

String _groupThousands(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String formatPrice(double price, {String currencySymbol = ''}) {
  final isWhole = price == price.truncateToDouble();
  final raw = isWhole
      ? price.toInt().toString()
      : price.toStringAsFixed(_priceDecimalDigits);

  final negative = raw.startsWith('-');
  final unsigned = negative ? raw.substring(1) : raw;

  final parts = unsigned.split('.');
  final grouped = _groupThousands(parts[0]);
  final formatted = parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
  final sign = negative ? '-' : '';

  return '$sign$currencySymbol$formatted';
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

  static Map<String, dynamic>? _extractData(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final responseData = data['data'];
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
    }
    return null;
  }

  static T? parse<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>) fromJson, {
    String? key,
  }) {
    final responseData = _extractData(response);
    if (responseData == null) return null;

    if (key != null) {
      final nested = responseData[key];
      if (nested is Map<String, dynamic>) return fromJson(nested);
      return null;
    }

    return fromJson(responseData);
  }

  static List<T> parseList<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>) fromJson, {
    String? key,
  }) {
    final responseData = _extractData(response);

    List<dynamic>? list;

    if (key != null) {
      list = responseData?[key] as List<dynamic>?;
    } else {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final raw = data['data'];
        if (raw is List) list = raw;
      }
    }

    if (list == null) return [];

    return list
        .whereType<Map<String, dynamic>>()
        .map((e) {
          try {
            return fromJson(e);
          } catch (_) {
            return null;
          }
        })
        .whereType<T>()
        .toList();
  }

  static T? parseValue<T>(Response<dynamic> response, String key) {
    final responseData = _extractData(response);
    return responseData?[key] as T?;
  }
}
''';
