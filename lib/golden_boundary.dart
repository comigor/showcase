import 'package:flutter/material.dart';

typedef ContainerBuilder = Container Function(Widget child);

/// Use [GoldenBoundary] to wrap a [Widget] and be able to find its
/// [RenderObject] from a [GlobalKey].
class GoldenBoundary extends StatelessWidget {
  /// The widget to be wrapped.
  final Widget child;

  /// A custom key to find this widget later.
  final GlobalKey globalKey;

  /// A function to customize the wrapping container.
  final ContainerBuilder customContainerBuilder;

  /// Default constructor. Use [customContainerBuilder] if you want to customize
  /// the wrapping container.
  const GoldenBoundary({
    @required this.child,
    this.globalKey,
    this.customContainerBuilder,
  });

  Widget _defaultContainerBuilder(Widget child) => Container(
        padding: const EdgeInsets.all(10.0),
        width: 640.0,
        height: 480.0,
        child: child,
      );

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(
            key: globalKey,
            child: customContainerBuilder != null
                ? customContainerBuilder(child)
                : _defaultContainerBuilder(child),
          ),
        ),
      );
}
