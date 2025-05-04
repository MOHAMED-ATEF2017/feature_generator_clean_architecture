// Copyright (c) 2024 MOHAMED ATEF. 
// Licensed under the MIT License.

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:feature_generator/src/code_writers.dart';

// Function to create specific controller files
void createControllerFiles(String name) {
  final controllerPath =
      '${Directory.current.path}/lib/features/$name/presentation/controller';

  // Define the cubit and state file names
  final cubitFileName = '${name.toLowerCase()}_cubit.dart';
  final stateFileName = '${name.toLowerCase()}_state.dart';

  // Create cubit file
  final cubitFilePath = '$controllerPath/$cubitFileName';
  final cubitFile = File(cubitFilePath);
  if (!cubitFile.existsSync()) {
    cubitFile.createSync();
    print('Created file: $cubitFilePath ✓');
    writeCubitCode(cubitFile, name);
  } else {
    print('File already exists: $cubitFilePath');
  }

  // Create state file
  final stateFilePath = '$controllerPath/$stateFileName';
  final stateFile = File(stateFilePath);
  if (!stateFile.existsSync()) {
    stateFile.createSync();
    print('Created file: $stateFilePath ✓');
    writeStateCode(stateFile, name);
  } else {
    print('File already exists: $stateFilePath');
  }  
}

void createCoreFiles() {
  final coreDirectories = [
    'lib/core/errors',
    'lib/core/use_cases',
  ];

  // Create core directories
  for (var dir in coreDirectories) {
    final directory = Directory(dir);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      print('Created core directory: $dir ✓');
    }
  }

  // Create failure.dart
  final failureFile = File('lib/core/errors/failure.dart');
  if (!failureFile.existsSync()) {
    failureFile.createSync(recursive: true);
    writeCoreFailureCode(failureFile);
    print('Created core file: ${failureFile.path} ✓');
  } else {
    print('Core file already exists: ${failureFile.path}');
  }

  // Create use_case.dart
  final useCaseFile = File('lib/core/use_cases/use_case.dart');
  if (!useCaseFile.existsSync()) {
    useCaseFile.createSync(recursive: true);
    writeCoreUseCaseCode(useCaseFile);
    print('Created core file: ${useCaseFile.path} ✓');
  } else {
    print('Core file already exists: ${useCaseFile.path}');
  }
}

void createFeatureStructure(String featureName ,{bool installDeps = false}) {
  if (featureName.isEmpty) {
    print('Please provide a feature name as an argument.');
    return;
  }

  // Create core directories and files first
  createCoreFiles();

  // Get the feature name from command line arguments
  final name = featureName;
  // Project path
  final projectPath = '${Directory.current.path}/lib/features/$name';

  // Folder creation
  final directories = [
    '$projectPath/data/data_sources',
    '$projectPath/data/models',
    '$projectPath/data/repo',
    '$projectPath/domain/repositories',
    '$projectPath/domain/use_cases',
    '$projectPath/presentation/controller',
    '$projectPath/presentation/views',
    '$projectPath/presentation/views/widgets',
  ];

  for (var dir in directories) {
    final directory = Directory(dir);

    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      print('Created: $dir ✓');
    } else {
      print('Directory already exists: $dir ');
    }

    // Create a Dart file in each directory
    final fileName =
        '${name.toLowerCase()}_${dir.split('/').last.toLowerCase()}.dart'; // Creating a unique file name
    final filePath = '$dir/$fileName';

    final file = File(filePath);

    // Create the file if it doesn't exist
    if (!file.existsSync()) {
      file.createSync();
      print('Created file: $filePath ✓');
      writeInitialCode(file, fileName, name);
    } else {
      print('File already exists: $filePath');
    }
  }
// Call the function to create controller files
  createControllerFiles(name);

  print('Creating folders and files successfully ✓');
  print('Creating files successfully ✓');

    if (installDeps) {
    _runPostInstallation();
  }
}
void _runPostInstallation() {
  try {
    final isWindows = Platform.isWindows;
    final flutterExecutable = isWindows ? 'flutter.bat' : 'flutter';
    final currentDir = Directory.current.path;

    print('🔧 Verifying Flutter installation...');
    final flutterCheck = Process.runSync(
      flutterExecutable,
      ['--version'],
      runInShell: true,
    );

    if (flutterCheck.exitCode != 0) {
      print('''
❌ Flutter not found in PATH!
Please ensure Flutter is installed and available in your system PATH.
Installation guide: https://flutter.dev/docs/get-started/install
''');
      return;
    }

    print('📦 Adding dependencies...');
    _runCommand(flutterExecutable, ['pub', 'add', 'flutter_bloc', 'injectable', 'dartz', 'dio']);
    _runCommand(flutterExecutable, ['pub', 'add', '--dev', 'build_runner', 'injectable_generator', 'intl_utils', 'flutter_gen_runner', 'flutter_lints']);

    print('🚀 Running build_runner...');
    _runCommand(flutterExecutable, ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs']);

  } catch (e) {
    print('''
⚠️ Error during post-installation:
$e

💡 Troubleshooting steps:
1. Ensure Flutter is installed and in your PATH
2. Run manually:
   - flutter pub add flutter_bloc injectable dartz dio
   - flutter pub add --dev build_runner injectable_generator
   - flutter pub run build_runner build
''');
  }
}

void _runCommand(String command, List<String> args) {
  print('\n🏃 Running: $command ${args.join(' ')}');
  final result = Process.runSync(
    command,
    args,
    runInShell: true,
    workingDirectory: Directory.current.path,
  );

  if (result.exitCode != 0) {
    print('❌ Command failed:');
    print(result.stderr);
    throw Exception('Command failed: $command ${args.join(' ')}');
  }
  
  print('✅ Command succeeded');
  print(result.stdout);
}