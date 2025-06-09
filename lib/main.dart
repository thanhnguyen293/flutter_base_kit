import 'dart:isolate';

import 'dependencies.dart';
import 'project_imports.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  init();
  runApp(const MyApp());
}
