# Feature Generator 🛠️

[![Pub Version](https://img.shields.io/pub/v/feature_generator)](https://pub.dev/packages/feature_generator)
[![Build Status](https://img.shields.io/github/actions/workflow/status/MOHAMED-ATEF2017/feature_generator/dart.yml)](https://github.com/MOHAMED-ATEF2017/feature_generator/actions)
[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://pub.dev/packages/feature_generator/license)

A command-line interface (CLI) tool that accelerates Flutter development by generating Clean Architecture folder structures with boilerplate code for BLoC/Cubit state management.

# Table of Contents 📑
- [Installation](#installation-)
- [Usage](#usage-)
- [Generated Structure](#generated-structure-)
- [Example](#example-)
- [Dependencies](#dependencies-)
- [Configuration](#configuration-)
- [Troubleshooting](#troubleshooting-)
- [Contributing](#contributing-)
- [License](#license-)

# Installation 💻

Install globally using Dart:
### 1. From pub.dev [pub.dev](https://pub.dev/packages/feature_generator)
Import the package:
``` bash
flutter pub get feature_generator
```
Then, to add the package to PATH

```bash
 dart pub global activate feature_generator && dart pub global run feature_generator:_post_install
 ```
 <!-- Add to PATH:
 ```bash
 # For Bash/Zsh
    export PATH="$PATH:$HOME/.pub-cache/bin"

# For PowerShell
    $env:Path += ";$env:USERPROFILE\.pub-cache\bin" -->
<!-- ``` -->
### Key Features:
#### 1- Automatic Shell Detection
Supports Bash, Zsh, and Fish.

#### 2- Permanent PATH Configuration
Appends to the appropriate shell config file.
# Usage 🚀
## 1. Initialize Project

At first , run this command to install dependacies and core folder:
``` bash
feature_generator install
```
This creates:

Core directories (`lib/core/errors`, `lib/core/use_cases`)

Service locator (`lib/core/utils/service_locator.dart`)

Installs required dependencies

## 2. Generate Features
``` bash
feature_generator create --name <FEATURE_NAME>
```

## 3. Add Use Cases to Existing Features
``` bash
feature_generator add-usecase --feature <FEATURE_NAME> --usecase <USECASE_NAME>
```

## Examples:

For create `Auth` feature 
``` bash
feature_generator create --name Auth
```

For adding a `Login` use case to the `Auth` feature:
``` bash
feature_generator add-usecase --feature Auth --usecase Login
```

For adding a `Logout` use case to the `Auth` feature:
``` bash
feature_generator add-usecase --feature Auth --usecase Logout
```
The core folders (`lib/core/errors` and `lib/core/use_cases`) will only exist after running the `install` command, never during feature creation.
# Generated Structure 🌳
```
├── core/ # Shared project components
│ ├── errors/ # Custom error classes
│ │    └── failure.dart # Failure type definitions
│ ├── use_cases/ # Base use case classes
│ │    └── use_case.dart # Abstract UseCase template
│ └── utils/ # Create getit initialize
│      └── use_case.dart # Get it Definition
│
└── features/ # Feature modules
    └── <feature_name>/ # Generated feature name
        ├── data/
        │ ├── data_sources/ # API/Remote data sources
        │ ├── models/ # Data model classes
        │ └── repo/ # Repository implementations
        │
        ├── domain/
        │ ├── repositories/ # Abstract repository contracts
        │ └── use_cases/ # Business logic components
        │
        └── presentation/
          ├── controller/ # BLoC/Cubit + State classes
          └── views/
              ├── screens/ # Full page views
              └── widgets/ # Reusable components
 ```        
The `lib/` directory is divided into two main sections: shared utilities (`core/`) and feature-specific modules (`features/`). Below is a breakdown of the structure in a tabular format:

| Directory Path                     | Purpose                                      |
|------------------------------------|----------------------------------------------|
| `core/errors/failure.dart`         | Defines custom error types for the app.      |
| `core/use_cases/use_case.dart`     | Abstract template for use case classes.      |
| `features/<feature_name>/data/data_sources/` | Handles API or remote data interactions.     |
| `features/<feature_name>/data/models/`      | Contains data model classes for serialization. |
| `features/<feature_name>/data/repo/`        | Implements data repository logic.            |
| `features/<feature_name>/domain/repositories/` | Defines abstract repository interfaces.      |
| `features/<feature_name>/domain/use_cases/`     | Encapsulates business logic for the feature. |
| `features/<feature_name>/presentation/controller/` | Manages state using BLoC or Cubit.          |
| `features/<feature_name>/presentation/views/screens/` | Full-page UI views for the feature.         |
| `features/<feature_name>/presentation/views/widgets/` | Reusable UI components.


Key additions:
1. Core directory structure shown at project root level
2. Explicit paths for critical base files
3. Clear separation between shared core components and feature modules

The core directory will be generated once during the first feature creation. Subsequent features will reuse these core components.

## Core Components 🔨

### Failure Class (`lib/core/errors/failure.dart`)
```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

```
# Example Code 🧑💻

## 1. Cubit File (`lib/feature/auth/presentation/controller/user_profile_cubit.dart`):
```dart
@injectable
class UserProfileCubit extends Cubit<UserProfileState> {
  final FetchUserProfileUseCase fetchUserProfileUseCase;
  
  UserProfileCubit(this.fetchUserProfileUseCase) 
    : super(UserProfileInitial());

  Future<void> loadProfile() async {
    emit(UserProfileLoading());
    // ... cubit logic
  }

```
## 2. Repository Contract (`user_profile_repository.dart`):
```dart
abstract class UserProfileRepository {
  Future<Either<Failure, UserProfileModel>> getProfile();
}
```
## 3. UseCase Template (`lib/core/use_cases/use_case.dart`):
```dart
import 'package:dartz/dartz.dart';
import '../Errors/failure.dart';

abstract class UseCases<Type> {
  Future<Either<Failure, Type>> call();
}

abstract class UseCasesWithParamater<Type, Parameter> {
  Future<Either<Failure, Type>> call(Parameter parameter);
}
```
## 4. Service Locator (`lib/core/util/service_locator.dart`)
```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();
```
## 5. Failure (`lib/core/errors/failure.dart`) :
```dart
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
```
## 6. Data Source (`lib/featurs/*FeatureName*/data/data_sources/*featurename*_data_source.dart `):
```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '/core/api_helper/api_endpoints.dart';
import '/core/api_helper/api_headers.dart';
import '/core/api_helper/api_helper.dart';

abstract class FeatureNameRemoteDataSource {
  Future<FeatureNameModel> getFeatureName();
}

@Singleton(as: FeatureNameRemoteDataSource)
class FeatureNameRemoteDataSourceImplementation extends FeatureNameRemoteDataSource {
  late FeatureNameModel FeatureNameModel;
  late Response response;
  final DioHelper dioHelper ;
  FeatureNameRemoteDataSourceImplementation({required this.dioHelper});

  @override
  Future<FeatureNameModel> getFeatureName() async {
    response = await dioHelper.getData(ApisEndPoints.kGetFeatureNameDataUrl,
        headers: headersMapWithToken());
    FeatureNameModel = FeatureNameModel.fromJson(response.data ?? {});
    return FeatureNameModel;
  }
}
```
## 7. Data RepoRepository (`lib/featurs/*FeatureName*/data/repo/*featurename*_repo.dart`):
```dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '/Core/Errors/failure.dart';

@Singleton(as: FEATURENAMERepository)
class FEATURENAMERepoImpl extends FEATURENAMERepository {
  final FEATURENAMERemoteDataSource remoteDataSource;

  FEATURENAMERepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, FEATURENAMEModel>> getFEATURENAME() async {
    try {
      FEATURENAMEModel request = await remoteDataSource.getFEATURENAME();
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
```
## 8. Domain Repository (`lib/featurs/*FeatureName*/domain/repositories/*featurename*_repository.dart`):
```dart
import 'package:dartz/dartz.dart';
import '/Core/Errors/failure.dart';

abstract class FEATURENAMERepository {
  Future<Either<Failure, FEATURENAMEModel>> getFEATURENAME();
}
```
## 9. Domain UseCases (`lib/featurs/*FeatureName*/domain/use_cases/*featurename*_use_case_.dart`):
```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '/Core/Errors/failure.dart';
import '/Core/UseCase/use_case.dart';

@lazySingleton
class FetchFEATURENAMEUseCase extends UseCases<FEATURENAMEModel> {
  final FEATURENAMERepository FEATURENAMERepository;

  FetchFEATURENAMEUseCase({required this.FEATURENAMERepository});
  @override
  Future<Either<Failure, FEATURENAMEModel>> call() async {
    return await FEATURENAMERepository.getFEATURENAME();
  }
}
```

# Adding Use Cases to Existing Features 🔧

You can add additional use cases to an existing feature without recreating the entire feature structure. This is useful when you want to extend a feature with new business logic.

## Command Usage
```bash
feature_generator add-usecase --feature <FEATURE_NAME> --usecase <USECASE_NAME>
```

## Example: Adding Multiple Use Cases to Auth Feature

```bash
# Create the Auth feature first
feature_generator create --name Auth

# Add Login use case
feature_generator add-usecase --feature Auth --usecase Login

# Add Logout use case  
feature_generator add-usecase --feature Auth --usecase Logout

# Add ResetPassword use case
feature_generator add-usecase --feature Auth --usecase ResetPassword
```

## What Gets Generated

When you add a use case, the tool automatically:

1. **Creates the use case file** - `lib/features/auth/domain/use_cases/login_use_case.dart`
2. **Creates the domain entity** - `lib/features/auth/domain/entities/login_auth_entity.dart`
3. **Creates the data model** - `lib/features/auth/data/models/login_auth_model.dart`
4. **Updates the repository interface** - Adds the new method to the abstract repository
5. **Updates the repository implementation** - Adds the implementation in the data layer
6. **Updates the data source** - Adds the method to both interface and implementation

## Generated Files Example

For `feature_generator add-usecase --feature Auth --usecase Login`:

**login_use_case.dart**
```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '/core/errors/failure.dart';
import '/core/use_cases/use_case.dart';
import '../entities/login_auth_entity.dart';

@lazySingleton
class LoginAuthUseCase extends UseCases<LoginAuthEntity> {
  final AuthRepository authRepository;

  LoginAuthUseCase({required this.authRepository});
  
  @override
  Future<Either<Failure, LoginAuthEntity>> call() async {
    return await authRepository.login();
  }
}
```

**login_auth_entity.dart**
```dart
/// Domain entity for Login Auth
/// 
/// Represents the business object structure
class LoginAuthEntity {
  final int? id;
  final String? message;
  final bool? success;
  final dynamic data;

  const LoginAuthEntity({
    this.id,
    this.message,
    this.success,
    this.data,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginAuthEntity &&
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
}
```

**login_auth_model.dart**
```dart
import '../../../domain/entities/login_auth_entity.dart';

/// Data model for Login Auth
/// 
/// Implements the domain entity with JSON serialization
class LoginAuthModel extends LoginAuthEntity {
  const LoginAuthModel({
    super.id,
    super.message,
    super.success,
    super.data,
  });

  /// Creates a model from JSON
  factory LoginAuthModel.fromJson(Map<String, dynamic> json) {
    return LoginAuthModel(
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
  LoginAuthModel copyWith({
    int? id,
    String? message,
    bool? success,
    dynamic data,
  }) {
    return LoginAuthModel(
      id: id ?? this.id,
      message: message ?? this.message,
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }
}
```
  }
}
```

**Updated Repository Interface**
```dart
abstract class AuthRepository {
  Future<Either<Failure, AuthModel>> getAuth();
  Future<Either<Failure, LoginAuthEntity>> login(); // ← New method added
}
```

**Updated Repository Implementation**
```dart
@override
Future<Either<Failure, LoginAuthEntity>> login() async {
  try {
    LoginAuthModel request = await remoteDataSource.login();
    return right(request);
  } on Exception catch (e) {
    if (e is DioException) {
      return left(ServerFailure.fromDioException(e));
    } else {
      return left(ServerFailure(message: e.toString()));
    }
  }
}
```

**Updated Data Source**
```dart
abstract class AuthRemoteDataSource {
  Future<AuthModel> getAuth();
  Future<LoginAuthModel> login(); // ← New method added
}

@Singleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImplementation extends AuthRemoteDataSource {
  // ...existing implementation...
  
  @override
  Future<LoginAuthModel> login() async {
    final response = await dioHelper.getData(
      ApisEndPoints.kAuthLoginUrl,
      headers: headersMapWithToken()
    );
    return LoginAuthModel.fromJson(response.data ?? {});
  }
}
  } on Exception catch (e) {
    if (e is DioException) {
      return left(ServerFailure.fromDioException(e));
    } else {
      return left(ServerFailure(message: e.toString()));
    }
  }
}
```

# Dependencies 📦
These dependencies will added to your pubspec.yaml:
```yaml
dependencies:
  flutter_bloc: 
  injectable: 
  dartz: 
  dio: 
  get_it:

dev_dependencies:
  build_runner: 
  injectable_generator: 
```

Run after code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

# Configuration ⚙️
Create feature_config.json for custom templates:
```
{
  "base_path": "lib/modules",
  "use_freezed": true,
  "add_routing": false
}
```

# Troubleshooting 🔧
### Issue: Command not found

\# Verify installation
```dart
dart pub global list
```
\# Check PATH configuration
```bash
echo $PATH
```
### Issue: Missing dependencies
```dart
flutter clean
flutter pub get
```
# Contributing 🤝
1. Fork the repository

2. Create feature branch (git checkout -b feature/improve-generator)

3. Commit changes (git commit -m 'Add template customization')

4. Push to branch (git push origin feature/improve-generator)

5. Open a Pull Request

# License 📄
This project is licensed under the BSD_3 License - see the [LICENSE](https://pub.dev/packages/feature_generator/license) file for details.
