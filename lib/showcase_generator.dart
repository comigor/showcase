import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'package:showcase/showcased.dart';
import 'package:dart_style/dart_style.dart';

final DartFormatter _dartFormatter = DartFormatter();

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
        return generateForAnnotatedElement(annotatedElement, subElement,
            annotatedElement.annotation, buildStep, library);
      }
    }
    return null;
  }

  Future<String> generateForAnnotatedElement(
      AnnotatedElement annotatedElement,
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
            (ElementAnnotation a) =>
                a.computeConstantValue().type.name == 'Required',
            orElse: () => null,
          ) !=
          null;

      return (p.isNotOptional || (p.isNamed && namedParamIsRequired)) &&
          p.defaultValueCode == null;
    }, orElse: () => null);
    final bool hasAnyRequiredParameter = _firstRequiredParameter != null;

    final MethodElement forDesignTime =
        element.lookUpMethod('forDesignTime', library.element);
    final bool isForDesignTimeDefined = forDesignTime != null;

    if (hasAnyRequiredParameter && !isForDesignTimeDefined) {
      throw Exception('''

${element.name} default constructor has required parameters which are not set.
Give them default values or create a [forDesignTime] class method with default
(dev-only) values, that return either [Widget] or [List<Widget>].

''');
    }

    final double boundaryWidth =
        annotatedElement.annotation.peek('width').doubleValue;
    final double boundaryHeight =
        annotatedElement.annotation.peek('height').doubleValue;

    String constructor = '[${element.name}()]';
    if (isForDesignTimeDefined &&
        forDesignTime.returnType.displayName == 'Widget') {
      constructor = '[${element.name}.forDesignTime()]';
    } else if (isForDesignTimeDefined &&
        forDesignTime.returnType.displayName == 'List<Widget>') {
      constructor = '${element.name}.forDesignTime()';
    }

    buffer.write('''
// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showcase/showcase.dart';
import '$assetUri';

Future<void> main() async {
  await loadFonts();

  group('Showcase ${element.name}', () {
    showcaseWidgets($constructor, size: const Size($boundaryWidth, $boundaryHeight));
  });
}
''');

    final File file = generatedFilePath(assetUri);
    await file.create(recursive: true);

    final String formattedFile = _dartFormatter.format(buffer.toString());

    await file.writeAsString(formattedFile);

    return null;
  }
}

/// Supports `package:build_runner` creation and configuration of `showcase`.
///
/// Not meant to be invoked by hand-authored code.
Builder showcaseBuilder(BuilderOptions options) =>
    LibraryBuilder(_ShowcaseGenerator(), generatedExtension: '.showcased.dart');
