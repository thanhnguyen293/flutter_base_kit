import '../../../../project_imports.dart';

@RoutePage()
class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReelsBloc, ReelsState>(
      builder: (context, state) {
        return Scaffold(
          floatingActionButton: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                child: const Icon(Icons.arrow_upward),
                onPressed: () {
                  if (state.focusedIndex > 0) {
                    pageController.animateToPage(
                      state.focusedIndex - 1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'pause',
                child: const Icon(Icons.arrow_downward),
                onPressed: () {
                  if (state.focusedIndex < state.reels.length - 1) {
                    pageController.animateToPage(
                      state.focusedIndex + 1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  }
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              PageView.builder(
                controller: pageController,
                itemCount: state.reels.length,
                scrollDirection: Axis.vertical,
                onPageChanged: (index) {
                  context.read<ReelsBloc>().add(
                    ReelsEvent.onVideoIndexChanged(index: index),
                  );
                },
                itemBuilder: (_, index) {
                  final bool _isLoading =
                      (state.status.isInitialOrPending &&
                          index == state.reels.length - 1);
                  final item = state.reels[index];

                  final rangeShowItem = (index - state.focusedIndex).abs() <= 1;
                  if (!rangeShowItem) return const SizedBox();
                  return ReelItem(
                    isLoading: _isLoading,
                    reel: item,
                    controller: state.controllerId(item.id),
                  );
                },
              ),
              Align(
                alignment: Alignment.topRight,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current index: ${state.focusedIndex} -> ${state.reels[state.focusedIndex].id}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        '[${state.controllers.entries.where((e) => e.value.controller != null).map((e) => e.key).join(', ')}]',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        '[${state.controllers.entries.where((e) => (e.value.controller != null && e.value.isDone)).map((e) => e.key).join(', ')}]',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        '${state.focusedIndex}/[${state.reels.map((e) => e.id).join(', ')}]',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProcessWidget extends StatefulWidget {
  const ProcessWidget({super.key, required this.controller});

  final VideoPlayerController? controller;

  @override
  State<ProcessWidget> createState() => _ProcessWidgetState();
}

class _ProcessWidgetState extends State<ProcessWidget> {
  late Duration position;
  late Duration duration;

  @override
  void initState() {
    super.initState();
    duration = widget.controller!.value.duration;
    position = widget.controller!.value.position;
    widget.controller!.addListener(_listener);
  }

  @override
  void didUpdateWidget(covariant ProcessWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller!.removeListener(_listener);
      widget.controller!.addListener(_listener);
      setState(() {
        duration = widget.controller!.value.duration;
        position = widget.controller!.value.position;
      });
    }
  }

  void _listener() {
    setState(() {
      position = widget.controller!.value.position;
    });
  }

  // @override
  // void didUpdateWidget(covariant ProcessWidget oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.controller != oldWidget.controller) {
  //     oldWidget.controller!.removeListener(_listener);
  //     widget.controller!.addListener(_listener);
  //     setState(() {
  //       duration = widget.controller!.value.duration;
  //       position = widget.controller!.value.position;
  //     });
  //   }
  // }

  @override
  void dispose() {
    widget.controller!.removeListener(_listener);
    super.dispose();
  }

  double get progress {
    final durationMs = widget.controller!.value.duration.inMilliseconds;
    final positionMs = widget.controller!.value.position.inMilliseconds;

    if (durationMs == 0) return 0.0;

    final progress = positionMs / durationMs;

    // Clamp between 0.0 and 1.0 to avoid overflows or NaN
    return progress.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${position.toMMSS()}/${duration.toMMSS()}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white60,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ],
    );
  }
}

extension DurationFormat on Duration {
  String toHHMMSS() {
    // Helper function to ensure 2-digit formatting
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = twoDigits(inHours);
    final minutes = twoDigits(inMinutes.remainder(60));
    final seconds = twoDigits(inSeconds.remainder(60));
    if (hours != '00') {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  String toMMSS() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = twoDigits(inMinutes);
    final seconds = twoDigits(inSeconds.remainder(60));

    return '$minutes:$seconds';
  }
}
