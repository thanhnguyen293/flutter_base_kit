part of 'reels_bloc.dart';

@freezed
class ReelsEvent with _$ReelsEvent {
  const factory ReelsEvent.getVideosFromApi({required String? cursor}) = _GetVideosFromApi;

  const factory ReelsEvent.statusChanged({required ApiStatus status}) =
      _StatusChanged;

  const factory ReelsEvent.updateReels({required List<ReelEntity> urls}) =
      _UpdateReels;

  const factory ReelsEvent.onVideoIndexChanged({required int index}) =
      _OnVideoIndexChanged;

  const factory ReelsEvent.initController({
    required String reelId,
    @Default(false) bool autoPlay,
  }) = _InitController;
}

//
// const factory PreloadEvent.getVideosFromApi() = _GetVideosFromApi;
// const factory PreloadEvent.setLoading() = _SetLoading;
// const factory PreloadEvent.updateUrls(List<String> urls) = _UpdateUrls;
// const factory PreloadEvent.onVideoIndexChanged(int index) =
// _OnVideoIndexChanged;
