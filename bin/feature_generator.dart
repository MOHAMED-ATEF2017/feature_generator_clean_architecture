#!/usr/bin/env dart

import 'package:args/args.dart';
import 'package:feature_generator/src/directory_creator.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addCommand('create', ArgParser()..addOption('name', abbr: 'n'));
  
  final results = parser.parse(arguments);
  
  if (results.command?.name == 'create') {
    final name = results.command!['name'];
    if (name == null) {
      print('Please provide a feature name using --name');
      return;
    }
    createFeatureStructure(name);
  }
}