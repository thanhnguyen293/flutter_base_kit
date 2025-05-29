import 'package:flutter/material.dart';

class PageErrorNotify extends StatelessWidget {
  const PageErrorNotify({super.key, this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Failed to load content, please pull down to try again!'),
      ),
    );
  }
}

class PageEmptyNotify extends StatelessWidget {
  const PageEmptyNotify({super.key, required this.message, this.icon});

  final Widget? icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          icon ?? const SizedBox.shrink(),
          SizedBox(height: 20),
          Text(
            message,
          ),
        ],
      ),
    );
  }
}

class ContentNotFound extends StatelessWidget {
  const ContentNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Content not found'),
      ),
    );
  }
}
