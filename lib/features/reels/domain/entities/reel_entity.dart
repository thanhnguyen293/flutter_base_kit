import 'package:flutter_base_kit/project_imports.dart';

part 'reel_entity.freezed.dart';

@freezed
abstract class ReelEntity with _$ReelEntity {
  const factory ReelEntity({
    required String id,
    required String content,
    required String video,
    required int likes,
    required int comments,
    required int views,
  }) = _ReelEntity;
}
