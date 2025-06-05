import 'package:flutter_list_view/flutter_list_view.dart';

import '../../project_imports.dart';

class InfiniteScrollExample extends StatelessWidget {
  const InfiniteScrollExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FlutterListView Infinity Scroll")),
      body: FlutterInfiniteListView<String>(
        pageSize: 20,
        onLoadMore: (page) async {
          // Giả lập API
          await Future.delayed(const Duration(seconds: 1));
          return List.generate(20, (i) => 'Item ${page * 20 + i}');
        },
        itemBuilder: (context, item, index) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              item,
              style: const TextStyle(fontSize: 18),
            ),
          );
        },
      ),
    );
  }
}

typedef ItemWidgetBuilder<T> =
    Widget Function(BuildContext context, T item, int index);
typedef LoadMoreCallback<T> = Future<List<T>> Function(int page);

class FlutterInfiniteListView<T> extends StatefulWidget {
  final ItemWidgetBuilder<T> itemBuilder;
  final LoadMoreCallback<T> onLoadMore;
  final int pageSize;
  final bool reverse;
  final EdgeInsets padding;

  const FlutterInfiniteListView({
    super.key,
    required this.itemBuilder,
    required this.onLoadMore,
    this.pageSize = 20,
    this.padding = EdgeInsets.zero,
    this.reverse = false,
  });

  @override
  State<FlutterInfiniteListView<T>> createState() =>
      _FlutterInfiniteListViewState<T>();
}

class _FlutterInfiniteListViewState<T>
    extends State<FlutterInfiniteListView<T>> {
  final controller = FlutterListViewController();
  final List<T> items = [];
  bool isLoading = false;
  int page = 0;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMore();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.position.addListener(_onScroll);
    });
  }

  void _onScroll() {
    final offset = controller.position.pixels;
    final max = controller.position.maxScrollExtent;
    if (!isLoading && hasMore && offset >= max - 300) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => isLoading = true);

    final newItems = await widget.onLoadMore(page);
    setState(() {
      items.addAll(newItems);
      isLoading = false;
      page++;
      hasMore = newItems.length >= widget.pageSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterListView(
      controller: controller,
      reverse: widget.reverse,
      delegate: FlutterListViewDelegate((context, index) {
        if (index >= items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return widget.itemBuilder(context, items[index], index);
      }, childCount: isLoading ? items.length + 1 : items.length),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
