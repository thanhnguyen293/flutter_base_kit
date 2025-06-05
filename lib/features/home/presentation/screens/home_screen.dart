import 'package:flutter_base_kit/features/profile/presentations/screens/profile_screen.dart';
import 'package:flutter_base_kit/shared/paging_controller_x.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../domain/repositories/message_repo.dart';
import '../../../../project_imports.dart';
import '../../../chat/presentations/screens/single_chat_screen.dart';
import '../../../infinity_scroll/infinity_scroll_example.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final _pagingController = PagingController<int, String>(
    getNextPageKey: (state) {
      debugPrint(
        'state: ${state.keys?.length}\n'
        'state: ${state.pages?.length}\n',
      );
      return (state.keys?.last ?? 0) + 1;
    },
    fetchPage: (pageKey) {
      return messageRepo.getMessages(pageKey: pageKey, pageSize: 20);
    },
  );
  final scrollController = ScrollController();

  final MessageRepo messageRepo = MessageRepoImpl.instance;

  int newItemIndex = 0;

  addNewItem() {
    final newItem = '🆕 New Item ${++newItemIndex}';
    _pagingController.addNewItem(newItem);
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomePage'),
        backgroundColor: Colors.teal[200],
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 10,
          children: [
            AppButton(
              child: Text('Profile Page'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            AppButton(
              child: Text('InfiniteScrollExample'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const InfiniteScrollExample(),
                  ),
                );
              },
            ),
            AppButton(
              child: Text('SingleChatScreen'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SingleChatScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewItem,
        child: const Icon(Icons.add),
      ),
      // body: RefreshIndicator(
      //   onRefresh: () async {
      //     _pagingController.refresh();
      //   },
      //   child: PagingListener(
      //     controller: _pagingController,
      //     builder: (context, state, fetchNextPage) {
      //       return PagedListView<int, String>(
      //         state: state,
      //         fetchNextPage: fetchNextPage,
      //         scrollController: scrollController,
      //         builderDelegate: PagedChildBuilderDelegate(
      //           itemBuilder: (context, item, index) {
      //             return ListTile(
      //               title: Text(item),
      //               subtitle: Text('Details for item'),
      //             );
      //           },
      //         ),
      //       );
      //     },
      //   ),
      // ),
    );
  }
}
