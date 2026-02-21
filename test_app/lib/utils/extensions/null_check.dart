import 'dart:developer';

import 'package:flutter/foundation.dart';

extension NullCheck on Object? {
  bool get isNull => this == null;

  bool get isNotNull => this != null;
}

extension NullOrEmptyStringCheck on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotNullAndNotEmpty => this != null && this!.isNotEmpty;
}

extension NullOrEmptyListCheck<T> on List<T>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotNullAndNotEmpty => this != null && this!.isNotEmpty;
}

void debugLog(
  String message, {
  StackTrace? stackTrace,
}) {
  if (kDebugMode) {
    log(message, stackTrace: stackTrace);
  }
}
