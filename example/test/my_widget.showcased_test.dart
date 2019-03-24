// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcase/showcase.dart';
import 'package:showcase_example/my_widget.dart';

Future<void> main() async {
  final FontLoader fontLoader = FontLoader('Roboto')..addFont(fetchFont());
  await fontLoader.load();

  group('Showcase MyWidget', () {
    showcaseWidgets([MyWidget()]);
  });
}
