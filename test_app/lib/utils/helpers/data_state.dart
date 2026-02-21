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
