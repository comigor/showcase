import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'package:showcase/showcased.dart';

class ShowcaseGenerator extends Generator {
  TypeChecker get _typeChecker => const TypeChecker.fromRuntime(Showcased);

  File generatedFilePath(Uri originalFile) {
    final List<String> butFirst = originalFile.pathSegments.skip(1).toList()
      ..insert(0, 'test');
    butFirst.add(butFirst.removeLast().replaceAllMapped(RegExp(r'^(.*)\.dart$'),
        (Match match) => '${match[1]}_test.showcased.dart'));
    final Uri newPath = originalFile.replace(pathSegments: butFirst);
    return File(newPath.path);
  }

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    for (AnnotatedElement annotatedElement
        in library.annotatedWith(_typeChecker)) {
      // TODO(igor): filter Widgets only
      return generateForAnnotatedElement(annotatedElement.element,
          annotatedElement.annotation, buildStep, library);
    }
    return null;
  }

  Future<String> generateForAnnotatedElement(
      Element element,
      ConstantReader annotation,
      BuildStep buildStep,
      LibraryReader library) async {
    final StringBuffer buffer = StringBuffer();

    final Uri assetUri = library.pathToAsset(buildStep.inputId);

    buffer.writeln('''
// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter_test/flutter_test.dart';
import 'package:showcase/showcase.dart';
import '${assetUri.toString()}';

void main() {
  group('Showcase ${element.name}', () {
    showcaseWidgets([${element.name}()]);
  });
}
''');

    final File file = generatedFilePath(assetUri);
    await file.create(recursive: true);

    await file.writeAsString(buffer.toString());

    return null;
  }
}

Builder showcaseBuilder(BuilderOptions options) {
  return LibraryBuilder(ShowcaseGenerator(),
      generatedExtension: '.showcased.dart');
}
