import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import './golden_boundary.dart';

Future<Uint8List> _capturePng(WidgetTester tester, GlobalKey key) async {
  final RenderObject boundary = key.currentContext.findRenderObject();
  if (boundary is RenderRepaintBoundary) {
    final ui.Image image = await boundary.toImage();
    final ByteData byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }
  return null;
}

Future<File> _writeToFile(String path, Uint8List imageBytes) async {
  final File output = File(path)..createSync(recursive: true);
  return await output.writeAsBytes(imageBytes);
}

Future<void> _makeTest(Widget widget, int index,
    {ContainerBuilder customContainerBuilder, Size size, String outDir}) async {
  final String strIndex = index.toString().padLeft(3, '0');
  testWidgets('[$strIndex] Showcasing ${widget.toString()}',
      (WidgetTester tester) async {
    // https://github.com/flutter/flutter/issues/17738#issuecomment-392237064
    await tester.runAsync(() async {
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(GoldenBoundary(
        globalKey: key,
        child: widget,
        size: size,
        customContainerBuilder: customContainerBuilder,
      ));

      final Uint8List screenshotBytes = await _capturePng(tester, key);
      await _writeToFile(
          '${outDir ?? 'showcase'}/${strIndex}_${widget.toString()}.png',
          screenshotBytes);
    });
  });
}

/// Use this function to generate screenshots of your widgets. See optional
/// parameters for custom configurations.
Future<void> showcaseWidgets(List<Widget> widgets,
    {ContainerBuilder customContainerBuilder, Size size, String outDir}) {
  return Future.wait(widgets.asMap().entries.map((entry) => _makeTest(
        entry.value,
        entry.key,
        customContainerBuilder: customContainerBuilder,
        size: size,
        outDir: outDir,
      )));
}
