import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/matchito_generator.dart';

/// Builds generators for `build_runner` to run
Builder matchito(BuilderOptions options) {
  return PartBuilder(
    [MatchitoGenerator()],
    '.matchito.dart',
    header: '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

const _sentinel = Object();
''',
    options: options,
  );
}
