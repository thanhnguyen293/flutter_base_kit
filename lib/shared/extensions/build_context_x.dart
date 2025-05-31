import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  /// Get width of screen
  double get width => MediaQuery.of(this).size.width;

  /// Get height of screen
  double get height => MediaQuery.of(this).size.height;

  /// Show a snackBar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(SnackBar(content: Text(message), duration: duration));
  }
}

extension NavigatorX on BuildContext {
  /// Push a page with MaterialPageRoute
  Future<T?> push<T>(Widget page) {
    return Navigator.push<T>(this, MaterialPageRoute(builder: (_) => page));
  }

  /// Push and replace current page
  Future<T?> pushReplacement<T, TO>(Widget page) {
    return Navigator.pushReplacement<T, TO>(
      this,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Push named route
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(this, routeName, arguments: arguments);
  }

  // Push named route and remove until nothing left
  Future<T?> pushNamedAndRemoveUntil<T>(String routeName, {Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      this,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  ///Pop current route
  void pop<T extends Object?>([T? result]) {
    Navigator.pop(this, result);
  }
}
