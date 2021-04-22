import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:huge_listview/src/draggable_scrollbar_thumbs.dart';

class DraggableScrollbar extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final Color drawColor;
  final double heightScrollThumb;
  final EdgeInsetsGeometry? padding;
  final int totalCount;
  final int initialScrollIndex;
  final int currentFirstIndex;
  final ValueChanged<double>? onChange;
  final ScrollThumbBuilder scrollThumbBuilder;
  final Axis scrollDirection;

  DraggableScrollbar({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.drawColor = Colors.grey,
    this.heightScrollThumb = 48.0,
    this.padding,
    this.totalCount = 1,
    this.initialScrollIndex = 0,
    this.currentFirstIndex = 0,
    required this.scrollThumbBuilder,
    this.onChange,
    required this.scrollDirection
  }) : super(key: key);

  @override
  DraggableScrollbarState createState() => DraggableScrollbarState();
}

class DraggableScrollbarState extends State<DraggableScrollbar> with TickerProviderStateMixin {
  double thumbOffset = 0.0;
  int currentFirstIndex = 0;
  bool isDragging = false;

  double get thumbMin => 0.0;

  double get thumbMax => widget.scrollDirection == Axis.vertical ?
  context.size!.height - widget.heightScrollThumb:
  context.size!.width - widget.heightScrollThumb;

  @override
  void initState() {
    super.initState();

    currentFirstIndex = widget.currentFirstIndex;
    if (widget.initialScrollIndex > 0 && widget.totalCount > 1) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
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
        onHorizontalDragStart: onDragStart,
        onHorizontalDragUpdate: onDragUpdate,
        onHorizontalDragEnd: onDragEnd,
        child: Container(
          alignment: widget.scrollDirection == Axis.vertical ?
          Alignment.topRight:
          Alignment.bottomLeft,
          margin: widget.scrollDirection == Axis.vertical ?
          EdgeInsets.only(top: thumbOffset):
          EdgeInsets.only(left: thumbOffset),
          padding: widget.padding,
          child: widget.scrollThumbBuilder.call(widget.backgroundColor, widget.drawColor, widget.heightScrollThumb, currentFirstIndex),
        ),
      );

  void setPosition(double position, int currentFirstIndex) {
    setState(() {
      this.currentFirstIndex = currentFirstIndex;
      thumbOffset = position * (thumbMax - thumbMin);
    });
  }

  void onDragStart(DragStartDetails details) {
    setState(() => isDragging = true);
  }

  void onDragUpdate(DragUpdateDetails details) {
    setState(() {
      if (isDragging && details.delta.dy != 0 && widget.scrollDirection == Axis.vertical) {
         thumbOffset += details.delta.dy;
        thumbOffset = thumbOffset.clamp(thumbMin, thumbMax);
        double position = thumbOffset / (thumbMax - thumbMin);
        widget.onChange?.call(position);
      }
      else if (isDragging && details.delta.dx != 0 && widget.scrollDirection == Axis.horizontal) {
        thumbOffset += details.delta.dx;
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
      else if (value.logicalKey == LogicalKeyboardKey.arrowRight)
        onDragUpdate(DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: Offset(2, 0),
        ));
      else if (value.logicalKey == LogicalKeyboardKey.arrowLeft)
        onDragUpdate(DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: Offset(-2, 0),
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
