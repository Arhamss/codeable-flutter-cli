import 'package:equatable/equatable.dart';

class ApiError extends Equatable {
  const ApiError({
    required this.code,
    required this.message,
    required this.timestamp,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String?,
      message: json['message'] as String,
      timestamp: json['timestamp'] as String?,
    );
  }

  final String? code;
  final String message;
  final String? timestamp;

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'timestamp': timestamp,
      };

  @override
  List<Object?> get props => [code, message, timestamp];

  @override
  String toString() => '\$code: \$message';
}
