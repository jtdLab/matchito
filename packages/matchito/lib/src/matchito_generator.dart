import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:matchito_annotation/matchito_annotation.dart';
import 'package:source_gen/source_gen.dart';

class MatchitoGenerator extends GeneratorForAnnotation<Matchito> {
  const MatchitoGenerator();

  /*   @override
  FutureOr<String> generate(
    LibraryReader oldLibrary,
    BuildStep buildStep,
  ) async {
    final assetId = await buildStep.resolver.assetIdForElement(
      oldLibrary.element,
    );
    if (await buildStep.resolver.isLibrary(assetId).then((value) => !value)) {
      return '';
    }
    final library = await buildStep.resolver.libraryFor(assetId);

    final buffer = StringBuffer();

    final imports = <String>[];
    final exports = <String>[];

    for (final element in library.topLevelElements.where(
      typeChecker.hasAnnotationOf,
    )) {
      if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@Matchito can only be applied on classes. Failing element: ${element.name}',
        element: element,
      );
      }

      if (element.isValidMock) {
      mocks.add(element.asMock());
      } else if (element.isValidFake) {
      fakes.add(element.asFake());
      } else {
      throw InvalidGenerationSourceError(
        '@Matchito can only be applied on classes defined in the following way:\n'
        '\n'
        'Mock:\n'
        'class MockMyClass extends _\$MockMyClass implements MyClass {}\n'
        '\n'
        'Fake:\n'
        'class FakeMyClass extends Fake implements MyClass {}\n'
        '\n'
        'Failing element: ${element.name}\n',
        element: element,
      );
      }
    }

    for (final directive in library.libraryImports) {
      if (typeChecker.hasAnnotationOf(directive.importedLibrary?.element)) {
      imports.add(directive.uri);
      }
    }

    for (final directive in library.libraryExports) {
      if (typeChecker.hasAnnotationOf(directive.exportedLibrary?.element)) {
      exports.add(directive.uri);
      }
    }

    for (final mock in mocks) {
      buffer.writeln(mock.asMockClass().toString());
    }

    return buffer.toString();
  }
 */

  @override
  Stream<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async* {
    final matchitoAnnotation = annotation.peek('types');
    if (matchitoAnnotation == null || !matchitoAnnotation.isList) {
      throw InvalidGenerationSourceError(
        '@Matchito annotation must have a "types" parameter of type List.',
        element: element,
      );
    }

    final types =
        matchitoAnnotation.listValue.map((dartObject) {
          final type = dartObject.toTypeValue();
          if (type == null) {
            throw InvalidGenerationSourceError(
              'All elements in the "type" list must be valid types.',
              element: element,
            );
          }
          return type;
        }).toList();

    if (types.isEmpty) {
      throw InvalidGenerationSourceError(
        'The "types" list cannot be empty.',
        element: element,
      );
    }

    yield 'const _sentinel = Object();';
    for (final type in types) {
      final typeName = type.getDisplayString();
      final typeElement = type.element as ClassElement?;
      final parameters =
          typeElement?.fields
              .where((field) => !field.isStatic)
              .map((field) => field.name)
              .toList();

      if (parameters == null || parameters.isEmpty) {
        yield 'Matcher is$typeName() => isA<$typeName>();';
      } else {
        final parameterMatchers = parameters
            .map((param) {
              return '''
      if ($param != _sentinel) {
        matcher = matcher.having((e) => e.$param, '$param', $param);
      }
    ''';
            })
            .join('\n');

        final parameterList = parameters
            .map((param) => 'Object? $param = _sentinel')
            .join(', ');

        yield 'Matcher is$typeName({$parameterList}) {';
        yield '  var matcher = isA<$typeName>();';
        yield parameterMatchers;
        yield '  return matcher;';
        yield '}';
      }
    }
  }
}
