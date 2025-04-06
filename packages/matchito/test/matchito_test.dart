import 'dart:async';

import 'package:matchito/src/matchito_generator.dart';
import 'package:matchito_annotation/matchito_annotation.dart';
import 'package:source_gen_test/src/build_log_tracking.dart';
import 'package:source_gen_test/src/init_library_reader.dart';
import 'package:source_gen_test/src/test_annotated_classes.dart';

Future<void> main() async {
  final reader = await initializeLibraryReaderForDirectory(
    'test/sources',
    'matchito_test_src.dart',
  );

  initializeBuildLogTracking();
  testAnnotatedElements<Matchito>(reader, const MatchitoGenerator());
}
