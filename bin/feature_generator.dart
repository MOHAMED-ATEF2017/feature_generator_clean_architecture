#!/usr/bin/env dart
// Copyright (c) 2025 MOHAMED ATEF.
// Licensed under the MIT License.

import 'package:args/args.dart';
import 'package:feature_generator/src/directory_creator.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addCommand(
      'create',
      ArgParser()
        ..addOption(
          'name',
          abbr: 'n', /* mandatory: true */
        )
        ..addFlag('install-deps', abbr: 'i', defaultsTo: false),
    )
    ..addCommand(
        'install', ArgParser()..addFlag('core', abbr: 'c', defaultsTo: true));

  try {
    final result = parser.parse(args);

    if (result.command?.name == 'create') {
      final name = result.command!['name'] as String?;
      if (name == null) {
        print('Error: --name is required.');
        print('Please provide a feature name using --name');
        print(parser.usage);
        return;
      }
      // final installDeps = result.command!['install-deps'] as bool;
      createFeatureStructure(name,
          installDeps: result.command!['install-deps'] as bool);
    } else if (result.command?.name == 'install') {
      installDependencies(createCore: result.command!['core'] as bool);
    }
  } catch (e) {
    print('Error: $e');
    print(parser.usage);
  }
}
