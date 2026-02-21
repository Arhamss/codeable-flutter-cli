class AppApiException implements Exception {
  AppApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

String extractApiErrorMessage(Object e, String fallback) {
  return e is AppApiException ? e.message : fallback;
}
