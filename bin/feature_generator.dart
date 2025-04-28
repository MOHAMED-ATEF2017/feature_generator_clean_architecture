#!/usr/bin/env dart

// Copyright (c) 2024 MOHAMED ATEF. 
// Licensed under the MIT License.

import 'package:args/args.dart';
import 'package:feature_generator/src/directory_creator.dart';

// void main(List<String> arguments) {
//   final parser = ArgParser()
//     ..addCommand('create', ArgParser()..addOption('name', abbr: 'n'));
  
//   final results = parser.parse(arguments);
  
//   if (results.command?.name == 'create') {
//     final name = results.command!['name'];
//     if (name == null) {
//       print('Please provide a feature name using --name');
//       return;
//     }
//     createFeatureStructure(name);
//   }
// }

void main(List<String> args) {
  final parser = ArgParser()
    ..addCommand(
      'create',
      ArgParser()
        ..addOption('name', abbr: 'n', mandatory: true)
        ..addFlag('install-deps', abbr: 'i', defaultsTo: false),
    );

  try {
    final result = parser.parse(args);
    
    if (result.command?.name == 'create') {
      final name = result.command!['name'] as String;
      final installDeps = result.command!['install-deps'] as bool;
      
      createFeatureStructure(name, installDeps: installDeps);
    }
  } catch (e) {
    print('Error: $e');
    print(parser.usage);
  }
}