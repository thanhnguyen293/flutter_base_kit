import 'project_imports.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerLazySingleton<ReelsService>(() => ReelsServiceLocalImpl());
  getIt.registerLazySingleton<ReelsBloc>(
    () => ReelsBloc(reelsService: getIt<ReelsService>()),
  );
}
