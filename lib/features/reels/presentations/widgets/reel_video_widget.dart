import '../../../../project_imports.dart';

class ReelItem extends StatelessWidget {
  const ReelItem({
    Key? key,
    required this.isLoading,
    required this.reel,
    required this.controller,
  }) : super(key: key);

  final bool isLoading;
  final ReelEntity reel;
  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final aspectRatio = controller?.value.aspectRatio ?? 1;
    return GestureDetector(
      onTap: () {
        if (controller == null) return;
        if (controller!.value.isPlaying) {
          controller!.pause();
        } else {
          controller!.play();
        }
      },
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Stack(
          children: [
            if (controller == null) ...{
              Center(child: Text('Content not found')),
            } else ...[
              Align(
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: VideoPlayer(controller!),
                ),
              ),
              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: ProcessWidget(controller: controller),
              // ),
            ],
          ],
        ),
      ),
    );
  }
}
