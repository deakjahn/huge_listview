import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huge_listview/src/arrows_thumb.dart';

class DraggableScrollbar extends StatefulWidget {
  final Widget child;
  final double heightScrollThumb;
  final EdgeInsetsGeometry padding;
  final int totalCount;
  final int initialScrollIndex;
  final ValueChanged<double> onChange;

  DraggableScrollbar({
    Key key,
    @required this.child,
    this.heightScrollThumb = 48.0,
    this.padding,
    this.totalCount = 1,
    this.initialScrollIndex = 0,
    this.onChange,
  })  : assert(child != null),
        super(key: key);

  @override
  DraggableScrollbarState createState() => DraggableScrollbarState();
}

class DraggableScrollbarState extends State<DraggableScrollbar> with TickerProviderStateMixin {
  double thumbOffset = 0.0;
  bool isDragging = false;

  double get thumbMin => 0.0;

  double get thumbMax => context.size.height - widget.heightScrollThumb;

  @override
  void initState() {
    super.initState();

    if (widget.initialScrollIndex > 0 && widget.totalCount > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => thumbOffset = (widget.initialScrollIndex / widget.totalCount) * (thumbMax - thumbMin));
      });
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          RepaintBoundary(child: widget.child),
          RepaintBoundary(child: buildDetector()),
        ],
      );

  Widget buildKeyboard() {
    if (defaultTargetPlatform == TargetPlatform.windows)
      return RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: keyHandler,
        child: buildDetector(),
      );
    else
      return buildDetector();
  }

  Widget buildDetector() => GestureDetector(
        onVerticalDragStart: onDragStart,
        onVerticalDragUpdate: onDragUpdate,
        onVerticalDragEnd: onDragEnd,
        child: Container(
          alignment: Alignment.topRight,
          margin: EdgeInsets.only(top: thumbOffset),
          padding: widget.padding,
          child: buildThumb(
            width: widget.heightScrollThumb * 0.6,
            height: widget.heightScrollThumb,
          ),
        ),
      );

  void setPosition(double position) {
    setState(() {
      thumbOffset = position * (thumbMax - thumbMin);
    });
  }

  Widget buildThumb({double width, double height}) => CustomPaint(
        foregroundPainter: ArrowCustomPainter(context),
        child: Material(
          elevation: 4.0,
          child: Container(constraints: BoxConstraints.tight(Size(width, height))),
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(height),
            bottomLeft: Radius.circular(height),
            topRight: Radius.circular(4.0),
            bottomRight: Radius.circular(4.0),
          ),
        ),
      );

  void onDragStart(DragStartDetails details) {
    setState(() => isDragging = true);
  }

  void onDragUpdate(DragUpdateDetails details) {
    setState(() {
      if (isDragging && details.delta.dy != 0) {
        thumbOffset += details.delta.dy;
        thumbOffset = thumbOffset.clamp(thumbMin, thumbMax);
        double position = thumbOffset / (thumbMax - thumbMin);
        widget.onChange?.call(position);
      }
    });
  }

  void onDragEnd(DragEndDetails details) {
    setState(() => isDragging = false);
  }

  void keyHandler(RawKeyEvent value) {
    if (value.runtimeType == RawKeyDownEvent) {
      if (value.logicalKey == LogicalKeyboardKey.arrowDown)
        onDragUpdate(DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: Offset(0, 2),
        ));
      else if (value.logicalKey == LogicalKeyboardKey.arrowUp)
        onDragUpdate(DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: Offset(0, -2),
        ));
      else if (value.logicalKey == LogicalKeyboardKey.pageDown)
        onDragUpdate(DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: Offset(0, 25),
        ));
      else if (value.logicalKey == LogicalKeyboardKey.pageUp)
        onDragUpdate(DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: Offset(0, -25),
        ));
    }
  }
}
