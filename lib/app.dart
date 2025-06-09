import 'dependencies.dart';
import 'project_imports.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ReelsBloc>.value(
          value:
              getIt<ReelsBloc>()..add(ReelsEvent.getVideosFromApi(cursor: '')),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.instance.config(),
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink),
        ),
      ),
    );
  }
}
