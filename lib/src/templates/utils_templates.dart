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
import 'package:toastification/toastification.dart';
import 'package:{{project_name}}/exports.dart';

class ToastHelper {
  static void showErrorToast(String? message) {
    toastification.show(
      type: ToastificationType.error,
      backgroundColor: AppColors.error,
      borderRadius: BorderRadius.circular(48),
      borderSide: BorderSide.none,
      icon: Padding(
        padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
        child: SvgPicture.asset(AssetPaths.errorIcon, height: 24, width: 24),
      ),
      title: Text(
        message ?? 'Something went wrong. Please try again later.',
        style: const TextStyle(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w500,
          fontSize: 16,
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
      showProgressBar: false,
    );
  }

  static void showSuccessToast(String message) {
    toastification.show(
      type: ToastificationType.success,
      backgroundColor: AppColors.positiveBottomStatusBackground,
      borderRadius: BorderRadius.circular(48),
      borderSide: BorderSide.none,
      icon: Padding(
        padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
        child: SvgPicture.asset(AssetPaths.successIcon, height: 24, width: 24),
      ),
      title: Text(
        message,
        style: const TextStyle(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: false,
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
      icon: Padding(
        padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
        child: SvgPicture.asset(AssetPaths.infoIcon, height: 24, width: 24),
      ),
      title: Text(
        message,
        style: const TextStyle(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w500,
          fontSize: 16,
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
      showProgressBar: false,
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
      length > 0 ? '\${this[0].toUpperCase()}\${substring(1).toLowerCase()}' : '';

  String get toTitleCase => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toLetterCase)
      .join(' ');

  String sPluralise(num number) => (number == 1) ? this : '\${this}s';
}

extension StringListHelper on List<String> {
  String get toBulletedString => map((item) => '\\u2022 \$item').join('\\n\\n');

  String bulletedString({String gap = '\\n'}) =>
      map((item) => '\\u2022 \$item').join(gap);
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
        color: color ?? AppColors.blackPrimary.withValues(alpha: 0.1),
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
