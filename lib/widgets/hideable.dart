import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Hideable extends StatefulWidget {
  final Duration duration;
  final Curve curve;
  final AlignmentGeometry stackAlign;
  final CrossAxisAlignment crossAxisAlignment;
  final Axis axis;
  final double iconSize;
  final Widget child;

  Hideable({Key key,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
    this.stackAlign,
    this.axis = Axis.vertical,
    this.iconSize,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    @required this.child}) :
      super(key: key);

  @override
  _HideableState createState() => new _HideableState();
}

class _HideableState extends State<Hideable> with SingleTickerProviderStateMixin {
  AnimationController controller;
  CurvedAnimation animation;
  IconData icon;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(vsync: this, duration: widget.duration, value: 1.0);
    animation = new CurvedAnimation(parent: controller, curve: widget.curve);
    icon = widget.axis == Axis.vertical ? Icons.arrow_drop_up : Icons.arrow_left;
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<Null> toggle() async {
    if (controller.isDismissed) {
      await controller.forward();
      setState(() { icon = widget.axis == Axis.vertical ? Icons.arrow_drop_up : Icons.arrow_left; });
      }
    else {
      await controller.reverse();
      setState(() { icon = widget.axis == Axis.vertical ? Icons.arrow_drop_down : Icons.arrow_right; });
    }
  }

  @override Widget build(BuildContext context) {
    List<Widget> widgets = [
      new SizeTransition(sizeFactor: animation, axis: widget.axis, child: widget.child),
      new GestureDetector(child: new Icon(icon, size: widget.iconSize), onTap: toggle),
    ];

    return widget.stackAlign == null ? (
      widget.axis == Axis.vertical ?
      new Column(key: widget.key, crossAxisAlignment: widget.crossAxisAlignment, children: widgets) :
      new Row(key: widget.key, crossAxisAlignment: widget.crossAxisAlignment, children: widgets)
    ) : new Stack(key: widget.key, alignment: widget.stackAlign, children: widgets);

  }
}