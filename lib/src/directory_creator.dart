// Copyright (c) 2024 MOHAMED ATEF. 
// Licensed under the MIT License.

// ignore_for_file: avoid_print

import 'dart:io';

void createFeatureStructure(String featureName) { 
   if (featureName.isEmpty) {
    print('Please provide a feature name as an argument.');
    return;
  }

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
}

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

// Function to write initial code to the cubit file
void writeCubitCode(File file, String name) {
  final String initialCode = '''
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '/Core/Errors/failure.dart';
import '/Core/Extensions/toast.dart';

part '${name.toLowerCase()}_state.dart';

@injectable
class ${name.capitalize()}Cubit extends Cubit<${name.capitalize()}State> {
  ${name.capitalize()}Cubit(this.fetch${name.capitalize()}UseCase) : super(${name.capitalize()}State());

  final Fetch${name.capitalize()}UseCase fetch${name.capitalize()}UseCase;
  late ${name.capitalize()}Model ${name.toLowerCase()}Model = ${name.capitalize()}Model.fromJson({});

  Future<void> fetch${name.capitalize()}Data(BuildContext ctx) async {
    emit(${name.capitalize()}StateStart ());
    Either<Failure, ${name.capitalize()}Model> result = await fetch${name.capitalize()}UseCase.call();
    result.fold(
      (l) {
        ctx.customToast(l.message);
        emit(${name.capitalize()}StateFailed(message: l.message));
      },
      (request) {
        ${name.toLowerCase()}Model = request;
        if (${name.toLowerCase()}Model.status == 200) {
          emit(${name.capitalize()}StateSuccess(${name.toLowerCase()}Model: ${name.toLowerCase()}Model));
        } else {
          emit(${name.capitalize()}StateFailed(message: ${name.toLowerCase()}Model.message));
        }
      },
    );
  }
}
''';

  // Write the initial code to the file
  file.writeAsStringSync(initialCode);
}

// Function to write initial code to the Dart file based on its name
void writeInitialCode(File file, String fileName, String name) {
  String initialCode = ''; // Default value to avoid uninitialized error

  // Determine the initial code based on the file name
  if (fileName.contains('datasources')) {
    initialCode = '''
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '/Core/API/api_endpoints.dart';
import '/Core/API/api_headers.dart';
import '/Core/API/api_helper.dart';

abstract class ${fileName.split('_').first.capitalize()}RemoteDataSource {
  Future<${fileName.split('_').first.capitalize()}Model> get${fileName.split('_').first.capitalize()}();
}

@Singleton(as: ${fileName.split('_').first.capitalize()}RemoteDataSource)
class ${fileName.split('_').first.capitalize()}RemoteDataSourceImplementation extends ${fileName.split('_').first.capitalize()}RemoteDataSource {
  late ${fileName.split('_').first.capitalize()}Model ${fileName.split('_').first}Model;
  late Response response;
  final DioHelper dioHelper ;
  ${fileName.split('_').first.capitalize()}RemoteDataSourceImplementation({required this.dioHelper});

  @override
  Future<${fileName.split('_').first.capitalize()}Model> get${fileName.split('_').first.capitalize()}() async {
    response = await dioHelper.getData(ApisEndPoints.kGet${fileName.split('_').first.capitalize()}DataUrl,
        headers: headersMapWithToken());
    ${fileName.split('_').first}Model = ${fileName.split('_').first.capitalize()}Model.fromJson(response.data ?? {});
    return ${fileName.split('_').first}Model;
  }
}
''';
  } else if (fileName.contains('models')) {
    initialCode = '';
  } else if (file.path.contains('Data') && fileName.contains('repo')) {
    initialCode = '''
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '/Core/Errors/failure.dart';

@Singleton(as: ${fileName.split('_').first.capitalize()}Repository)
class ${fileName.split('_').first.capitalize()}RepoImpl extends ${fileName.split('_').first.capitalize()}Repository {
  final ${fileName.split('_').first.capitalize()}RemoteDataSource remoteDataSource;

  ${fileName.split('_').first.capitalize()}RepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ${fileName.split('_').first.capitalize()}Model>> get${fileName.split('_').first.capitalize()}() async {
    try {
      ${fileName.split('_').first.capitalize()}Model request = await remoteDataSource.get${fileName.split('_').first.capitalize()}();
      return right(request);
    } on Exception catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioException(e));
      } else {
        return left(ServerFailure(message: e.toString()));
      }
    }
  }
}
''';
  } else if (file.path.contains('Domain/Repositories')) {
    initialCode = '''
import 'package:dartz/dartz.dart';
import '/Core/Errors/failure.dart';

abstract class ${fileName.split('_').first.capitalize()}Repository {
  Future<Either<Failure, ${fileName.split('_').first.capitalize()}Model>> get${fileName.split('_').first.capitalize()}();
}
''';
  } else if (fileName.contains('usecases')) {
    initialCode = '''
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '/Core/Errors/failure.dart';
import '/Core/UseCase/use_case.dart';

@lazySingleton
class Fetch${fileName.split('_').first.capitalize()}UseCase extends UseCases<${fileName.split('_').first.capitalize()}Model> {
  final ${fileName.split('_').first.capitalize()}Repository ${fileName.split('_').first}Repository;

  Fetch${fileName.split('_').first.capitalize()}UseCase({required this.${fileName.split('_').first}Repository});
  @override
  Future<Either<Failure, ${fileName.split('_').first.capitalize()}Model>> call() async {
    return await ${fileName.split('_').first}Repository.get${fileName.split('_').first.capitalize()}();
  }
}
''';
  } else if (fileName.contains('views')) {
    initialCode = '''
import 'package:flutter/material.dart';

class ${fileName.split('_').first.capitalize()}Screen extends StatelessWidget {
  static const String route = '/${fileName.split('_').first.capitalize()}Screen';
  const ${fileName.split('_').first.capitalize()}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(); 
  }
}
''';
  } else if (fileName.contains('widgets')) {
    initialCode = '''
import 'package:flutter/material.dart';

class ${fileName.split('_').first.capitalize()}Widget extends StatelessWidget {
  const ${fileName.split('_').first.capitalize()}Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(); 
  }
}
''';
  } else {
    initialCode = '// TODO: Implement $fileName functionality';
  }

  // Write the initial code to the file
  file.writeAsStringSync(initialCode);
}

// Function to write initial code to the state file
void writeStateCode(File file, String name) {
  final String initialCode = '''
part of '${name.toLowerCase()}_cubit.dart';

class ${name.capitalize()}State {}

final class ${name.capitalize()}StateInitial extends ${name.capitalize()}State {}

final class ${name.capitalize()}StateStart extends ${name.capitalize()}State {}

final class ${name.capitalize()}StateSuccess extends ${name.capitalize()}State {
  final ${name.capitalize()}Model ${name.toLowerCase()}Model;
  ${name.capitalize()}StateSuccess({required this.${name.toLowerCase()}Model});
}

final class ${name.capitalize()}StateFailed extends ${name.capitalize()}State {
  final String message;
  ${name.capitalize()}StateFailed({required this.message});
}
''';

  // Write the initial code to the file
  file.writeAsStringSync(initialCode);
}

// Extension method to capitalize the first letter of a string
extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
