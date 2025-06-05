enum MessageSource {
  self(0),
  other(1),
  sys(2);

  const MessageSource(this.rawValue);

  final int rawValue;

  static MessageSource fromInt(int rawValue) {
    return MessageSource.values.firstWhere(
            (element) => element.rawValue == rawValue,
        orElse: () => MessageSource.self);
  }
}
