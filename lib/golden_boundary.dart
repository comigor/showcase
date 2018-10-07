import 'package:flutter/material.dart';

typedef ContainerBuilder = Container Function(Widget child);

class GoldenBoundary extends StatelessWidget {
  final Widget child;
  final GlobalKey globalKey;
  final ContainerBuilder customContainerBuilder;


  GoldenBoundary({
    @required this.child,
    this.globalKey,
    this.customContainerBuilder,
  });

  Widget _defaultContainerBuilder(Widget child) {
    return Container(
      padding: EdgeInsets.all(10.0),
      width: 640.0,
      height: 480.0,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: RepaintBoundary(
          key: globalKey,
          child: customContainerBuilder != null ?
              customContainerBuilder(child) :
              _defaultContainerBuilder(child),
        ),
      ),
    );
  }
}
