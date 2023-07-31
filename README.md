Huge ListView
=============

A performant `ListView` that can handle any number of items with ease. Unlike other infinite list approaches,
it doesn't just add new items to the list, growing to huge sizes in the end, but has a fixed size cache that
only keeps a handful of pages (in other words, a few hundred items at most) all the time, discarding old pages
as new ones come in. The list asks for a pageful of items at once, in an async function, expecting to receive
a `Future<List<T>>` of your items.

This approach means that the actual number of items in the list makes no difference. Hundreds of thousands or
even millions of items are all the same. You never have to read and keep all of them in memory at the same time.

Instead of a regular `ListView`, it uses a `ScrollablePositionedList` inside that makes it possible to scroll
to specific items rather than scroll positions. The items don't have to be of uniform height, their size differences
don't affect performance at all. This list implementation, however, doesn't play nice with the regular `Scrollbar`,
so we use our own `DraggableScrollbar` instead. This way we can support both a scrollbar and the usual position-based
scrolling as well.

The basic idea came from:

* https://stackoverflow.com/questions/60074466/pagination-infinite-scrolling-in-flutter-with-caching-and-realtime-invalidatio

The scrollbar is based on:

* https://pub.dev/packages/draggable_scrollbar

## Usage

```dart
static const int PAGE_SIZE = 12;
final listKey = GlobalKey<HugeListViewState>();
final scroll = ItemScrollController();
final controller = HugeListViewController(totalItemCount: 999999);

HugeListView<MyDataItem>(
  /// Only needed if you expect to make use of its [setPosition] function.
  key: listKey,
  /// Only needed if you expect to make use of its [jumpTo] or [scrollTo] functions (the thumb expects it, though).
  scrollController: scroll,
  /// Only needed if you expect to provide the total count of items.
  listViewController: controller,
  /// Size of the page. [HugeListView] only keeps a few pages of items in memory any time.
  pageSize: PAGE_SIZE,
  /// Index of an item to initially align within the viewport.
  startIndex: 0,
  /// Called to load items for the list with the specified [pageIndex].
  pageFuture: (page) => _loadPage(page, PAGE_SIZE),
  /// Called to build an individual item with the specified [index].
  itemBuilder: (context, index, MyDataItem entry) {
    return Text(entry.name);
  },
  /// Called to build the thumb. One of [DraggableScrollbarThumbs.RoundedRectThumb], [DraggableScrollbarThumbs.ArrowThumb],
  /// [DraggableScrollbarThumbs.SemicircleThumb] or build your own.
  thumbBuilder: DraggableScrollbarThumbs.SemicircleThumb,
  /// Background color of scroll thumb, defaults to white.
  thumbBackgroundColor: Colors.white,
  /// Drawing color of scroll thumb, defaults to gray.
  thumbDrawColor: Colors.grey,
  /// Height of scroll thumb, defaults to 48.
  thumbHeight: 48,
  /// Called to build a placeholder while the item is not yet availabe.
  placeholderBuilder: (context, index) => <some Widget>,
  /// Called to build a progress widget while the whole list is initialized.
  waitBuilder: (context) => <some Widget>,
  /// Called to build a widget when the list is empty.
  emptyBuilder: (context) => <some Widget>,
  /// Called to build a widget when there is an error.
  errorBuilder: (context, error) => <some Widget>,
  /// Event to call with the index of the topmost visible item in the viewport while scrolling.
  /// Can be used eg. to display the current letter of an alphabetically sorted list.
  firstShown: (index) {},
  /// The axis along which the list view scrolls. Defaults to [Axis.vertical].
  scrollDirection: Axis.vertical,
  /// The amount of space by which to inset the list.
  padding: EdgeInsets.all(6.0),
  /// Whether the scroll thumb slides out when not used, defaults to always visible.
  alwaysVisibleThumb: false,
  /// How quickly the scroll thumb animates in and out. Ignored if `alwaysVisibleThumb` is true.
  /// Defaults to kThemeAnimationDuration.
  thumbAnimationDuration = const Duration(milliseconds: 300),
  /// How long the scroll thumb stays visible before disappearing. Ignored if `alwaysVisibleThumb` is true.
  /// Defaults to 1 second.
  thumbVisibleDuration = const Duration(milliseconds: 600),
  /// Optional external LruMap to be used for cache.
  final LruMap<int, HugeListViewPageResult<T>>? lruMap;
);
```

You have to pass a list of your items to `pageFuture`, for instance, given a list named `data`:

``` dart
Future<List<MyDataItem>> _loadPage(int page, int pageSize) async {
  int from = page * pageSize;
  int to = min(data.length, from + pageSize);
  return data.sublist(from, to);
}
```

The `waitBuilder` can be a simple centered `CircularProgressIndicator` but a nicer idea is
to provide a `placeholderBuilder` that is a mockup of the data to arrive. Many apps and sites
use gray horizontal bars instead of the actual text during loading. As an example,
here is a simple function that creates such a bar with randomly varying length:

``` dart
static const int PLACEHOLDER_SIZE = 14;

Widget buildPlaceholder() {
  double margin = Random().nextDouble() * 50;
  return Padding(
    padding: EdgeInsets.fromLTRB(3, 3, 3 + margin, 3),
    child: Container(
      height: PLACEHOLDER_SIZE,
      color: Colors.grey,
    ),
  );
}
```

You can pass it directly to `placeholderBuilder` and you can also use it to create
a whole page of text mockup bars that you can pass to `waitBuilder`:

``` dart
Widget buildWait() {
  return LayoutBuilder(
    builder: (_, constraints) {
      return ListView.builder(
        itemCount: (constraints.maxHeight / PLACEHOLDER_SIZE).ceil(),
        itemBuilder: (_, index) => buildPlaceholder(),
      );
    },
  );
}
```

## Custom thumb

In order to use a custom thumb, provide a builder:

``` dart
thumbBuilder: (Color backgroundColor, Color drawColor, double height, int index, bool alwaysVisibleScrollThumb, Animation<double> thumbAnimation) {
  return ScrollBarThumb(backgroundColor, drawColor, height, index.toString(), alwaysVisibleScrollThumb, thumbAnimation);
}
```

where `ScrollBarThumb` can be:

```dart
class ScrollBarThumb extends StatelessWidget {
  final Color backgroundColor;
  final Color drawColor;
  final double height;
  final String title;
  final bool alwaysVisibleScrollThumb;
  final Animation<double> thumbAnimation;

  const ScrollBarThumb(
    this.backgroundColor,
    this.drawColor,
    this.height,
    this.title,
    this.alwaysVisibleScrollThumb,
    this.thumbAnimation, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final thumb = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white.withOpacity(0.8),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.black,
              backgroundColor: Colors.transparent,
              fontSize: 14,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(2),
        ),
        CustomPaint(
          foregroundPainter: _ArrowCustomPainter(drawColor),
          child: Material(
            elevation: 4.0,
            child: Container(constraints: BoxConstraints.tight(Size(height * 0.6, height))),
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(height),
              bottomLeft: Radius.circular(height),
              topRight: Radius.circular(4.0),
              bottomRight: Radius.circular(4.0),
            ),
          ),
        ),
      ],
    );
    return alwaysVisibleScrollThumb ? thumb : SlideFadeTransition(animation: thumbAnimation, child: thumb);
  }
}

class _ArrowCustomPainter extends CustomPainter {
  final Color drawColor;

  _ArrowCustomPainter(this.drawColor);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = drawColor;
    const width = 12.0;
    const height = 8.0;
    final baseX = size.width / 2;
    final baseY = size.height / 2;

    canvas.drawPath(trianglePath(Offset(baseX - 4.0, baseY - 2.0), width, height, true), paint);
    canvas.drawPath(trianglePath(Offset(baseX - 4.0, baseY + 2.0), width, height, false), paint);
  }

  static Path trianglePath(Offset offset, double width, double height, bool isUp) {
    return Path()
      ..moveTo(offset.dx, offset.dy)
      ..lineTo(offset.dx + width, offset.dy)
      ..lineTo(offset.dx + (width / 2),
          isUp ? offset.dy - height : offset.dy + height)
      ..close();
  }
}
```