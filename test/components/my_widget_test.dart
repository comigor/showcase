import 'package:flutter/material.dart';
import 'package:showcase/components/my_widget.dart';
import '../helpers/showcase.dart';

void main() {
  final widgetList = [
    MyWidget(),
    MyWidget(anotherBuild: true),
    MyWidget(sliderValue: 5.0),
  ];

  // showcaseWidgets(widgetList);
  showcaseWidgets(widgetList, customContainerBuilder: (child) => Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.amberAccent,
        border: Border.all(
          color: Colors.amber,
          width: 2.0,
        ),
      ),
      width: 800.0,
      height: 240.0,
      child: child,
    ),
  );
}
