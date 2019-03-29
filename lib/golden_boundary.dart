import 'package:flutter/material.dart';

typedef ContainerBuilder = Container Function(Widget child);

/// Use [GoldenBoundary] to wrap a [Widget] and be able to find its
/// [RenderObject] from a [GlobalKey].
class GoldenBoundary extends StatelessWidget {
  /// Default constructor. Use [customContainerBuilder] if you want to customize
  /// the wrapping container.
  const GoldenBoundary({
    @required this.child,
    this.globalKey,
    this.size,
    this.customContainerBuilder,
  }) : assert(size != null || customContainerBuilder != null,
            'At least one of [size] or [customContainerBuilder] is required.');

  /// The widget to be wrapped.
  final Widget child;

  /// A custom key to find this widget later.
  final GlobalKey globalKey;

  /// A function to customize the wrapping container.
  final ContainerBuilder customContainerBuilder;

  /// The size of the wrapping container.
  final Size size;

  Widget _defaultContainerBuilder(Widget child) => Container(
        padding: const EdgeInsets.all(10.0),
        width: size != null ? size.width : 640.0,
        height: size != null ? size.height : 640.0,
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
