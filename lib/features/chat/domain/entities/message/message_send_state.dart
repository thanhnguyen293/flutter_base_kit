enum MessageSendStatus {
  sending(0),
  success(1),
  failed(2);

  const MessageSendStatus(this.rawValue);

  final int rawValue;

  static MessageSendStatus fromInt(int rawValue) {
    return MessageSendStatus.values.firstWhere(
      (element) => element.rawValue == rawValue,
      orElse: () => MessageSendStatus.success,
    );
  }
}
