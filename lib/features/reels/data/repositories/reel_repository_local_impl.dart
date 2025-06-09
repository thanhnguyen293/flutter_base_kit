import 'package:flutter_base_kit/project_imports.dart';

class ReelsRepositoryLocalImpl implements ReelsRepository {
  @override
  Future<List<ReelEntity>> getReels() {
    return Future.value([]);
  }
}
