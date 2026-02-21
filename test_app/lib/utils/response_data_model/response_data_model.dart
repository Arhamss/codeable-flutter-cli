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
