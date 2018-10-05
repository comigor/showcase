import 'package:flutter/material.dart';

class GoldenBoundary extends StatelessWidget {
  final Widget child;

  GoldenBoundary({@required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: RepaintBoundary(
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
