# Matchito

Ready to use matcher for every dart object.

# How to use

## Install

To use [matchito], you will need your typical [build_runner]/code-generator setup.\
First, install [build_runner] and [matchito] by adding them to your `pubspec.yaml` file:

For a Flutter project:

```console
flutter pub add --dev build_runner
flutter pub add --dev matchito_annotation
flutter pub add --dev matchito
```

For a Dart project:

```console
dart pub add --dev build_runner
dart pub add --dev matchito_annotation
dart pub add --dev matchito
```

This installs four packages:

- [build_runner], the tool to run code-generators
- [matchito], the code generator
- [matchito_annotation], a package containing annotations for [matchito].

## Run the generator

To run the code generator, execute the following command:

```
dart run build_runner build -d
```

For Flutter projects, you can also run:

```
flutter pub run build_runner build -d
```

# Usage

Let's start with a Dart library, animals.dart:

```dart
import 'package:matchito_annotation/matchito_annotation.dart';

// Annotation which generates the animals.matchers.dart library and the isCat, isDog matcher functions.
@Matchito([Cat, Dog])
abstract class _Matchers {}

class Cat {
    const Cat({required this.name, required this.age});

    final String name;

    final int age;
}

class Dog {    
    const Dog({required this.name, required this.race});

    final String name;

    final String race;
}

void main() { 
    test('cat', () {
        final cat = Cat(name: 'Tom', age: 5);
        expect(cat, isCat(age: 5));
    });

    test('dog', () {
        final dog = Dog(name: 'Tom', race: 'Beagle');
        expect(cat, isDog(name: 'Tom', race: startsWith('Bea')));
    });
}
```