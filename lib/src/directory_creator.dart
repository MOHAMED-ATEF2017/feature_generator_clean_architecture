// Copyright (c) 2025 MOHAMED ATEF.
// Licensed under the MIT License.

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:feature_generator/src/code_writers.dart';

/// Writes featue files and directories to the specified path.
///
/// ```dart
/// createControllerFiles('Auth');
/// ```

// Function to create specific controller files
void _createControllerFiles(String name) {
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

/// Writes core files and directories to the specified path.
///
/// ```dart
/// createCoreFiles();
/// ```

void _createCoreFiles() {
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

      // Create default files
      if (dir.contains('errors')) {
        _createFailureFile(directory);
      } else if (dir.contains('use_cases')) {
        _createUseCaseFile(directory);
      }
    }
  }
}

// Create failure.dart

void _createFailureFile(Directory dir) {
  final failureFile = File('${dir.path}/failure.dart');
  if (!failureFile.existsSync()) {
    failureFile.createSync(recursive: true);
    writeCoreFailureCode(failureFile);
    print('Created core file: ${failureFile.path} ✓');
  } else {
    print('Core file already exists: ${failureFile.path}');
  }
}

// Create use_case.dart

void _createUseCaseFile(Directory dir) {
  final useCaseFile = File('${dir.path}/use_case.dart');
  if (!useCaseFile.existsSync()) {
    useCaseFile.createSync(recursive: true);
    writeCoreUseCaseCode(useCaseFile);
    print('Created core file: ${useCaseFile.path} ✓');
  } else {
    print('Core file already exists: ${useCaseFile.path}');
  }
}

/// Generates Clean Architecture folder structure for a feature
///
/// {@template feature_generator}
/// Creates the following structure:
///
/// ```dart
/// lib/features/<feature_name>/
///   ├── data/
///   ├── domain/
///   └── presentation/
/// ```
/// {@endtemplate}
///

void createFeatureStructure(String featureName, {bool installDeps = false}) {
  if (featureName.isEmpty) {
    print('Please provide a feature name as an argument.');
    return;
  }

  // Create core directories and files first
  if (installDeps) _createCoreFiles();

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
  _createControllerFiles(name);

  print('Creating folders and files successfully ✓');
  print('Creating files successfully ✓');

  if (installDeps) {
    _runPostInstallation();
  }
}

/// Writes initial code to the specified file.
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

/// Runs post-installation tasks such as adding dependencies and running build_runner.
void _runPostInstallation() {
  try {
    final isWindows = Platform.isWindows;
    final flutterExecutable = isWindows ? 'flutter.bat' : 'flutter';

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

    print('📦 Installing dependencies...');
    _runCommand(flutterExecutable,
        ['pub', 'add', 'get_it', 'injectable', 'flutter_bloc', 'dartz', 'dio']);
    _runCommand(flutterExecutable,
        ['pub', 'add', '--dev', 'build_runner', 'injectable_generator']);

    print('🚀 Running build_runner...');
    _runCommand(flutterExecutable, [
      'pub',
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs'
    ]);
  } catch (e) {
    print('''
⚠️ Error during post-installation:
$e

💡 Troubleshooting steps:
1. Ensure Flutter is installed and in your PATH
2. Run manually:
   - flutter pub add flutter_bloc injectable dartz dio get_it
   - flutter pub add --dev build_runner injectable_generator
   - flutter pub run build_runner build
''');
  }
}

// Add this new function
void installDependencies({bool createCore = true}) {
  if (createCore) {
    _createCoreFiles();
    _createServiceLocator();
  }
  _runPostInstallation();
}

// Add service locator creation
void _createServiceLocator() {
  final file = File('lib/core/utils/service_locator.dart');
  if (!file.existsSync()) {
    writeServiceLocatorCode(file);
    print('Created service locator: ${file.path} ✓');
  }
}
