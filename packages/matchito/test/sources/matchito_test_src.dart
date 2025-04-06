// ignore_for_file: unused_element

import 'package:matchito_annotation/matchito_annotation.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(
  r'''
const _sentinel = Object();

Matcher isFoo() => isA<Foo>();

Matcher isBar({Object? bam = _sentinel, Object? baz = _sentinel}) {
  var matcher = isA<Bar>();

  if (bam != _sentinel) {
    matcher = matcher.having((e) => e.bam, 'bam', bam);
  }

  if (baz != _sentinel) {
    matcher = matcher.having((e) => e.baz, 'baz', baz);
  }

  return matcher;
}

Matcher isBaz(
    {Object? quick = _sentinel,
    Object? bam = _sentinel,
    Object? baz = _sentinel}) {
  var matcher = isA<Baz>();

  if (quick != _sentinel) {
    matcher = matcher.having((e) => e.quick, 'quick', quick);
  }

  if (bam != _sentinel) {
    matcher = matcher.having((e) => e.bam, 'bam', bam);
  }

  if (baz != _sentinel) {
    matcher = matcher.having((e) => e.baz, 'baz', baz);
  }

  return matcher;
}
''',
  configurations: ['default'],
)
@Matchito(types: [Foo, Bar, Baz])
abstract class _TestClass1 {}

@ShouldThrow('The "types" list cannot be empty.', configurations: ['default'])
@Matchito()
abstract class _TestClass2 {}

class Foo {}

class Bar {
  Bar({required this.bam, this.baz = 0});
  final String bam;
  final int baz;
}

class Baz extends Bar {
  Baz({required this.quick, required super.bam, super.baz});
  final String quick;
}
