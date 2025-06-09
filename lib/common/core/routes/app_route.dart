import 'package:flutter_base_kit/project_imports.dart';

part 'app_route.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  static AppRouter? _instance;

  static AppRouter get instance => _instance ??= AppRouter();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: MainRoute.page,
      initial: true,
      children: [
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: ReelsRoute.page),
      ],
    ),
  ];
}
