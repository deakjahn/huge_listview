import 'dart:async';

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
  final bool alwaysVisibleThumb;
  final Duration thumbAnimationDuration;
  final Duration thumbVisibleDuration;
  final int totalCount;
  final int initialScrollIndex;
  final int currentFirstIndex;
  final ValueChanged<double>? onChange;
  final ScrollThumbBuilder scrollThumbBuilder;
  final Axis scrollDirection;

  const DraggableScrollbar({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.drawColor = Colors.grey,
    this.heightScrollThumb = 48.0,
    this.padding,
    this.alwaysVisibleThumb = true,
    this.thumbAnimationDuration = kThemeAnimationDuration,
    this.thumbVisibleDuration = const Duration(milliseconds: 1000),
    this.totalCount = 1,
    this.initialScrollIndex = 0,
    this.currentFirstIndex = 0,
    required this.scrollThumbBuilder,
    this.onChange,
    this.scrollDirection = Axis.vertical,
  }) : super(key: key);

  @override
  DraggableScrollbarState createState() => DraggableScrollbarState();
}

class DraggableScrollbarState extends State<DraggableScrollbar>
    with TickerProviderStateMixin {
  double thumbOffset = 0.0;
  int currentFirstIndex = 0;
  bool isDragging = false;
  late AnimationController thumbAnimationController;
  late Animation<double> thumbAnimation;
  Timer? fadeoutTimer;

  double get thumbMin => 0.0;

  double get thumbMax => widget.scrollDirection == Axis.vertical //
      ? context.size!.height - widget.heightScrollThumb
      : context.size!.width - widget.heightScrollThumb;

  @override
  void initState() {
    super.initState();

    thumbAnimationController = AnimationController(
      vsync: this,
      duration: widget.thumbAnimationDuration,
    );

    thumbAnimation = CurvedAnimation(
      parent: thumbAnimationController,
      curve: Curves.fastOutSlowIn,
    );

    currentFirstIndex = widget.currentFirstIndex;
    if (widget.initialScrollIndex > 0 && widget.totalCount > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => thumbOffset =
            (widget.initialScrollIndex / widget.totalCount) *
                (thumbMax - thumbMin));
      });
    }
  }

  @override
  void dispose() {
    thumbAnimationController.dispose();
    fadeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (!isDragging &&
              (notification is ScrollUpdateNotification ||
                  notification is OverscrollNotification)) {
            if (thumbAnimationController.status != AnimationStatus.forward)
              thumbAnimationController.forward();
            fadeoutTimer?.cancel();
            fadeoutTimer = Timer(widget.thumbVisibleDuration, () {
              thumbAnimationController.reverse();
              fadeoutTimer = null;
            });
          }
          return false;
        },
        child: Stack(
          children: [
            RepaintBoundary(child: widget.child),
            RepaintBoundary(child: buildDetector()),
          ],
        ),
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
          alignment: widget.scrollDirection == Axis.vertical //
              ? Alignment.topRight
              : Alignment.bottomLeft,
          margin: widget.scrollDirection == Axis.vertical //
              ? EdgeInsets.only(top: thumbOffset)
              : EdgeInsets.only(left: thumbOffset),
          padding: widget.padding,
          child: widget.scrollThumbBuilder.call(
            widget.backgroundColor,
            widget.drawColor,
            widget.heightScrollThumb,
            currentFirstIndex,
            widget.alwaysVisibleThumb,
            thumbAnimation,
          ),
        ),
      );

  void setPosition(double position, int currentFirstIndex) {
    setState(() {
      this.currentFirstIndex = currentFirstIndex;
      thumbOffset = position * (thumbMax - thumbMin);
    });
  }

  void onDragStart(DragStartDetails details) {
    setState(() {
      isDragging = true;
      fadeoutTimer?.cancel();
    });
  }

  void onDragUpdate(DragUpdateDetails details) {
    setState(() {
      if (thumbAnimationController.status != AnimationStatus.forward)
        thumbAnimationController.forward();
      if (isDragging &&
          details.delta.dy != 0 &&
          widget.scrollDirection == Axis.vertical) {
        thumbOffset += details.delta.dy;
        thumbOffset = thumbOffset.clamp(thumbMin, thumbMax);
        double position = thumbOffset / (thumbMax - thumbMin);
        widget.onChange?.call(position);
      } else if (isDragging &&
          details.delta.dx != 0 &&
          widget.scrollDirection == Axis.horizontal) {
        thumbOffset += details.delta.dx;
        thumbOffset = thumbOffset.clamp(thumbMin, thumbMax);
        double position = thumbOffset / (thumbMax - thumbMin);
        widget.onChange?.call(position);
      }
    });
  }

  void onDragEnd(DragEndDetails details) {
    fadeoutTimer = Timer(widget.thumbVisibleDuration, () {
      thumbAnimationController.reverse();
      fadeoutTimer = null;
    });
    setState(() => isDragging = false);
  }

  void keyHandler(RawKeyEvent value) {
    if (value.runtimeType == RawKeyDownEvent) {
      if (widget.scrollDirection == Axis.vertical &&
          value.logicalKey == LogicalKeyboardKey.arrowDown)
        onDragUpdate(DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: const Offset(0, 2),
        ));
      else if (widget.scrollDirection == Axis.vertical &&
          value.logicalKey == LogicalKeyboardKey.arrowUp)
        onDragUpdate(DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: const Offset(0, -2),
        ));
      else if (widget.scrollDirection == Axis.horizontal &&
          value.logicalKey == LogicalKeyboardKey.arrowRight)
        onDragUpdate(DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: const Offset(2, 0),
        ));
      else if (widget.scrollDirection == Axis.horizontal &&
          value.logicalKey == LogicalKeyboardKey.arrowLeft)
        onDragUpdate(DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: const Offset(-2, 0),
        ));
      else if (value.logicalKey == LogicalKeyboardKey.pageDown)
        onDragUpdate(DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: widget.scrollDirection == Axis.horizontal
              ? const Offset(25, 0)
              : const Offset(0, 25),
        ));
      else if (value.logicalKey == LogicalKeyboardKey.pageUp)
        onDragUpdate(DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: widget.scrollDirection == Axis.horizontal
              ? const Offset(-25, 0)
              : const Offset(0, -25),
        ));
    }
  }
}
