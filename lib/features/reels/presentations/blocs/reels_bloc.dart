import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../../../../project_imports.dart';
import '../../domain/entities/controller_status.dart';

part 'reels_bloc.freezed.dart'; //
part 'reels_event.dart'; //
part 'reels_state.dart'; //

class ReelsBloc extends Bloc<ReelsEvent, ReelsState> {
  ReelsBloc({required ReelsService reelsService})
    : _reelsService = reelsService,
      super(const ReelsState()) {
    on<_GetVideosFromApi>(_onGetVideosFromApi);
    on<_OnVideoIndexChanged>(_onVideoIndexChanged, transformer: concurrent());
    on<_UpdateReels>(_onUpdateUrls);
    on<_StatusChanged>(
      (event, emit) => emit(state.copyWith(status: event.status)),
    );
    on<_InitController>(_onInitController, transformer: concurrent());
  }

  final ReelsService _reelsService;
  Timer? _debounceTimer;

  // Constants
  static const int kPageSize = 5;
  static const int kPreloadController = 5;
  static const Duration kInitializationTimeout = Duration(seconds: 10);
  static const Duration kDebounceDelay = Duration(milliseconds: 300);

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _disposeAllControllers();
    return super.close();
  }

  Future<void> _onGetVideosFromApi(
    _GetVideosFromApi event,
    Emitter<ReelsState> emit,
  ) async {
    if (state.status.isPending) return;
    emit(state.copyWith(status: state.status.toPending()));
    try {
      final newReels = await _reelsService.getVideos();
      emit(
        state.copyWith(
          status: ApiStatus.done(),
          reels: [...state.reels, ...newReels],
        ),
      );

      // Initialize controllers for first batch if this is the first load
      if (state.reels.length == newReels.length && newReels.isNotEmpty) {
        final initializeCount = min(kPreloadController, state.reels.length);
        for (int i = 0; i < initializeCount; i++) {
          add(ReelsEvent.initController(reelId: state.reels[i].id));
        }
      }
    } catch (error) {
      emit(state.copyWith(status: ApiStatus.error(error.toString())));
    }
  }

  Future<void> _onVideoIndexChanged(
    _OnVideoIndexChanged event,
    Emitter<ReelsState> emit,
  ) async {
    final newIndex = event.index;
    final oldIndex = state.focusedIndex;

    if (newIndex < 0 ||
        newIndex >= state.reels.length ||
        newIndex == oldIndex) {
      return;
    }
    emit(state.copyWith(focusedIndex: newIndex));
    final item = state.reels[newIndex];
    final controllerStatus = state.controllers[item.id];
    if (controllerStatus != null && controllerStatus.isDone) {
      controllerStatus.controller!.play();
    }

    debugPrint('Index changed: $oldIndex => $newIndex');

    if (state.shouldLoadMore) {
      final pageNum = (state.reels.length / kPageSize).ceil();
      debugPrint('Load more: $pageNum - $kPageSize');
      IsoLateUtils.createIsolate(pageNum, kPageSize);
    }

    // Pause previous video
    if (oldIndex >= 0 && oldIndex < state.reels.length) {
      if (!state.isValidIndex(oldIndex)) return;
      final item = state.reels[oldIndex];
      final controllerStatus = state.controllers[item.id];
      debugPrint('Pause video at index $oldIndex');
      if (controllerStatus != null && controllerStatus.isDone) {
        final controller = controllerStatus.controller!;
        controller.pause();
      }
    }

    // Cleanup distant controllers
    _cleanupDistantControllers(newIndex, emit);
  }

  // void _preloadAdjacentControllers(int currentIndex, Emitter<ReelsState> emit) {
  //   // Preload next videos
  //   for (int i = 1; i <= state.reels.length; i++) {
  //     final targetIndex = currentIndex + i;
  //     if (targetIndex < state.reels.length) {
  //       add(ReelsEvent.initController(reelId: state.reels[targetIndex].id));
  //     }
  //   }
  //
  //   // Preload previous videos
  //   for (int i = 1; i <= state.reels.length; i++) {
  //     final targetIndex = currentIndex - i;
  //     if (targetIndex >= 0) {
  //     }
  //   }
  // }

  Future<void> _cleanupDistantControllers(
    int currentIndex,
    Emitter<ReelsState> emit,
  ) async {
    final lowerBound = currentIndex - kPreloadController;
    final upperBound = currentIndex + kPreloadController;
    debugPrint('Initializing controllers from $lowerBound to $upperBound');

    for (int index = 0; index < state.reels.length; index++) {
      final isCleanUp = !(index >= lowerBound && index <= upperBound);
      final reelId = state.reels[index].id;
      debugPrint('$reelId: $isCleanUp');

      if (!isCleanUp) {
        add(ReelsEvent.initController(reelId: reelId));
      } else {
        final reel = state.reels[index];
        final controller = state.controllers[reel.id]?.controller;
        controller?.dispose();
        emit(
          state.copyWith(
            controllers: {
              ...state.controllers,
              reel.id: ControllerStatus.initial(),
            },
          ),
        );
      }
    }
  }

  void _disposeAllControllers() {
    // for (int i = 0; i < state.controllers.length; i++) {
    //   final controller = state.reels[i].controller;
    //   controller?.dispose().catchError((error) {
    //     debugPrint('❌ Error disposing controller at index $i: $error');
    //   });
    // }
  }

  Future<void> _onUpdateUrls(
    _UpdateReels event,
    Emitter<ReelsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ApiStatus.done(),
        reels: [...state.reels, ...event.urls],
      ),
    );
  }

  FutureOr<void> _onInitController(
    _InitController event,
    Emitter<ReelsState> emit,
  ) async {
    final ReelEntity? item = state.reels.firstWhereOrNull(
      (element) => element.id == event.reelId,
    );
    if (item == null) {
      debugPrint('Item not found at index ${event.reelId}');
      return;
    }
    final controllerStatus = state.controllers[event.reelId];
    if (controllerStatus != null) {
      if (controllerStatus.isPending || controllerStatus.isDone) {
        return;
      }
    }

    // debugPrint(
    //   'Initializing controller at index ${item.id}\n'
    //   'controllerStatus: ${controllerStatus?.status}',
    // );
    emit(
      state.copyWith(
        controllers: {
          ...state.controllers,
          event.reelId: const ControllerStatus.loading(),
        },
      ),
    );
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(item.video),
      );
      await controller.initialize();
      debugPrint('Initialized controller at index ${item.id}');
      emit(
        state.copyWith(
          controllers: {
            ...state.controllers,
            event.reelId: ControllerStatus.done(controller),
          },
        ),
      );
      controller.setLooping(true);
      if (state.currentReel?.id == event.reelId) {
        debugPrint('Play video at index ${item.id}');
        controller.play();
      }
    } catch (error) {
      emit(
        state.copyWith(
          controllers: {
            ...state.controllers,
            event.reelId: ControllerStatus.error(error.toString()),
          },
        ),
      );
      debugPrint(
        '❌ Failed to initialize controller at index ${item.id}: $error',
      );
    }
  }
}

extension ListExtension<T> on List<T> {
  List<T> replaceWhere(bool Function(T item) function, T newItem) {
    return map((item) => function(item) ? newItem : item).toList();
  }
}

extension FirstWhereOrNullExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
