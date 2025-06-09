import 'package:flutter_base_kit/project_imports.dart';
part 'controller_status.freezed.dart';

@freezed
sealed class ControllerStatus with _$ControllerStatus {
  const ControllerStatus._();

  const factory ControllerStatus.initial() = ControllerStatusInitial;

  const factory ControllerStatus.loading() = ControllerStatusLoading;

  const factory ControllerStatus.refreshing() = ControllerStatusRefreshing;

  const factory ControllerStatus.done(VideoPlayerController controller) =
      ControllerStatusDone;

  const factory ControllerStatus.error(String failure) = ControllerStatusError;

  ControllerStatus toPending() => switch (this) {
    const ControllerStatus.initial() ||
    const ControllerStatus.loading() => const ControllerStatus.refreshing(),
    _ => const ControllerStatus.refreshing(),
  };

  bool get isInitial => this is ControllerStatusInitial;

  bool get isLoading => this is ControllerStatusLoading;

  bool get isRefreshing => this is ControllerStatusRefreshing;

  bool get isDone => this is ControllerStatusDone;

  bool get isError => this is ControllerStatusError;

  bool get isInitialOrPending => isInitial || isPending;

  bool get isPending => isLoading || isRefreshing;

  bool get isCompleted => isDone || isError;

  String get status => switch (this) {
    ControllerStatusInitial() => 'initial',
    ControllerStatusLoading() => 'loading',
    ControllerStatusRefreshing() => 'refreshing',
    ControllerStatusDone() => 'done',
    ControllerStatusError() => 'error',
  };

  String? get failure => switch (this) {
    ControllerStatusError(:final failure) => failure,
    _ => null,
  };

  VideoPlayerController? get controller => switch (this) {
    ControllerStatusDone(:final controller) => controller,
    _ => null,
  };
}
