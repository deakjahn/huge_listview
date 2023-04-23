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
      home: const MyHomePage(title: 'Huge ListView Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const int PAGE_SIZE = 24;
  final scroll = ItemScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: HugeListView<String>(
        controller: scroll,
        pageSize: PAGE_SIZE,
        totalCount: 999999,
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
