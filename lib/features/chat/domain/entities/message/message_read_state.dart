enum MessageReadStatus {
  unread(1),
  read(2),
  delivered(3);

  const MessageReadStatus(this.rawValue);

  final int rawValue;

  static MessageReadStatus fromInt(int rawValue) {
    return MessageReadStatus.values.firstWhere(
      (element) => element.rawValue == rawValue,
      orElse: () => MessageReadStatus.unread,
    );
  }
}
