import 'dart:async';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

typedef AppFetchPageCallback<PageKeyType, ItemType> = FutureOr<List<ItemType>>
    Function(PageKeyType pageKey, int pageSize);

class AppPagingController<PageKeyType, ItemType>
    extends PagingController<PageKeyType, ItemType> {
  AppPagingController({
    required this.pageSize,
    required super.getNextPageKey,
    required this.appFetchPageCallback,
  }) : super(
          fetchPage: (pageKey) async {
            final newItems = await appFetchPageCallback(
              pageKey,
              pageSize,
            );
            return newItems;
          },
        );

  final int pageSize;
  final AppFetchPageCallback<PageKeyType, ItemType> appFetchPageCallback;

  Future<void> refreshSilent() async {
    final currentItems = value.items;
    if (currentItems == null || currentItems.isEmpty) {
      refresh();
      fetchNextPage();
      return;
    }

    try {
      final nearestPageSize =
          ((currentItems.length / pageSize).ceil() * pageSize);
      final newItems = await this.appFetchPageCallback(
        (value.keys?.firstOrNull) as PageKeyType,
        nearestPageSize,
      );
      // add all new items to old pages
      final newPages = List.generate(
        value.pages?.length ?? 0,
        (index) {
          try {
            return newItems.sublist(
              index * pageSize,
              (index + 1) * pageSize,
            );
          } catch (e) {
            return newItems.sublist(
              index * pageSize,
              newItems.length,
            );
          }
        },
      );

      value = PagingState(
        error: null,
        pages: newPages,
        hasNextPage: newPages.lastOrNull?.length == pageSize,
        isLoading: false,
        keys: value.keys,
      );
      notifyListeners();
      fetchNextPage();
    } catch (error) {
      refresh();
    }
  }
}
