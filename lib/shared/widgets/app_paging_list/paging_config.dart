import 'package:flutter/material.dart';
import 'paging_state_widget.dart';

typedef PagingErrorBuilder = Widget Function(
  BuildContext context,
  dynamic error,
);
typedef PagingEmptyBuilder = Widget Function(BuildContext context);

extension PagingConfigDataExtension on BuildContext {
  PagingConfigData get pagingConfigData => PagingConfiguration.of(this);
}

class PagingConfigData {
  PagingConfigData({
    IndexedWidgetBuilder? separatorBuilder,
    WidgetBuilder? progressIndicatorBuilder,
    PagingErrorBuilder? errorBuilder,
    PagingEmptyBuilder? emptyBuilder,
  }) {
    this.separatorBuilder = separatorBuilder ??
        (context, index) => const SizedBox(
              height: 10,
              width: 10,
            );
    // this.progressIndicatorBuilder = progressIndicatorBuilder ?? (context) => const CupertinoActivityIndicator();
    this.progressIndicatorBuilder = progressIndicatorBuilder ??
        (context) => const Center(
              child: CircularProgressIndicator(),
            );
    this.errorBuilder =
        errorBuilder ?? (context, error) => PageErrorNotify(error: error);
    this.emptyBuilder = emptyBuilder ??
        (context) => const PageEmptyNotify(
              message: 'No data found',
            );
  }

  late final IndexedWidgetBuilder separatorBuilder;
  late final WidgetBuilder progressIndicatorBuilder;
  late final PagingErrorBuilder errorBuilder;
  late final PagingEmptyBuilder emptyBuilder;
}

class PagingConfiguration extends InheritedWidget {
  const PagingConfiguration({
    required this.configData,
    required super.child,
    super.key,
  });

  final PagingConfigData configData;

  static PagingConfigData of(BuildContext context) {
    final configWidget =
        context.dependOnInheritedWidgetOfExactType<PagingConfiguration>();
    return configWidget?.configData ?? PagingConfigData();
  }

  @override
  bool updateShouldNotify(covariant PagingConfiguration oldWidget) {
    return configData != oldWidget.configData;
  }
}
