import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

extension PagingStateExtension<ItemType> on PagingController<int, ItemType> {
  void addNewItem(ItemType item) {
    final List<ItemType> newPage = [item];
    final firstKey = value.keys?.firstOrNull ?? -1;
    value = PagingState(
      error: value.error,
      pages: [newPage, ...(value.pages ?? [])],
      hasNextPage: value.hasNextPage,
      isLoading: value.isLoading,
      keys: [firstKey, ...(value.keys ?? [])],
    );
  }
}
