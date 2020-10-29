import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class ArrowCustomPainter extends CustomPainter {
  final BuildContext context;

  ArrowCustomPainter(this.context);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Theme.of(context).hintColor;
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
      ..lineTo(offset.dx + (width / 2), isUp ? offset.dy - height : offset.dy + height)
      ..close();
  }
}

class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double arrowWidth = 8.0;
    double startPointX = (size.width - arrowWidth) / 2;
    double startPointY1 = size.height / 2 - arrowWidth / 2;
    double startPointY2 = size.height / 2 + arrowWidth / 2;

    return Path()
      ..lineTo(0.0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0.0)
      ..lineTo(0.0, 0.0)
      ..close()
      ..moveTo(startPointX, startPointY1)
      ..lineTo(startPointX + arrowWidth / 2, startPointY1 - arrowWidth / 2)
      ..lineTo(startPointX + arrowWidth, startPointY1)
      ..lineTo(startPointX + arrowWidth, startPointY1 + 1.0)
      ..lineTo(startPointX + arrowWidth / 2, startPointY1 - arrowWidth / 2 + 1.0)
      ..lineTo(startPointX, startPointY1 + 1.0)
      ..close()
      ..moveTo(startPointX + arrowWidth, startPointY2)
      ..lineTo(startPointX + arrowWidth / 2, startPointY2 + arrowWidth / 2)
      ..lineTo(startPointX, startPointY2)
      ..lineTo(startPointX, startPointY2 - 1.0)
      ..lineTo(startPointX + arrowWidth / 2, startPointY2 + arrowWidth / 2 - 1.0)
      ..lineTo(startPointX + arrowWidth, startPointY2 - 1.0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
