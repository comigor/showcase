import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as path;

import 'package:showcase/components/my_widget.dart';
import '../helpers/golden_boundary.dart';

Future<Uint8List> capturePng(WidgetTester tester, GlobalKey key) async {
  RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
  ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData.buffer.asUint8List();
}

Future<void> writeToFile(String pathName, Uint8List u) async {
  final Directory goldenDir = Directory(path.dirname(pathName));
  if (!goldenDir.existsSync()) {
    goldenDir.createSync(recursive: true);
  }
  final File output = File(pathName);

  await output.writeAsBytes(u);
}

void makeTest(Widget widget, int index) async {
  testWidgets('MyWidget golden $index', (WidgetTester tester) async {
    // https://github.com/flutter/flutter/issues/17738#issuecomment-392237064
    await tester.runAsync(() async {
      final key = GlobalKey();

      await tester.pumpWidget(GoldenBoundary(
        globalKey: key,
        child: widget,
      ));

      final screenshotBytes = await capturePng(tester, key);
      await writeToFile('showcase/golden_$index.png', screenshotBytes);
      expect(1, equals(1));
    });
  });
}

void main() {
  final widgetList = [
    MyWidget(),
    MyWidget(anotherBuild: true),
    MyWidget(sliderValue: 5.0),
  ];

  int index = 0;
  widgetList.forEach((widget) async {
    makeTest(widget, index);
    index++;
  });
}
