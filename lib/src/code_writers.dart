// Copyright (c) 2025 MOHAMED ATEF.
// Licensed under the BSD License.
/// {@category Code Generation}
library code_writers;

import 'dart:io';

import 'package:feature_generator/src/extensions.dart';

/// Writes Cubit boilerplate code to a file
///
/// ```dart
/// writeCubitCode(file, 'Auth');
/// ```

//*________________ Function to write initial code to the cubit file __________________*//
void writeCubitCode(File file, String name) {
  final String initialCode = '''
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '/core/errors/failure.dart';

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
        //TODO : write the code which will woek at failed case
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

/// Writes initial boilerplate code to a file
///
/// ```dart
/// writeInitialCode(File file, String fileName, String name);
/// ```

//*_______________ Function to write initial code to the Dart file based on its name _______________*//
void writeInitialCode(File file, String fileName, String name) {
  String initialCode = ''; // Default value to avoid uninitialized error

  // Determine the initial code based on the file name
  if (fileName.contains('data_sources')) {
    initialCode = '''
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
//TODO: Importing the write endpoints
// import '/core/api_helper/api_endpoints.dart';
// import '/core/api_helper/api_headers.dart';
// import '/core/api_helper/api_helper.dart';

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
  } else if (file.path.contains('data') && fileName.contains('repo')) {
    initialCode = '''
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '/core/errors/failure.dart';

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
  } else if (file.path.contains('domain/repositories')) {
    initialCode = '''
import 'package:dartz/dartz.dart';
import '/core/errors/failure.dart';

abstract class ${fileName.split('_').first.capitalize()}Repository {
  Future<Either<Failure, ${fileName.split('_').first.capitalize()}Model>> get${fileName.split('_').first.capitalize()}();
}
''';
  } else if (fileName.contains('use_cases')) {
    initialCode = '''
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '/core/errors/failure.dart';
import '/core/useCase/use_case.dart';

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

/// Writes BLoc states code to a file
///
/// ```dart
/// writeStateCode(file, 'Auth');
/// ```

//*______________ Function to write initial code to the state file ________________*//
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

/// Writes Core Failure code to a file
///
/// ```dart
/// writeCoreFailureCode(file);
/// ```

//*________________ Function to write initial code to failure file __________________*//
void writeCoreFailureCode(File failureFile) {
  failureFile.writeAsStringSync('''
import 'package:dio/dio.dart';

class Failure {
  final String message;

  Failure({required this.message});
}

class ServerFailure extends Failure {
  ServerFailure({required super.message});

  factory ServerFailure.fromBadResponse(Response response) {
    if (response.statusCode == 404) {
      return ServerFailure(
          message: 'Your request was not found, Please try later');
    } else if (response.statusCode == 500) {
      return ServerFailure(
          message: 'There are errors with server, Please try later');
    } else if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 403) {
      return ServerFailure(message: response.statusMessage.toString());
    } else {
      return ServerFailure(message: 'Please try later');
    }
  }
  factory ServerFailure.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure(message: 'Connection timed out');
      case DioExceptionType.sendTimeout:
        return ServerFailure(message: 'Connection send timed out');
      case DioExceptionType.receiveTimeout:
        return ServerFailure(message: 'Connection received timed out');
      case DioExceptionType.badCertificate:
        return ServerFailure(message: 'Bad certification error');
      case DioExceptionType.badResponse:
        return ServerFailure.fromBadResponse(e.response!);
      case DioExceptionType.cancel:
        return ServerFailure(message: 'Connection canceled');
      case DioExceptionType.connectionError:
        return ServerFailure(message: 'Connection Error');
      case DioExceptionType.unknown:
        return ServerFailure(message: 'Unknown Error');
    }
  }
}
''');
}

/// Writes Core Use Case code to a file
///
/// ```dart
/// writeCoreUseCaseCode(file, 'Auth');
/// ```

//*________________ Function to write initial code to failure file __________________*//
void writeCoreUseCaseCode(File useCaseFile) {
  useCaseFile.writeAsStringSync('''
import 'package:dartz/dartz.dart';
import '../errors/failure.dart';

abstract class UseCases<Type> {
  Future<Either<Failure, Type>> call();
}

abstract class UseCasesWithParamater<Type, Parameter> {
  Future<Either<Failure, Type>> call(Parameter parameter);
}
''');
}

/// Writes Core utilization Helper code to a file
///
/// ```dart
/// writeServiceLocatorCode(File file);
/// ```
//*________________ Function to write initial code to service locator file __________________*//
void writeServiceLocatorCode(File file) {
  file.writeAsStringSync('''
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
// run the command: flutter pub run build_runner build 
// to generate the service locator
// and the injectable config file
import 'service_locator.config.dart';
final getIt = GetIt.instance;

@InjectableInit()

// call this function in main.dart
void configureDependencies() => getIt.init();
''');
}
