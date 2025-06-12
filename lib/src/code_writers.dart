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

/// Writes Use Case code for a specific feature and use case name
///
/// ```dart
/// writeUseCaseCode(file, 'Auth', 'Login');
/// ```
void writeUseCaseCode(File file, String featureName, String useCaseName) {
  final String initialCode = '''
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '/core/errors/failure.dart';
import '/core/use_cases/use_case.dart';
import '../entities/${useCaseName.toLowerCase()}_${featureName.toLowerCase()}_entity.dart';

@lazySingleton
class ${useCaseName.capitalize()}${featureName.capitalize()}UseCase extends UseCases<${useCaseName.capitalize()}${featureName.capitalize()}Entity> {
  final ${featureName.capitalize()}Repository ${featureName.toLowerCase()}Repository;

  ${useCaseName.capitalize()}${featureName.capitalize()}UseCase({required this.${featureName.toLowerCase()}Repository});
  
  @override
  Future<Either<Failure, ${useCaseName.capitalize()}${featureName.capitalize()}Entity>> call() async {
    return await ${featureName.toLowerCase()}Repository.${useCaseName.toLowerCase()}();
  }
}
''';

  // Write the initial code to the file
  file.writeAsStringSync(initialCode);
}

/// Writes Use Case code for a specific feature and use case name (without entity dependency)
///
/// ```dart
/// writeUseCaseCodeWithoutEntity(file, 'Auth', 'Login');
/// ```
void writeUseCaseCodeWithoutEntity(
    File file, String featureName, String useCaseName) {
  final String initialCode = '''
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '/core/errors/failure.dart';
import '/core/use_cases/use_case.dart';
import '../repositories/${featureName.toLowerCase()}_repository.dart';
import '../../data/models/${useCaseName.toLowerCase()}_${featureName.toLowerCase()}_model.dart';

@lazySingleton
class ${useCaseName.capitalize()}${featureName.capitalize()}UseCase extends UseCases<${useCaseName.capitalize()}${featureName.capitalize()}Model> {
  final ${featureName.capitalize()}Repository ${featureName.toLowerCase()}Repository;

  ${useCaseName.capitalize()}${featureName.capitalize()}UseCase({required this.${featureName.toLowerCase()}Repository});
  
  @override
  Future<Either<Failure, ${useCaseName.capitalize()}${featureName.capitalize()}Model>> call() async {
    return await ${featureName.toLowerCase()}Repository.${useCaseName.toLowerCase()}();
  }
}
''';

  // Write the initial code to the file
  file.writeAsStringSync(initialCode);
}

/// Writes Domain Entity code for a specific feature and use case name
///
/// ```dart
/// writeEntityCode(file, 'Auth', 'Login');
/// ```
void writeEntityCode(File file, String featureName, String useCaseName) {
  final String initialCode = '''
/// Domain entity for ${useCaseName.capitalize()} ${featureName.capitalize()}
/// 
/// Represents the business object structure
class ${useCaseName.capitalize()}${featureName.capitalize()}Entity {
  final int? id;
  final String? message;
  final bool? success;
  final dynamic data;

  const ${useCaseName.capitalize()}${featureName.capitalize()}Entity({
    this.id,
    this.message,
    this.success,
    this.data,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ${useCaseName.capitalize()}${featureName.capitalize()}Entity &&
        other.id == id &&
        other.message == message &&
        other.success == success &&
        other.data == data;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        message.hashCode ^
        success.hashCode ^
        data.hashCode;
  }

  @override
  String toString() {
    return '${useCaseName.capitalize()}${featureName.capitalize()}Entity(id: \$id, message: \$message, success: \$success, data: \$data)';
  }
}
''';

  file.writeAsStringSync(initialCode);
}

/// Writes Data Model code for a specific feature and use case name
///
/// ```dart
/// writeModelCode(file, 'Auth', 'Login');
/// ```
void writeModelCode(File file, String featureName, String useCaseName) {
  final String initialCode = '''
import '../../../domain/entities/${useCaseName.toLowerCase()}_${featureName.toLowerCase()}_entity.dart';

/// Data model for ${useCaseName.capitalize()} ${featureName.capitalize()}
/// 
/// Implements the domain entity with JSON serialization
class ${useCaseName.capitalize()}${featureName.capitalize()}Model extends ${useCaseName.capitalize()}${featureName.capitalize()}Entity {
  const ${useCaseName.capitalize()}${featureName.capitalize()}Model({
    super.id,
    super.message,
    super.success,
    super.data,
  });

  /// Creates a model from JSON
  factory ${useCaseName.capitalize()}${featureName.capitalize()}Model.fromJson(Map<String, dynamic> json) {
    return ${useCaseName.capitalize()}${featureName.capitalize()}Model(
      id: json['id'] as int?,
      message: json['message'] as String?,
      success: json['success'] as bool?,
      data: json['data'],
    );
  }

  /// Converts the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'success': success,
      'data': data,
    };
  }

  /// Creates a copy with updated fields
  ${useCaseName.capitalize()}${featureName.capitalize()}Model copyWith({
    int? id,
    String? message,
    bool? success,
    dynamic data,
  }) {
    return ${useCaseName.capitalize()}${featureName.capitalize()}Model(
      id: id ?? this.id,
      message: message ?? this.message,
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return '${useCaseName.capitalize()}${featureName.capitalize()}Model(id: \$id, message: \$message, success: \$success, data: \$data)';
  }
}
''';

  file.writeAsStringSync(initialCode);
}

/// Writes Empty Data Model code for a specific feature and use case name (without entity dependency)
///
/// ```dart
/// writeEmptyModelCode(file, 'Auth', 'Login');
/// ```
void writeEmptyModelCode(File file, String featureName, String useCaseName) {
  final String initialCode = '''
/// Data model for ${useCaseName.capitalize()} ${featureName.capitalize()}
/// 
/// Standalone model with JSON serialization (no entity dependency)
class ${useCaseName.capitalize()}${featureName.capitalize()}Model {
  final int? id;
  final String? message;
  final bool? success;
  final dynamic data;

  const ${useCaseName.capitalize()}${featureName.capitalize()}Model({
    this.id,
    this.message,
    this.success,
    this.data,
  });

  /// Creates a model from JSON
  factory ${useCaseName.capitalize()}${featureName.capitalize()}Model.fromJson(Map<String, dynamic> json) {
    return ${useCaseName.capitalize()}${featureName.capitalize()}Model(
      id: json['id'] as int?,
      message: json['message'] as String?,
      success: json['success'] as bool?,
      data: json['data'],
    );
  }

  /// Converts the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'success': success,
      'data': data,
    };
  }

  /// Creates a copy with updated fields
  ${useCaseName.capitalize()}${featureName.capitalize()}Model copyWith({
    int? id,
    String? message,
    bool? success,
    dynamic data,
  }) {
    return ${useCaseName.capitalize()}${featureName.capitalize()}Model(
      id: id ?? this.id,
      message: message ?? this.message,
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ${useCaseName.capitalize()}${featureName.capitalize()}Model &&
        other.id == id &&
        other.message == message &&
        other.success == success &&
        other.data == data;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        message.hashCode ^
        success.hashCode ^
        data.hashCode;
  }

  @override
  String toString() {
    return '${useCaseName.capitalize()}${featureName.capitalize()}Model(id: \$id, message: \$message, success: \$success, data: \$data)';
  }
}
''';

  file.writeAsStringSync(initialCode);
}

/// Writes Data Source code for a specific use case
///
/// ```dart
/// writeDataSourceCode(file, 'Auth', 'Login');
/// ```
void writeDataSourceCode(File file, String featureName, String useCaseName) {
  final String initialCode = '''
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
//TODO: Importing the write endpoints
// import '/core/api_helper/api_endpoints.dart';
// import '/core/api_helper/api_headers.dart';
// import '/core/api_helper/api_helper.dart';

abstract class ${featureName.capitalize()}RemoteDataSource {
  Future<${featureName.capitalize()}Model> get${featureName.capitalize()}();
}

@Singleton(as: ${featureName.capitalize()}RemoteDataSource)
class ${featureName.capitalize()}RemoteDataSourceImplementation extends ${featureName.capitalize()}RemoteDataSource {
  late ${featureName.capitalize()}Model ${featureName.toLowerCase()}Model;
  late Response response;
  final DioHelper dioHelper ;
  ${featureName.capitalize()}RemoteDataSourceImplementation({required this.dioHelper});

  @override
  Future<${featureName.capitalize()}Model> get${featureName.capitalize()}() async {
    response = await dioHelper.getData(ApisEndPoints.kGet${featureName.capitalize()}DataUrl,
        headers: headersMapWithToken());
    ${featureName.toLowerCase()}Model = ${featureName.capitalize()}Model.fromJson(response.data ?? {});
    return ${featureName.toLowerCase()}Model;
  }
}
''';

  file.writeAsStringSync(initialCode);
}

/// Writes Repository Implementation code for a specific use case
///
/// ```dart
/// writeRepositoryCode(file, 'Auth', 'Login');
/// ```
void writeRepositoryCode(File file, String featureName, String useCaseName) {
  final String initialCode = '''
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '/core/errors/failure.dart';

@Singleton(as: ${featureName.capitalize()}Repository)
class ${featureName.capitalize()}RepoImpl extends ${featureName.capitalize()}Repository {
  final ${featureName.capitalize()}RemoteDataSource remoteDataSource;

  ${featureName.capitalize()}RepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ${featureName.capitalize()}Model>> get${featureName.capitalize()}() async {
    try {
      ${featureName.capitalize()}Model request = await remoteDataSource.get${featureName.capitalize()}();
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

  file.writeAsStringSync(initialCode);
}

/// Writes Domain Repository Interface code for a specific use case
///
/// ```dart
/// writeDomainRepositoryCode(file, 'Auth', 'Login');
/// ```
void writeDomainRepositoryCode(
    File file, String featureName, String useCaseName) {
  final String initialCode = '''
import 'package:dartz/dartz.dart';
import '/core/errors/failure.dart';

abstract class ${featureName.capitalize()}Repository {
  Future<Either<Failure, ${featureName.capitalize()}Model>> get${featureName.capitalize()}();
}
''';

  file.writeAsStringSync(initialCode);
}

/// Writes Data Source code specifically for a use case
///
/// ```dart
/// writeUseCaseDataSourceCode(file, 'Fe', 'Login');
/// ```
void writeUseCaseDataSourceCode(
    File file, String featureName, String useCaseName) {
  final String initialCode = '''
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
//TODO: Importing the write endpoints
// import '/core/api_helper/api_endpoints.dart';
// import '/core/api_helper/api_headers.dart';
// import '/core/api_helper/api_helper.dart';

abstract class ${useCaseName.capitalize()}RemoteDataSource {
  Future<${useCaseName.capitalize()}${featureName.capitalize()}Model> ${useCaseName.toLowerCase()}();
}

@Singleton(as: ${useCaseName.capitalize()}RemoteDataSource)
class ${useCaseName.capitalize()}RemoteDataSourceImplementation extends ${useCaseName.capitalize()}RemoteDataSource {
  late ${useCaseName.capitalize()}${featureName.capitalize()}Model ${useCaseName.toLowerCase()}${featureName.capitalize()}Model;
  late Response response;
  final DioHelper dioHelper;
  ${useCaseName.capitalize()}RemoteDataSourceImplementation({required this.dioHelper});

  @override
  Future<${useCaseName.capitalize()}${featureName.capitalize()}Model> ${useCaseName.toLowerCase()}() async {
    response = await dioHelper.getData(ApisEndPoints.k${useCaseName.capitalize()}${featureName.capitalize()}Url,
        headers: headersMapWithToken());
    ${useCaseName.toLowerCase()}${featureName.capitalize()}Model = ${useCaseName.capitalize()}${featureName.capitalize()}Model.fromJson(response.data ?? {});
    return ${useCaseName.toLowerCase()}${featureName.capitalize()}Model;
  }
}
''';

  file.writeAsStringSync(initialCode);
}

/// Writes Repository Implementation code specifically for a use case
///
/// ```dart
/// writeUseCaseRepositoryCode(file, 'Fe', 'Login');
/// ```
void writeUseCaseRepositoryCode(
    File file, String featureName, String useCaseName) {
  final String initialCode = '''
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '/core/errors/failure.dart';
import '../data_sources/${useCaseName.toLowerCase()}_data_source.dart';
import '../../domain/repositories/${useCaseName.toLowerCase()}_repository.dart';
import '../models/${useCaseName.toLowerCase()}_${featureName.toLowerCase()}_model.dart';

@Singleton(as: ${useCaseName.capitalize()}Repository)
class ${useCaseName.capitalize()}RepoImpl extends ${useCaseName.capitalize()}Repository {
  final ${useCaseName.capitalize()}RemoteDataSource remoteDataSource;

  ${useCaseName.capitalize()}RepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ${useCaseName.capitalize()}${featureName.capitalize()}Model>> ${useCaseName.toLowerCase()}() async {
    try {
      ${useCaseName.capitalize()}${featureName.capitalize()}Model request = await remoteDataSource.${useCaseName.toLowerCase()}();
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

  file.writeAsStringSync(initialCode);
}

/// Writes Domain Repository Interface code specifically for a use case
///
/// ```dart
/// writeUseCaseDomainRepositoryCode(file, 'Fe', 'Login');
/// ```
void writeUseCaseDomainRepositoryCode(
    File file, String featureName, String useCaseName) {
  final String initialCode = '''
import 'package:dartz/dartz.dart';
import '/core/errors/failure.dart';
import '../../data/models/${useCaseName.toLowerCase()}_${featureName.toLowerCase()}_model.dart';

abstract class ${useCaseName.capitalize()}Repository {
  Future<Either<Failure, ${useCaseName.capitalize()}${featureName.capitalize()}Model>> ${useCaseName.toLowerCase()}();
}
''';

  file.writeAsStringSync(initialCode);
}
