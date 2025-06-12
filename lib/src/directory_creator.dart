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
    'lib/core/utils',
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
        _createCoreUseCaseFile(directory);
      }
    }
  }
  _createServiceLocator();
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

void _createCoreUseCaseFile(Directory dir) {
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

  // Automatically configure PATH after installation
  _configurePathAutomatically();
}

/// Automatically configures the PATH to include pub cache bin directory
void _configurePathAutomatically() {
  try {
    print('\n🔧 Configuring PATH...');

    final configFile = _getShellConfigFile();
    final exportCommand = _getExportCommand();

    if (_pathAlreadyExists(configFile)) {
      print('✅ PATH already configured!');
      return;
    }

    // Create config file if it doesn't exist
    final file = File(configFile);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
      print('Created config file: $configFile');
    }

    // Append the export command
    file.writeAsStringSync(exportCommand, mode: FileMode.append);
    print('✅ Updated $configFile');
    print('📝 Added: export PATH="\$PATH:\$HOME/.pub-cache/bin"');
    print('');
    print('🎉 PATH configured successfully!');
    print('💡 Restart your terminal or run: source $configFile');
    print('');
  } catch (e) {
    print('⚠️  Warning: Could not automatically configure PATH');
    print('Please manually add this to your shell config file:');
    print('export PATH="\$PATH:\$HOME/.pub-cache/bin"');
    print('');
    print(
        'For more details, run: dart pub global run feature_generator:_post_install');
  }
}

/// Gets the appropriate shell config file path
String _getShellConfigFile() {
  if (Platform.isWindows) {
    return _getWindowsPath();
  }

  final shell = Platform.environment['SHELL']?.split('/').last ?? 'bash';
  switch (shell) {
    case 'zsh':
      return Platform.environment['ZDOTDIR'] ??
          '${Platform.environment['HOME']}/.zshrc';
    case 'fish':
      return '${Platform.environment['HOME']}/.config/fish/config.fish';
    default:
      return '${Platform.environment['HOME']}/.bashrc';
  }
}

/// Gets the appropriate export command for the platform
String _getExportCommand() {
  if (Platform.isWindows) {
    return '\n\$env:Path += ";${Platform.environment['USERPROFILE']}\\.pub-cache\\bin"';
  }
  return '\nexport PATH="\$PATH:\$HOME/.pub-cache/bin"';
}

/// Gets the Windows PowerShell profile path
String _getWindowsPath() {
  final powerShellProfile = Platform.environment['PROFILE'] ??
      '${Platform.environment['USERPROFILE']}\\Documents\\WindowsPowerShell\\Microsoft.PowerShell_profile.ps1';

  if (File(powerShellProfile).existsSync()) return powerShellProfile;
  return '${Platform.environment['USERPROFILE']}\\.bashrc';
}

/// Checks if the PATH is already configured
bool _pathAlreadyExists(String configFile) {
  try {
    final file = File(configFile);
    if (!file.existsSync()) return false;

    final content = file.readAsStringSync();
    return content.contains('.pub-cache/bin');
  } catch (e) {
    return false;
  }
}

// Add service locator creation
void _createServiceLocator() {
  final utilsDir = Directory('lib/core/utils');
  if (!utilsDir.existsSync()) {
    utilsDir.createSync(recursive: true);
  }
  final file = File('${utilsDir.path}/service_locator.dart');
  if (!file.existsSync()) {
    writeServiceLocatorCode(file);
    print('Created service locator: ${file.path} ✓');
  }
}

/// Adds a new use case to an existing feature
///
/// ```dart
/// addUseCaseToFeature('Auth', 'Login');
/// ```
void addUseCaseToFeature(String featureName, String useCaseName) {
  // Validate feature exists
  final featurePath = '${Directory.current.path}/lib/features/$featureName';
  final featureDir = Directory(featurePath);

  if (!featureDir.existsSync()) {
    print('❌ Error: Feature "$featureName" does not exist.');
    print(
        'Please create the feature first using: feature_generator create --name $featureName');
    return;
  }

  // Check if use case already exists
  final useCasePath = '$featurePath/domain/use_cases';
  final useCaseFileName = '${useCaseName.toLowerCase()}_use_case.dart';
  final useCaseFile = File('$useCasePath/$useCaseFileName');

  if (useCaseFile.existsSync()) {
    print(
        '❌ Error: Use case "$useCaseName" already exists in feature "$featureName".');
    return;
  }

  // Create the use case directory if it doesn't exist
  final useCaseDir = Directory(useCasePath);
  if (!useCaseDir.existsSync()) {
    useCaseDir.createSync(recursive: true);
    print('Created directory: $useCasePath ✓');
  }

  // Create individual files for the use case
  _createUseCaseDataSource(featureName, useCaseName);
  _createUseCaseRepository(featureName, useCaseName);
  _createUseCaseDomainRepository(featureName, useCaseName);
  _createUseCaseFile(featureName, useCaseName);

  // Create empty data model
  _createEmptyDataModel(featureName, useCaseName);

  print(
      '✅ Successfully added use case "$useCaseName" to feature "$featureName"');
  print('📝 Don\'t forget to:');
  print('   1. Implement the actual logic in the repository and data source');
  print('   2. Add the model class properties if needed');
  print(
      '   3. Run: flutter pub run build_runner build --delete-conflicting-outputs');
}

/// Creates an empty data model file for the use case
void _createEmptyDataModel(String featureName, String useCaseName) {
  final modelPath =
      '${Directory.current.path}/lib/features/$featureName/data/models';
  final modelDir = Directory(modelPath);

  if (!modelDir.existsSync()) {
    modelDir.createSync(recursive: true);
    print('Created directory: $modelPath ✓');
  }

  final modelFileName =
      '${useCaseName.toLowerCase()}_${featureName.toLowerCase()}_model.dart';
  final modelFile = File('$modelPath/$modelFileName');

  if (modelFile.existsSync()) {
    print('⚠️  Model already exists: ${modelFile.path}');
    return;
  }

  modelFile.createSync();
  writeEmptyModelCode(modelFile, featureName, useCaseName);
  print('Created empty model: ${modelFile.path} ✓');
}

/// Creates or reuses the data source file for the feature
void _createUseCaseDataSource(String featureName, String useCaseName) {
  final dataSourcePath =
      '${Directory.current.path}/lib/features/$featureName/data/data_sources';
  final dataSourceFile =
      File('$dataSourcePath/${featureName.toLowerCase()}_data_source.dart');

  if (dataSourceFile.existsSync()) {
    print('Data source file already exists: ${dataSourceFile.path}');
    return;
  }

  dataSourceFile.createSync();
  writeDataSourceCode(dataSourceFile, featureName, useCaseName);
  print('Created data source file: ${dataSourceFile.path} ✓');
}

/// Creates or reuses the repository implementation file
void _createUseCaseRepository(String featureName, String useCaseName) {
  final repoPath =
      '${Directory.current.path}/lib/features/$featureName/data/repo';
  final repoFile = File('$repoPath/${featureName.toLowerCase()}_repo.dart');

  if (repoFile.existsSync()) {
    print('Repository file already exists: ${repoFile.path}');
    return;
  }

  repoFile.createSync();
  writeRepositoryCode(repoFile, featureName, useCaseName);
  print('Created repository file: ${repoFile.path} ✓');
}

/// Creates or reuses the domain repository interface
void _createUseCaseDomainRepository(String featureName, String useCaseName) {
  final domainRepoPath =
      '${Directory.current.path}/lib/features/$featureName/domain/repositories';
  final domainRepoFile =
      File('$domainRepoPath/${featureName.toLowerCase()}_repository.dart');

  if (domainRepoFile.existsSync()) {
    print('Domain repository file already exists: ${domainRepoFile.path}');
    return;
  }

  domainRepoFile.createSync();
  writeDomainRepositoryCode(domainRepoFile, featureName, useCaseName);
  print('Created domain repository file: ${domainRepoFile.path} ✓');
}

/// Creates the use case file
void _createUseCaseFile(String featureName, String useCaseName) {
  final useCasePath =
      '${Directory.current.path}/lib/features/$featureName/domain/use_cases';
  final useCaseFileName = '${useCaseName.toLowerCase()}_use_case.dart';
  final useCaseFile = File('$useCasePath/$useCaseFileName');

  if (useCaseFile.existsSync()) {
    print('Use case file already exists: ${useCaseFile.path}');
    return;
  }

  useCaseFile.createSync();
  writeUseCaseCodeWithoutEntity(useCaseFile, featureName, useCaseName);
  print('Created use case file: ${useCaseFile.path} ✓');
}
