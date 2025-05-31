import 'package:flutter/material.dart';
import 'package:flutter_base_kit/shared/widgets/app_paging_list/paging_config.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'app_paging_controller.dart';

typedef PagingListFetchDelegate<T> =
    Future<List<T>> Function(int offset, int limit);

class AppPagingList<T> extends StatefulWidget {
  const AppPagingList({
    required this.itemBuilder,
    required this.fetchListData,
    super.key,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.separatorBuilder,
    this.pageSize = 20,
    this.pagingController,
    this.onlyOnePage = false,
    this.noItemsFoundIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
    this.onEmpty,
    this.onNotEmpty,
    this.reverse = false,
    this.enablePullDown = true,
    this.delayFetch,
    this.scrollController,
    this.isSliver = false,
    this.onPullDown,
    this.initialOffsetIndex = 1,
  });

  final AppPagingController<int, T>? pagingController;
  final int initialOffsetIndex;
  final bool isSliver;
  final int pageSize;
  final ItemWidgetBuilder<T> itemBuilder;
  final PagingListFetchDelegate<T>? fetchListData;
  final IndexedWidgetBuilder? separatorBuilder;

  // Indicator builders
  final WidgetBuilder? noItemsFoundIndicatorBuilder;
  final WidgetBuilder? noMoreItemsIndicatorBuilder;
  final WidgetBuilder? firstPageProgressIndicatorBuilder;
  final WidgetBuilder? newPageProgressIndicatorBuilder;
  final WidgetBuilder? firstPageErrorIndicatorBuilder;
  final WidgetBuilder? newPageErrorIndicatorBuilder;

  // Callbacks
  final VoidCallback? onEmpty;
  final VoidCallback? onNotEmpty;
  final void Function(AppPagingController<int, T> controller)? onPullDown;
  final Duration? delayFetch;

  // Paging params
  final bool onlyOnePage;

  // ListView params
  final ScrollController? scrollController;
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsets? padding;
  final bool reverse;
  final bool enablePullDown;

  @override
  State<AppPagingList<T>> createState() => _AppPagingListState<T>();
}

class _AppPagingListState<T> extends State<AppPagingList<T>> {
  late final AppPagingController<int, T> _pagingController;

  bool get _shouldDisposePagingController => widget.pagingController == null;

  @override
  void initState() {
    super.initState();
    _pagingController =
        widget.pagingController ??
        AppPagingController<int, T>(
          getNextPageKey: _getNextPageKey,
          appFetchPageCallback: _fetchPageCallback,
          pageSize: widget.pageSize,
        );
  }

  int? _getNextPageKey(PagingState<int, T> state) {
    if (widget.onlyOnePage && (state.keys?.length ?? 0) >= 1) {
      return null;
    }

    final pages = state.pages;
    if (pages.isEmptyOrNoData()) return 0;

    final lastPageLength =
        pages.getOrNull((state.keys?.length ?? 0) - 1)?.length ?? 0;
    final isOutOfItems = lastPageLength < widget.pageSize;

    if (isOutOfItems) return null;

    return (state.keys?.last ?? -1) + 1;
  }

  Future<List<T>> _fetchPageCallback(int pageKey, int pageSize) async {
    if (widget.fetchListData == null) {
      throw Exception('fetchListData is required');
    }

    try {
      final result = await widget.fetchListData!(
        pageKey + widget.initialOffsetIndex,
        pageSize,
      );

      debugPrint('Fetched page $pageKey: ${result.length} items');

      // Only trigger callbacks for first page
      if (pageKey == widget.initialOffsetIndex) {
        _handleFirstPageResult(result);
      }

      return result;
    } catch (e) {
      debugPrint('Error fetching page $pageKey: $e');
      rethrow;
    }
  }

  void _handleFirstPageResult(List<T> result) {
    if (result.isEmpty) {
      widget.onEmpty?.call();
    } else {
      widget.onNotEmpty?.call();
    }
  }

  @override
  void dispose() {
    if (_shouldDisposePagingController) {
      _pagingController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagingListener<int, T>(
      controller: _pagingController,
      builder: _buildPagingContent,
    );
  }

  Widget _buildPagingContent(
    BuildContext context,
    PagingState<int, T> state,
    NextPageCallback fetchNextPage,
  ) {
    if (widget.isSliver) {
      return _buildSliverList(state, fetchNextPage);
    }

    final pagedListView = _buildListView(state, fetchNextPage);

    // Skip RefreshIndicator if pull-down is disabled and shrinkWrap is true
    if (!widget.enablePullDown && widget.shrinkWrap) {
      return pagedListView;
    }

    return RefreshIndicator(onRefresh: _handleRefresh, child: pagedListView);
  }

  Widget _buildSliverList(
    PagingState<int, T> state,
    NextPageCallback fetchNextPage,
  ) {
    final sliverList = PagedSliverList<int, T>.separated(
      state: state,
      fetchNextPage: fetchNextPage,
      builderDelegate: _createBuilderDelegate(),
      separatorBuilder: _createSeparatorBuilder(),
    );

    if (widget.padding != null) {
      return SliverPadding(padding: widget.padding!, sliver: sliverList);
    }

    return sliverList;
  }

  Widget _buildListView(
    PagingState<int, T> state,
    NextPageCallback fetchNextPage,
  ) {
    return PagedListView<int, T>.separated(
      state: state,
      fetchNextPage: fetchNextPage,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      scrollController: widget.scrollController,
      reverse: widget.reverse,
      scrollDirection: widget.scrollDirection,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: _calculatePadding(),
      builderDelegate: _createBuilderDelegate(),
      separatorBuilder: _createSeparatorBuilder(),
      cacheExtent: 10000,
    );
  }

  Future<void> _handleRefresh() async {
    if (!widget.enablePullDown) return;

    if (widget.onPullDown != null) {
      widget.onPullDown!(_pagingController);
    } else {
      _pagingController.refresh();
    }
  }

  EdgeInsets _calculatePadding() {
    final basePadding = widget.padding ?? EdgeInsets.zero;
    return basePadding.copyWith(bottom: basePadding.bottom);
  }

  IndexedWidgetBuilder _createSeparatorBuilder() {
    if (widget.separatorBuilder == null) {
      return (_, __) => const SizedBox.shrink();
    }

    return (context, index) {
      final isLastItem = (index + 1) == (_pagingController.items?.length ?? 0);
      if (isLastItem) {
        return const SizedBox.shrink();
      }
      return widget.separatorBuilder!(context, index);
    };
  }

  PagedChildBuilderDelegate<T> _createBuilderDelegate() {
    return PagedChildBuilderDelegate<T>(
      itemBuilder: widget.itemBuilder,
      firstPageProgressIndicatorBuilder:
          widget.firstPageProgressIndicatorBuilder,
      newPageProgressIndicatorBuilder: widget.newPageProgressIndicatorBuilder,
      noItemsFoundIndicatorBuilder: _buildEmptyIndicator,
      noMoreItemsIndicatorBuilder:
          widget.noMoreItemsIndicatorBuilder ?? (_) => const SizedBox.shrink(),
      firstPageErrorIndicatorBuilder: _buildErrorIndicator,
      newPageErrorIndicatorBuilder: _buildNewPageErrorIndicator,
    );
  }

  Widget _buildEmptyIndicator(BuildContext context) {
    if (widget.noItemsFoundIndicatorBuilder != null) {
      return widget.noItemsFoundIndicatorBuilder!(context);
    }
    return context.pagingConfigData.emptyBuilder(context);
  }

  Widget _buildErrorIndicator(BuildContext context) {
    if (widget.firstPageErrorIndicatorBuilder != null) {
      return widget.firstPageErrorIndicatorBuilder!(context);
    }
    return context.pagingConfigData.errorBuilder(context, null);
  }

  Widget _buildNewPageErrorIndicator(BuildContext context) {
    if (widget.newPageErrorIndicatorBuilder != null) {
      return widget.newPageErrorIndicatorBuilder!(context);
    }
    return context.pagingConfigData.errorBuilder(context, null);
  }
}

extension IterableX<T> on Iterable<T>? {
  T? getOrNull(int index) {
    final self = this;
    if (self == null || index < 0 || index >= self.length) {
      return null;
    }
    return self.elementAt(index);
  }
}

extension ObjectExtension on dynamic {
  bool isEmptyOrNoData() {
    final self = this;
    if (self == null) return true;

    return switch (self) {
      String s => s.trim().isEmpty,
      List l => l.isEmpty,
      Map m => m.isEmpty,
      Iterable i => i.isEmpty,
      double d => d == 0,
      int i => i == 0,
      _ => false,
    };
  }
}
