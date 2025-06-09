import 'package:flutter_base_kit/project_imports.dart';

abstract class ReelsService {
  Future<List<ReelEntity>> getVideos({String? cursor});
}
