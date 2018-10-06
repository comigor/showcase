import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import './golden_boundary.dart';

Future<Uint8List> capturePng(WidgetTester tester, GlobalKey key) async {
  RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
  ui.Image image = await boundary.toImage();
  ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData.buffer.asUint8List();
}

Future<File> writeToFile(String path, Uint8List imageBytes) async {
  final File output = File(path);
  output.createSync(recursive: true);
  return await output.writeAsBytes(imageBytes);
}

void makeTest(Widget widget, int index, {ContainerBuilder customContainerBuilder, String outDir}) async {
  final strIndex = index.toString().padLeft(3, '0');
  testWidgets('[$strIndex] Showcasing ${widget.toString()}', (WidgetTester tester) async {
    // https://github.com/flutter/flutter/issues/17738#issuecomment-392237064
    await tester.runAsync(() async {
      final key = GlobalKey();

      await tester.pumpWidget(GoldenBoundary(
        globalKey: key,
        child: widget,
        customContainerBuilder: customContainerBuilder,
      ));

      final screenshotBytes = await capturePng(tester, key);
      await writeToFile('${outDir ?? 'showcase'}/${strIndex}_${widget.toString()}.png', screenshotBytes);
    });
  });
}

showcaseWidgets(List<Widget> widgets, {ContainerBuilder customContainerBuilder, String outDir}) {
  widgets
      .asMap()
      .forEach((index, widget) => makeTest(widget, index, customContainerBuilder: customContainerBuilder, outDir: outDir));
}
