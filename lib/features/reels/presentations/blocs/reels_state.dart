part of 'reels_bloc.dart';

@freezed
abstract class ReelsState with _$ReelsState {
  const factory ReelsState({
    @Default(ApiStatus.initial()) ApiStatus status,
    @Default([]) List<ReelEntity> reels,
    @Default({}) Map<String, ControllerStatus> controllers,
    @Default(0) int focusedIndex,
  }) = _ReelsState;
}

const int kPreloadLimit = 5; //Number of videos to preload
const int kLatency = 2; //Duration in seconds

extension ReelsStateExtension on ReelsState {
  ReelEntity? get currentReel => reels.isNotEmpty ? reels[focusedIndex] : null;

  VideoPlayerController?  controllerId(String id) => controllers[id]?.controller;


  bool get shouldLoadMore => focusedIndex + kPreloadLimit >= reels.length && !status.isPending;

  bool isValidIndex(int index) {
    return index >= 0 && index < reels.length;
  }


}
