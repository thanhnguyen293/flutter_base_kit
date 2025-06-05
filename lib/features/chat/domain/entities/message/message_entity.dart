import 'package:flutter_base_kit/project_imports.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_entity.freezed.dart';

@freezed
sealed class MessageEntity with _$MessageEntity {
  const factory MessageEntity({
    required String messageId,
    required String senderId,
    required MessageType type,
    required MessageSource source,
    required MessageReadStatus readStatus,
    required MessageSendStatus sendStatus,
    required String encryptedContent,
    required RoomType roomType,
    required int createdAt,
    required int updatedAt,
    required String nodeAddress,
    required int version,
    String? content,
    int? expiredTime,
    String? avatarId,
    String? avatarUrl,
    String? nickname,
    @Default(false) bool isSelected,
    String? domain,
    String? permissionCode,
    String? originalNickname,
    int? experienceExpireTime,
    @Default(false) bool hasDownloadError,
    @Default(0) int isOwner,
    @Default(0) int isAdmin,
    @Default(0) int isGroupMember,
    MessageTranslateState? translateState,
    String? translatedContent,
  }) = _MessageEntity;
}

extension MessageEntityX on MessageEntity {
  bool isSentBy(String currentUserId) => senderId == currentUserId;

  bool get isExpired {
    if (expiredTime == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now > expiredTime!;
  }

  String get displayName => nickname ?? originalNickname ?? 'Unknown';

  String get formattedCreatedAt {
    final date = DateTime.fromMillisecondsSinceEpoch(createdAt);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
