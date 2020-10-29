Huge ListView
=============

A performant `ListView` that can handle any number of items with ease.

The basic idea came from:

* https://stackoverflow.com/questions/60074466/pagination-infinite-scrolling-in-flutter-with-caching-and-realtime-invalidatio

The scrollbar is based on:

* https://pub.dev/packages/draggable_scrollbar

## Usage

``` dart
static const int PAGE_SIZE = 12;

// Only needed if you expect to make use of its `setPosition` function.
final listKey = GlobalKey<HugeListViewState>();

// Only needed if you expect to make use of its `jumpTo` or `scrollTo` functions.
final scroll = ItemScrollController();

HugeListView<MyDataItem>(
  key: listKey,
  controller: scroll,
  pageSize: PAGE_SIZE,
  totalCount: 999999,
  startIndex: 0,
  pageFuture: (page) => _loadPage(page, PAGE_SIZE),
  itemBuilder: (context, index, entry) {
    return Text(entry.name);
  },
  placeholderBuilder: (context, index) => <some Widget>,
  waitBuilder: (context) => <some Widget>,
  firstShown: (index) {},
);
```

You have to pass a list of your items to `pageFuture`, for instance, given a list named `data`:

``` dart
Future<List<XmlItem>> _loadPage(int page, int pageSize) async {
  final result = <MyDataItem>[];
  int from = page * pageSize;
  int to = min(data.length, from + pageSize);
  for (int i = from; i < to; i++) {
    result.add(data.elementAt(i));
  }
  return result;
}
```
