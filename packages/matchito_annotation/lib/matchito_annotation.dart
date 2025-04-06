/// {@template matchito_annotation.matchito}
/// Flags a library as needing to be processed by Matchito.
/// {@endtemplate}
class Matchito {
  const Matchito({this.types = const []});

  final List<Type> types;
}
