enum MessageTranslateState {
  none(0),
  translating(1),
  translated(2),
  failed(3);

  const MessageTranslateState(this.rawValue);

  final int rawValue;

  static MessageTranslateState fromInt(int? rawValue) {
    return MessageTranslateState.values.firstWhere(
      (element) => element.rawValue == rawValue,
      orElse: () => MessageTranslateState.none,
    );
  }
}
