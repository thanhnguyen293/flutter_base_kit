import 'package:flutter_list_view/flutter_list_view.dart';

import '../../../../project_imports.dart';
import '../../../infinity_scroll/infinity_scroll_example.dart';
import '../../data/repositories/mock_message_repository.dart';

class SingleChatScreen extends StatefulWidget {
  const SingleChatScreen({super.key});

  @override
  State<SingleChatScreen> createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  final MockMessageRepository _messageRepository = MockMessageRepository();

  Future<List<MessageEntity>> _loadMore(int page) async {
    return _messageRepository.getMessages(pageKey: page, limit: 20);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Single Chat'),
        backgroundColor: Colors.teal[200],
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to a new chat screen or perform an action
            },
          ),
        ],
      ),
      body: FlutterInfiniteListView<MessageEntity>(
        reverse: true,
        pageSize: 20,
        itemBuilder: (BuildContext context, item, int index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                constraints: const BoxConstraints(maxWidth: 300),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.teal[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.teal[400]!,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  item.content ?? 'No content',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          );
        },
        onLoadMore: _loadMore,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate to a new chat screen or perform an action
              },
            ),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Type a message',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                // Send the message
              },
            ),
          ],
        ),
      ),
    );
  }
}
