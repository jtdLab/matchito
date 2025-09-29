// TODO(Jonas): rm later
// ignore_for_file: deprecated_member_use

import 'dart:async';

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
  ) {
    final matchitoAnnotation = annotation.peek('types');
    if (matchitoAnnotation == null || !matchitoAnnotation.isList) {
      throw InvalidGenerationSourceError(
        '@Matchito annotation must have a "types" parameter of type List.',
        element: element,
      );
    }

    final types = matchitoAnnotation.listValue.map((dartObject) {
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

    final buffer = ['const _sentinel = Object();\n'];

    for (final type in types) {
      final typeName = type.getDisplayString();
      final typeElement = type.element as ClassElement?;
      final parameters = {
        ...?typeElement?.fields
            .where(
              (field) =>
                  !field.metadata.hasInternal &&
                  !field.isStatic &&
                  field.name != 'copyWith' &&
                  field.name != 'hashCode' &&
                  field.name != 'runtimeType' &&
                  !(field.name?.startsWith('_') ?? false),
            )
            .map((field) => field.name),
        ...?typeElement?.allSupertypes
            .expand((supertype) => supertype.element.fields)
            .where(
              (field) =>
                  !field.metadata.hasInternal &&
                  !field.isStatic &&
                  field.name != 'copyWith' &&
                  field.name != 'hashCode' &&
                  field.name != 'runtimeType' &&
                  !(field.name?.startsWith('_') ?? false),
            )
            .map((field) => field.name),
      };

      if (parameters.isEmpty) {
        buffer.add('Matcher is$typeName() => isA<$typeName>();\n');
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

        buffer.add('Matcher is$typeName({$parameterList}) {');
        buffer.add('  var matcher = isA<$typeName>();\n');
        buffer.add(parameterMatchers);
        buffer.add('  return matcher;');
        buffer.add('}');
      }
    }

    return Stream.value(buffer.join('\n'));
  }
}
