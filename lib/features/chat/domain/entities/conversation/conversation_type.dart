enum RoomType {
  single(1),
  group(2),
  discussion(3);

  const RoomType(this.rawValue);

  final int rawValue;

  static RoomType fromInt(int rawValue) {
    return RoomType.values.firstWhere(
      (element) => element.rawValue == rawValue,
      orElse: () => RoomType.single,
    );
  }
}
