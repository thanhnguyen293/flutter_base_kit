import 'package:freezed_annotation/freezed_annotation.dart';
part 'api_status.freezed.dart';

@freezed
abstract class ApiStatus with _$ApiStatus {
  const ApiStatus._();

  const factory ApiStatus.initial() = ApiStatusInitial;

  const factory ApiStatus.loading() = ApiStatusLoading;

  const factory ApiStatus.refreshing() = ApiStatusRefreshing;

  const factory ApiStatus.done() = ApiStatusDone;

  const factory ApiStatus.error(String failure) = ApiStatusError;

  ApiStatus toPending() => switch (this) {
    const ApiStatus.initial() => const ApiStatus.loading(),
    const ApiStatus.loading() => const ApiStatus.loading(),
    _ => const ApiStatus.refreshing(),
  };

  bool get isInitial => this is ApiStatusInitial;

  bool get isLoading => this is ApiStatusLoading;

  bool get isRefreshing => this is ApiStatusRefreshing;

  bool get isDone => this is ApiStatusDone;

  bool get isError => this is ApiStatusError;

  bool get isInitialOrPending => isInitial || isPending;

  bool get isPending => isLoading || isRefreshing;

  bool get isCompleted => isDone || isError;

  String? get failure => switch (this) {
    ApiStatusError(:final failure) => failure,
    _ => null,
  };
}
