import 'package:flutter_base_kit/project_imports.dart';

abstract class ReelsRepository {
  Future<List<ReelEntity>> getReels();
}
