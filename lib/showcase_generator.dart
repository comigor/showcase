import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'package:showcase/showcased.dart';

class _ShowcaseGenerator extends Generator {
  TypeChecker get _typeChecker => const TypeChecker.fromRuntime(Showcased);

  File generatedFilePath(Uri originalFile) {
    final List<String> butFirst = originalFile.pathSegments.skip(1).toList()
      ..insert(0, 'test');
    butFirst.add(butFirst.removeLast().replaceAllMapped(RegExp(r'^(.*)\.dart$'),
        (Match match) => '${match[1]}.showcased_test.dart'));
    final Uri newPath = originalFile.replace(pathSegments: butFirst);
    return File(newPath.path);
  }

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    for (AnnotatedElement annotatedElement
        in library.annotatedWith(_typeChecker)) {
      // TODO(igor): filter Widgets only
      final Element subElement = annotatedElement.element;
      if (subElement is ClassElement) {
        return generateForAnnotatedElement(
            subElement, annotatedElement.annotation, buildStep, library);
      }
    }
    return null;
  }

  Future<String> generateForAnnotatedElement(
      ClassElement element,
      ConstantReader annotation,
      BuildStep buildStep,
      LibraryReader library) async {
    final StringBuffer buffer = StringBuffer();

    final Uri assetUri = library.pathToAsset(buildStep.inputId);

    final ConstructorElement defaultConstructor = element.constructors
        .firstWhere((ConstructorElement c) => c.name == '', orElse: () => null);

    final ParameterElement _firstRequiredParameter =
        defaultConstructor.parameters.firstWhere((ParameterElement p) {
      final bool namedParamIsRequired = p.metadata.firstWhere(
            (a) => a.computeConstantValue().type.name == 'Required',
            orElse: () => null,
          ) !=
          null;

      return (p.isNotOptional || (p.isNamed && namedParamIsRequired)) &&
          p.defaultValueCode == null;
    }, orElse: () => null);
    final bool hasAnyRequiredParameter = _firstRequiredParameter != null;

    final ConstructorElement forDesignTime = element.constructors.singleWhere(
      (ConstructorElement c) => c.name == 'forDesignTime',
      orElse: () => null,
    );
    final bool isForDesignTimeDefined = forDesignTime != null;

    if (hasAnyRequiredParameter && !isForDesignTimeDefined) {
      throw Exception('''

${element.name} default constructor has required parameters which are not set.
Give them default values or create a [forDesignTime] factory with default (dev-only) values.
See https://github.com/flutter/flutter-intellij/wiki/Using-live-preview

''');
    }

    final String constructor =
        isForDesignTimeDefined ? '${element.name}.forDesignTime' : element.name;

    buffer.write('''
// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter_test/flutter_test.dart';
import 'package:showcase/showcase.dart';
import '${assetUri.toString()}';

Future<void> main() async {
  await loadFonts();

  group('Showcase ${element.name}', () {
    showcaseWidgets([$constructor()]);
  });
}
''');

    final File file = generatedFilePath(assetUri);
    await file.create(recursive: true);

    await file.writeAsString(buffer.toString());

    return null;
  }
}

/// Supports `package:build_runner` creation and configuration of `showcase`.
///
/// Not meant to be invoked by hand-authored code.
Builder showcaseBuilder(BuilderOptions options) =>
    LibraryBuilder(_ShowcaseGenerator(), generatedExtension: '.showcased.dart');
