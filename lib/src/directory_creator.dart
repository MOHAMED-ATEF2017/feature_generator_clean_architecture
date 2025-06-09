// Copyright (c) 2025 MOHAMED ATEF.
// Licensed under the MIT License.

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:feature_generator/src/code_writers.dart';
import 'package:feature_generator/src/extensions.dart';

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
        _createUseCaseFile(directory);
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

  // Create the use case file
  useCaseFile.createSync();
  writeUseCaseCode(useCaseFile, featureName, useCaseName);
  print('Created use case: ${useCaseFile.path} ✓');

  // Create domain entity
  _createDomainEntity(featureName, useCaseName);

  // Create data model
  _createDataModel(featureName, useCaseName);

  // Update the repository interface to include the new method
  _updateRepositoryInterface(featureName, useCaseName);

  // Update the repository implementation to include the new method
  _updateRepositoryImplementation(featureName, useCaseName);

  // Update the data source interface and implementation
  _updateDataSource(featureName, useCaseName);

  print(
      '✅ Successfully added use case "$useCaseName" to feature "$featureName"');
  print('📝 Don\'t forget to:');
  print('   1. Implement the actual logic in the repository and data source');
  print('   2. Add the model class if needed');
  print(
      '   3. Run: flutter pub run build_runner build --delete-conflicting-outputs');
}

/// Updates the repository interface to include the new use case method
void _updateRepositoryInterface(String featureName, String useCaseName) {
  final repositoryPath =
      '${Directory.current.path}/lib/features/$featureName/domain/repositories';
  final repositoryFileName = '${featureName.toLowerCase()}_repository.dart';
  final repositoryFile = File('$repositoryPath/$repositoryFileName');

  if (!repositoryFile.existsSync()) {
    print('⚠️  Warning: Repository interface not found, skipping update');
    return;
  }

  final content = repositoryFile.readAsStringSync();
  final methodName = useCaseName.toLowerCase();
  final newMethod =
      '  Future<Either<Failure, ${useCaseName.capitalize()}${featureName.capitalize()}Entity>> $methodName();';

  // Add the new method before the closing brace
  final updatedContent = content.replaceFirst(
    RegExp(r'}\s*$'),
    '$newMethod\n}',
  );

  repositoryFile.writeAsStringSync(updatedContent);
  print('Updated repository interface: ${repositoryFile.path} ✓');
}

/// Updates the repository implementation to include the new use case method
void _updateRepositoryImplementation(String featureName, String useCaseName) {
  final repoPath =
      '${Directory.current.path}/lib/features/$featureName/data/repo';
  final repoFileName = '${featureName.toLowerCase()}_repo.dart';
  final repoFile = File('$repoPath/$repoFileName');

  if (!repoFile.existsSync()) {
    print('⚠️  Warning: Repository implementation not found, skipping update');
    return;
  }

  final content = repoFile.readAsStringSync();
  final methodName = useCaseName.toLowerCase();
  final capitalizedFeature = featureName.capitalize();

  final newMethod = '''
  
  @override
  Future<Either<Failure, ${useCaseName.capitalize()}${capitalizedFeature}Entity>> $methodName() async {
    try {
      ${useCaseName.capitalize()}${capitalizedFeature}Model request = await remoteDataSource.$methodName();
      return right(request);
    } on Exception catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioException(e));
      } else {
        return left(ServerFailure(message: e.toString()));
      }
    }
  }''';

  // Add the new method before the closing brace
  final updatedContent = content.replaceFirst(
    RegExp(r'}\s*$'),
    '$newMethod\n}',
  );

  repoFile.writeAsStringSync(updatedContent);
  print('Updated repository implementation: ${repoFile.path} ✓');
}

/// Updates the data source interface and implementation
void _updateDataSource(String featureName, String useCaseName) {
  final dataSourcePath =
      '${Directory.current.path}/lib/features/$featureName/data/data_sources';
  final dataSourceFileName = '${featureName.toLowerCase()}_data_source.dart';
  final dataSourceFile = File('$dataSourcePath/$dataSourceFileName');

  if (!dataSourceFile.existsSync()) {
    print('⚠️  Warning: Data source not found, skipping update');
    return;
  }

  final content = dataSourceFile.readAsStringSync();
  final methodName = useCaseName.toLowerCase();
  final capitalizedFeature = featureName.capitalize();

  // Add method to abstract class
  final abstractMethod =
      '  Future<${useCaseName.capitalize()}${capitalizedFeature}Model> $methodName();';
  final abstractUpdatedContent = content.replaceFirst(
    RegExp(r'(?=}\s*@Singleton)'),
    '$abstractMethod\n',
  );

  // Add method to implementation class
  final implementationMethod = '''
  
  @override
  Future<${useCaseName.capitalize()}${capitalizedFeature}Model> $methodName() async {
    response = await dioHelper.getData(ApisEndPoints.k$capitalizedFeature${useCaseName.capitalize()}Url,
        headers: headersMapWithToken());
    ${useCaseName.toLowerCase()}${featureName.capitalize()}Model = ${useCaseName.capitalize()}${capitalizedFeature}Model.fromJson(response.data ?? {});
    return ${useCaseName.toLowerCase()}${featureName.capitalize()}Model;
  }''';

  final finalContent = abstractUpdatedContent.replaceFirst(
    RegExp(r'}\s*$'),
    '$implementationMethod\n}',
  );

  dataSourceFile.writeAsStringSync(finalContent);
  print('Updated data source: ${dataSourceFile.path} ✓');
}

/// Creates a domain entity file for the use case
void _createDomainEntity(String featureName, String useCaseName) {
  final entityPath =
      '${Directory.current.path}/lib/features/$featureName/domain/entities';
  final entityDir = Directory(entityPath);

  if (!entityDir.existsSync()) {
    entityDir.createSync(recursive: true);
    print('Created directory: $entityPath ✓');
  }

  final entityFileName =
      '${useCaseName.toLowerCase()}_${featureName.toLowerCase()}_entity.dart';
  final entityFile = File('$entityPath/$entityFileName');

  if (entityFile.existsSync()) {
    print('⚠️  Entity already exists: ${entityFile.path}');
    return;
  }

  entityFile.createSync();
  writeEntityCode(entityFile, featureName, useCaseName);
  print('Created entity: ${entityFile.path} ✓');
}

/// Creates a data model file for the use case
void _createDataModel(String featureName, String useCaseName) {
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
  writeModelCode(modelFile, featureName, useCaseName);
  print('Created model: ${modelFile.path} ✓');
}
