import 'package:flutter/material.dart';
import 'package:flutter_base_kit/shared/extensions/build_context_x.dart';
import 'package:flutter_base_kit/shared/widgets/app_paging_list/app_paging_controller.dart';
import 'package:flutter_base_kit/shared/widgets/read_more_text.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'shared/widgets/app_paging_list/app_paging_list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body:  AppPagingList(
        // pagingController: AppPagingController<int, String>(
        //   pageSize: 20,
        //   getNextPageKey: (PagingState<int, dynamic> state) {
        //     if ((state.items?.length ?? 0) == 0) {
        //       return null;
        //     }
        //     return state.items!.length;
        //   },
        //   appFetchPageCallback: (int pageKey, int pageSize) {
        //     return Future.delayed(
        //       const Duration(seconds: 1),
        //           () => List.generate(
        //         pageSize,
        //             (index) => 'Item ${pageKey + index + 1}',
        //       ),
        //     );
        //   },
        // ),
        pageSize: 10,
        fetchListData: (int offset, int limit) {
          return Future.delayed(
            const Duration(seconds: 1),
                () => List.generate(
              limit,
                  (index) => 'Item ${offset + index + 1}',
            ),
          );
        },
        itemBuilder: (BuildContext context, String item, int index) {
          return ListTile(
            title: Text(item),
          );
        },

      ),
      // body: SingleChildScrollView(
      //   padding: const EdgeInsets.all(16.0),
      //   child: SafeArea(
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       crossAxisAlignment: CrossAxisAlignment.stretch,
      //       children: <Widget>[
      //         FilledButton(
      //           onPressed: () => context.pushNamed('/second'),
      //           child: const Text('Click me'),
      //         ),
      //         const Text('You have pushed the button this many times:'),
      //         Text(
      //           '$_counter',
      //           style: Theme.of(context).textTheme.headlineMedium,
      //         ),
      //         AppPagingList(
      //           pagingController: AppPagingController(
      //             pageSize: 20,
      //             getNextPageKey: (PagingState<int, dynamic> state) {},
      //             appFetchPageCallback: (int pageKey, int pageSize) {
      //               return Future.delayed(
      //                 const Duration(seconds: 1),
      //                 () => List.generate(
      //                   pageSize,
      //                   (index) => 'Item ${pageKey + index + 1}',
      //                 ),
      //               );
      //             },
      //           ),
      //
      //           itemBuilder: (BuildContext context, item, int index) {
      //             return ListTile(
      //               title: Text(item),
      //             );
      //           },
      //           fetchListData: (int offset, int limit) {
      //             return Future.delayed(
      //               const Duration(seconds: 1),
      //               () => List.generate(
      //                 limit,
      //                 (index) => 'Item ${offset + index + 1}',
      //               ),
      //             );
      //           },
      //         ),
      //         AppReadMoreText(
      //           text: longText,
      //           maxLines: 3,
      //           readMoreText: 'Read more',
      //           readLessText: 'Read less',
      //           readMoreStyle: const TextStyle(color: Colors.blue),
      //           readLessStyle: const TextStyle(color: Colors.blue),
      //           linkStyle: const TextStyle(
      //             color: Colors.blue,
      //             decoration: TextDecoration.underline,
      //           ),
      //           parseTypes: [ParseType.url, ParseType.email],
      //           onTap: (String text, ParseType type) {
      //             debugPrint('onTap: $text, type: $type');
      //           },
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

final longText = '''
Đây là đoạn test tổng hợp các loại đường dẫn:
- Trang web chuẩn: https://www.google.com
- Trang không có www: https://flutter.dev
- Trang không có https: http://example.com
- Link có port: http://localhost:3000/dashboard
- Link có query params: https://myapp.com/search?q=flutter&page=2
- Link có anchor: https://en.wikipedia.org/wiki/Flutter_(software)#History
- Link có subdomain: https://docs.flutter.dev
- Link IP: http://192.168.0.1/settings
- Link có path phức tạp: https://github.com/flutter/flutter/tree/main/packages/flutter
- Link có ký tự đặc biệt: https://example.com/file?name=abc%20def&sort=asc
- Link rút gọn: https://bit.ly/3xYzABC
- YouTube: https://www.youtube.com/watch?v=RQGlEaalWAs
- Link không hợp lệ nhưng vẫn hay gặp: www.example.com (không có http)
- Email: contact@flutter.dev
- Twitter: twitter.com
- Số điện thoại: +84901234567
- Số điện thoại có dấu cách: +84 90 123 4567
- Số điện thoại có dấu gạch ngang: +84-90-123-4567
- Số điện thoại có dấu ngoặc: +84 (90) 123 4567
Còn đây là một đoạn lorem để nối text và tăng độ dài nhằm test line-break:
Flutter là một SDK mã nguồn mở giúp xây dựng UI đẹp mắt cho nhiều nền tảng từ một codebase duy nhất. Với sự hỗ trợ của Dart, Flutter cho phép hot reload, hiệu suất cao, và khả năng tùy biến UI linh hoạt.
Đây là một đoạn test thật sự rất dài để đảm bảo widget `UrlReadMoreText` của đại ca hoạt động đúng, giữ link không bị cắt giữa chừng, vẫn tap được và hiển thị Read more đúng dòng thứ 3.
Hết!
''';
