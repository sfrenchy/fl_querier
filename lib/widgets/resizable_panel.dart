import 'package:flutter/material.dart';

class ResizablePanel extends StatefulWidget {
  final Widget child;
  final double initialWidth;
  final double minWidth;
  final double maxWidth;

  const ResizablePanel({
    super.key,
    required this.child,
    this.initialWidth = 250,
    this.minWidth = 200,
    this.maxWidth = 400,
  });

  @override
  State<ResizablePanel> createState() => _ResizablePanelState();
}

class _ResizablePanelState extends State<ResizablePanel> {
  late double width;

  @override
  void initState() {
    super.initState();
    width = widget.initialWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: width,
          child: widget.child,
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  width = (width + details.delta.dx)
                      .clamp(widget.minWidth, widget.maxWidth);
                });
              },
              child: Container(
                width: 8,
                color: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
