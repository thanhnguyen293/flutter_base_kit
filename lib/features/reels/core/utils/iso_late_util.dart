import '../../../../project_imports.dart';

class IsoLateUtils {
  static Future createIsolate(int pageNum, int pageSize) async {
    getIt<ReelsBloc>().add(
      ReelsEvent.statusChanged(status: ApiStatus.loading()),
    );

    final ReceivePort mainReceivePort = ReceivePort();

    await Isolate.spawn(_getVideosTask, [
      mainReceivePort.sendPort,
      getIt<ReelsService>(),
    ]);

    final SendPort isolateSendPort = await mainReceivePort.first;

    final ReceivePort isolateResponseReceivePort = ReceivePort();

    isolateSendPort.send([
      pageNum,
      pageSize,
      isolateResponseReceivePort.sendPort,
    ]);

    final _urls = await isolateResponseReceivePort.first;

    getIt<ReelsBloc>().add(ReelsEvent.updateReels(urls: _urls));
  }

  static void _getVideosTask(List<dynamic> args) async {
    final SendPort mySendPort = args[0];
    final ReelsService reelsService = args[1];

    final ReceivePort isolateReceivePort = ReceivePort();
    mySendPort.send(isolateReceivePort.sendPort);

    await for (var message in isolateReceivePort) {
      if (message is List) {
        final int pageNum = message[0];
        final int pageSize = message[1];
        final SendPort isolateResponseSendPort = message[2];

        final List<ReelEntity> _urls = await reelsService.getVideos();

        isolateResponseSendPort.send(_urls);
      }
    }
  }
}
