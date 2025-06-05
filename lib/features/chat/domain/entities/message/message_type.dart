import 'package:freezed_annotation/freezed_annotation.dart';

@JsonValue('rawValue')
enum MessageType {
  text(1),
  systemSingle(2),
  audio(3),
  video(4),
  file(5),
  image(6),
  location(7),
  custom(8),
  link(9),
  contactCard(10),
  forwarded(11),
  quoted(12),
  systemGroup(13),
  audioVideoCall(14),
  blockNotice(15),
  recalled(16),
  redEnvelope(17),
  transfer(18);

  const MessageType(this.rawValue);

  final int rawValue;

  static MessageType fromInt(int rawValue) {
    return MessageType.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => MessageType.text,
    );
  }
}
