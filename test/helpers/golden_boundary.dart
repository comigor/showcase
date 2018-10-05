import 'package:flutter/material.dart';

class GoldenBoundary extends StatelessWidget {
  final Widget child;
  GlobalKey globalKey;

  GoldenBoundary({@required this.child, this.globalKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: RepaintBoundary(
          key: globalKey,
          child: Container(
            padding: EdgeInsets.all(10.0),
            width: 640.0,
            height: 480.0,
            child: child,
          ),
        ),
      ),
    );
  }
}
