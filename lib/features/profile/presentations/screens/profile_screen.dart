import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../shared/widgets/app_paging_list/app_paging_controller.dart';
import '../../../../shared/widgets/app_paging_list/app_paging_list.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late final TabController primaryTC;
  final GlobalKey<ExtendedNestedScrollViewState> _key =
      GlobalKey<ExtendedNestedScrollViewState>();
  final ValueNotifier<bool> isPinned = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    primaryTC = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    primaryTC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double pinnedHeaderHeight = statusBarHeight + kToolbarHeight;
    return Scaffold(
      body: ExtendedNestedScrollView(
        key: _key,
        pinnedHeaderSliverHeightBuilder: () {
          return pinnedHeaderHeight;
        },
        headerSliverBuilder: (BuildContext context, bool isScrolled) {
          isPinned.value = isScrolled;
          return <Widget>[
            SliverAppBar(
              pinned: true,
              title: Text('load more list: $isScrolled'),
            ),
            SliverToBoxAdapter(
              child: VisibilityDetector(
                key: const ValueKey('TabViewItem'),
                onVisibilityChanged: (VisibilityInfo info) {
                  debugPrint('TabViewItem is visible: ${info.visibleFraction}');
                },
                child: SizedBox(
                  height: 300,
                  child: const ColoredBox(color: Colors.transparent),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: _TabBarDelegate(
                tabBar: TabBar(
                  controller: primaryTC,
                  labelColor: Colors.blue,
                  indicatorColor: Colors.blue,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 2.0,
                  isScrollable: false,
                  unselectedLabelColor: Colors.grey,
                  tabs: const <Tab>[Tab(text: 'Tab0'), Tab(text: 'Tab1')],
                ),
              ),
            ),
          ];
        },
        onlyOneScrollInBody: true,
        body: TabBarView(
          controller: primaryTC,
          children: const <Widget>[
            TabViewItem(Key('Tab0')),
            TabViewItem(Key('Tab1')),
          ],
        ),
      ),
    );
  }
}

class TabViewItem extends StatefulWidget {
  const TabViewItem(this.uniqueKey, {super.key, this.isPinned = false});

  final Key uniqueKey;
  final bool isPinned;

  @override
  State<TabViewItem> createState() => _TabViewItemState();
}

class _TabViewItemState extends State<TabViewItem>
    with AutomaticKeepAliveClientMixin {
  final _pagingController = AppPagingController<int, String>(
    getNextPageKey: (PagingState<int, String> state) {
      final pages = state.pages;
      if (pages.isEmptyOrNoData()) return 0;

      final lastPageLength =
          pages.getOrNull((state.keys?.length ?? 0) - 1)?.length ?? 0;
      final isOutOfItems = lastPageLength < 50;

      if (isOutOfItems) return null;

      return (state.keys?.last ?? -1) + 1;
    },
    fetchListData: (int offset, int limit) async {
      return Future.delayed(
        Duration(milliseconds: 200),
        () => List.generate(limit, (index) => 'Item ${offset + index}'),
      );
    },
    pageSize: 50,
  );

  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(covariant TabViewItem oldWidget) {
    if (widget.isPinned != oldWidget.isPinned) {
      _scrollController.jumpTo(0.0);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ExtendedVisibilityDetector(
      uniqueKey: widget.uniqueKey,
      child: RefreshIndicator(
        onRefresh: () async {
          // Reset the paging controller to refresh the data
          _pagingController.refreshSilent();
        },
        child: AppPagingList(
          enablePullDown: false,
          // scrollController: _scrollController,
          pagingController: _pagingController,
          pageSize: 50,
          itemBuilder: (BuildContext context, item, int index) {
            return ListTile(
              title: Text('Item $index'),
              subtitle: Text('Details for item $index'),
            );
          },
          fetchListData: (int offset, int limit) {
            // Simulate a network call
            return Future.delayed(
              Duration(milliseconds: 200),
              () => List.generate(limit, (index) => 'Item ${offset + index}'),
            );
          },
        ),
      ),
    );
    return ExtendedVisibilityDetector(
      uniqueKey: widget.uniqueKey,
      child: AppPagingList(
        key: widget.uniqueKey,
        itemBuilder: (BuildContext context, item, int index) {
          return ListTile(
            title: Text('Item $index'),
            subtitle: Text('Details for item $index'),
          );
        },
        fetchListData: (int offset, int limit) {
          // Simulate a network call
          return Future.delayed(
            Duration(seconds: 1),
            () => List.generate(limit, (index) => 'Item ${offset + index}'),
          );
        },
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate({required this.tabBar});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isPinned = shrinkOffset > 0;
    return Container(color: isPinned ? Colors.red : Colors.blue, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
