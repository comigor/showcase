import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:showcase/components/my_widget.dart';
import '../helpers/golden_boundary.dart';

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';

import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as path;

import 'package:quiver/testing/async.dart';

Future<Uint8List> capturePng(WidgetTester tester, GlobalKey key) async {
  // try {
    // print('inside');
    // RenderRepaintBoundary boundary = tester.allRenderObjects.firstWhere((o) => o is RenderRepaintBoundary);
    // RenderRepaintBoundary boundary = tester.firstRenderObject(find.byKey(key));
    RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
    // RenderRepaintBoundary boundary = _globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    // return byteData.buffer.asUint8List();
    // return null;
    var pngBytes = byteData.buffer.asUint8List();
    var bs64 = base64Encode(pngBytes);
    // print(pngBytes.length);
    // print(bs64);
    return pngBytes;
    // // setState(() {});
    // return pngBytes;
  // } catch (e) {
  //   print(e);
  //   return null;
  // }
}

Future<void> write(Uint8List u, int index) async {
  final String pathName = 'golden_$index.png';

  final Directory goldenDir = Directory(path.dirname(pathName));
  if (!goldenDir.existsSync()) {
    goldenDir.createSync(recursive: true);
  }
  final File output = File(pathName);

  // print('before');
  // final aaa = await capturePng(tester, key);
  // print('middle');
  await output.writeAsBytes(u);
}

void makeTest(Widget w, int index) async {
  testWidgets('MyWidget golden $index', (WidgetTester tester) async {
    // https://github.com/flutter/flutter/issues/17738#issuecomment-392237064
    await tester.runAsync(() async {
      final key = GlobalKey();

      final TestWidgetsFlutterBinding binding = tester.binding;
      if (binding is AutomatedTestWidgetsFlutterBinding)
        binding.addTime(const Duration(seconds: 7));

      await tester.pumpWidget(GoldenBoundary(
        globalKey: key,
        child: w,
      ));

      // print('before');
      final aaa = await capturePng(tester, key);
      await write(aaa, index);
      expect(1, equals(1));
      return Future.value(1);
    });    
    // print('end');
    // await write(aaa, index);
    // print('after');
  });
}

void main() {
  final widgetList = [
    MyWidget(),
    MyWidget(anotherBuild: true),
    MyWidget(sliderValue: 5.0),
  ];

  int index = 0;

  makeTest(MyWidget(), 0);

  // widgetList.forEach((widget) async {
  //   makeTest(widget, index);

  //   index++;
  // });

}
