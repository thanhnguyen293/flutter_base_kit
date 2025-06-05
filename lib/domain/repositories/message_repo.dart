abstract class MessageRepo {
  Future<void> sendMessage(String message);

  Future<List<String>> getMessages({int pageKey = 1, int pageSize = 20});
}

class MessageRepoImpl implements MessageRepo {
  MessageRepoImpl._();

  static MessageRepo? _instance;

  static MessageRepo get instance => _instance ??= MessageRepoImpl._();

  @override
  Future<void> sendMessage(String message) {
    // TODO: implement sendMessage
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getMessages({int pageKey = 1, int pageSize = 20}) {
    return Future.delayed(const Duration(milliseconds: 300), () {
      return mockMessage.sublist((pageKey - 1) * pageSize, pageKey * pageSize);
    });
  }
}

final List<String> mockMessage = List.generate(
  1000,
  (index) => 'This is a mock message ${index + 1}',
);
