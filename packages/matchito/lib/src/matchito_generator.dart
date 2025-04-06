import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:matchito_annotation/matchito_annotation.dart';
import 'package:source_gen/source_gen.dart';

class MatchitoGenerator extends GeneratorForAnnotation<Matchito> {
  const MatchitoGenerator();

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
      try {
        final typeName = type.getDisplayString();
        final typeElement = type.element as ClassElement?;
        final parameters = {
          ...?typeElement?.fields
              .where(
                (field) =>
                    !field.isStatic &&
                    field.name != 'copyWith' &&
                    field.name != 'hashCode' &&
                    field.name != 'runtimeType' &&
                    !field.name.startsWith('_'),
              )
              .map((field) => field.name),
          ...?typeElement?.allSupertypes
              .expand((supertype) => supertype.element.fields)
              .where(
                (field) =>
                    !field.isStatic &&
                    field.name != 'copyWith' &&
                    field.name != 'hashCode' &&
                    field.name != 'runtimeType' &&
                    !field.name.startsWith('_'),
              )
              .map((field) => field.name),
        };

        if (parameters.isEmpty) {
          yield 'Matcher is$typeName() => isA<$typeName>();';
        } else {
          final parameterList = parameters
              .map((param) => 'Object? $param = _sentinel')
              .join(', ');
          final parameterMatchers = parameters
              .map((param) {
                return '''
      if ($param != _sentinel) {
        matcher = matcher.having((e) => e.$param, '$param', $param);
      }
    ''';
              })
              .join('\n');

          yield 'Matcher is$typeName({$parameterList}) {';
          yield '  var matcher = isA<$typeName>();';
          yield parameterMatchers;
          yield '  return matcher;';
          yield '}';
        }
      } catch (e) {
        stderr.writeln(e.toString());
      }
    }
  }
}
