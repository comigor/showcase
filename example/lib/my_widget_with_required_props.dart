import 'package:flutter/material.dart';
import 'package:showcase/showcase.dart';

@Showcased(width: 480.0, height: 48.0)
class MyWidgetWithRequiredProps extends StatelessWidget {
  MyWidgetWithRequiredProps(this.label);

  factory MyWidgetWithRequiredProps.forDesignTime() =>
      MyWidgetWithRequiredProps('Default test-only label.');

  final String label;

  @override
  Widget build(BuildContext context) => Text(label);
}
