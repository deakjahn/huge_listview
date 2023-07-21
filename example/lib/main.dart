import 'dart:math';

import 'package:flutter/material.dart';
import 'package:huge_listview/huge_listview.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: PageView(
            controller: PageController(initialPage: 0),
            children: const [
              SimplePage(title: 'HugeListView simple demo'),
              DeletablePage(title: 'HugeListView deletable demo'),
            ],
          ),
        ),
        Container(
          color: Colors.blue.shade200,
          padding: const EdgeInsets.all(12),
          child: Text(
            'Swipe to see other pages',
            style: Theme.of(context).textTheme.bodyLarge!,
          ),
        )
      ],
    );
  }
}

class SimplePage extends StatefulWidget {
  final String title;

  const SimplePage({super.key, required this.title});

  @override
  State<SimplePage> createState() => _SimplePageState();
}

class _SimplePageState extends State<SimplePage> {
  static const int PAGE_SIZE = 24;
  final scroll = ItemScrollController();
  final controller = HugeListViewController(totalItemCount: 999999);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: HugeListView<String>(
        scrollController: scroll,
        listViewController: controller,
        pageSize: PAGE_SIZE,
        startIndex: 0,
        pageFuture: (page) => _loadPage(page, PAGE_SIZE),
        itemBuilder: (context, index, String entry) {
          return Text(entry);
        },
        thumbBuilder: DraggableScrollbarThumbs.SemicircleThumb,
        placeholderBuilder: (context, index) => buildPlaceholder(),
        alwaysVisibleThumb: false,
      ),
    );
  }

  Future<List<String>> _loadPage(int page, int pageSize) async {
    int from = page * pageSize;
    int to = min(999999, from + pageSize);
    return List.generate(to - from, (index) => 'Item #${from + index}');
  }

  Widget buildPlaceholder() {
    double margin = Random().nextDouble() * 50;
    return Padding(
      padding: EdgeInsets.fromLTRB(3, 3, 3 + margin, 3),
      child: Container(
        height: 15,
        color: Colors.grey,
      ),
    );
  }
}

class DeletablePage extends StatefulWidget {
  final String title;

  const DeletablePage({super.key, required this.title});

  @override
  State<DeletablePage> createState() => _DeletablePageState();
}

class _DeletablePageState extends State<DeletablePage> {
  static const int PAGE_SIZE = 24;
  final scroll = ItemScrollController();
  final controller = HugeListViewController(totalItemCount: 10000);
  late List<String> list;

  @override
  void initState() {
    super.initState();
    list = List.generate(controller.totalItemCount + 1,
        (index) => 'Item #$index of ${controller.totalItemCount}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: HugeListView<String>(
        scrollController: scroll,
        listViewController: controller,
        pageSize: PAGE_SIZE,
        startIndex: 0,
        pageFuture: (page) => _loadPage(page, PAGE_SIZE),
        itemBuilder: (context, index, String entry) {
          return Text(entry);
        },
        thumbBuilder: DraggableScrollbarThumbs.SemicircleThumb,
        placeholderBuilder: (context, index) => buildPlaceholder(),
        alwaysVisibleThumb: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final newCount = Random().nextInt(10000) + 10000;
          setState(() {
            list = List.generate(
                newCount + 1, (index) => 'New Item #$index of $newCount');
          });
          controller.invalidateList(true);
          controller.totalItemCount = newCount;
        },
        tooltip: 'Update list',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Future<List<String>> _loadPage(int page, int pageSize) async {
    int from = page * pageSize;
    int to = min(controller.totalItemCount, from + pageSize);
    return list.sublist(from, to);
  }

  Widget buildPlaceholder() {
    double margin = Random().nextDouble() * 50;
    return Padding(
      padding: EdgeInsets.fromLTRB(3, 3, 3 + margin, 3),
      child: Container(
        height: 15,
        color: Colors.grey,
      ),
    );
  }
}
