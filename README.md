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
### 1. If you use it from [pub.dev](https://pub.dev/packages/feature_generator)

```bash
    dart pub global activate feature_generator
 ```
     For Bash/Zsh
 ```bash
    export PATH="$PATH:$HOME/.pub-cache/bin"
```
    For PowerShell
```bash
    $env:Path += ";$env:USERPROFILE\.pub-cache\bin"
```

### 2. If you use it from [GitHub](https://github.com/MOHAMED-ATEF2017/feature_generator_clean_architecture)

    Add this lines to yaml
```yaml
dependencies:
  feature_generator:
    git:
      url: https://github.com/MOHAMED-ATEF2017/feature_generator_clean_architecture.git
      path: feature_generator/  # Path to package within repo
      ref: master               # Optional: branch/tag/commit
```
    Or run this at terminal 
```bash
dart pub global activate --source git https://github.com/MOHAMED-ATEF2017/feature_generator.git
```

# Usage 🚀
Generate a feature structure with optional automatic dependency installation:
```bash
feature_generator create --name <FEATURE_NAME>

OR

feature_generator create --name <FEATURE_NAME> [--install-deps]
```
## Example:

```bash
# Without automatic installation
feature_generator create --name Auth

# With full automatic installation
feature_generator create --name Auth --install-deps
```
<!-- ## This creates:
```
lib/features/user_profile/
├── Data/
├── Domain/
└── Presentation/
``` -->

# Generated Structure 🌳
```
lib/
├── core/ # Shared project components
│ ├── errors/ # Custom error classes
│ │ └── failure.dart # Failure type definitions
│ └── use_cases/ # Base use case classes
│ └── use_case.dart # Abstract UseCase template
│
└── features/ # Feature modules
└── <feature_name>/ # Generated feature name
├── Data/
│ ├── DataSources/ # API/Remote data sources
│ ├── Models/ # Data model classes
│ └── Repo/ # Repository implementations
│
├── Domain/
│ ├── Repositories/ # Abstract repository contracts
│ └── UseCases/ # Business logic components
│
└── Presentation/
├── Controller/ # BLoC/Cubit + State classes
└── Views/
├── Screens/ # Full page views
└── Widgets/ # Reusable components
```


Key additions:
1. Core directory structure shown at project root level
2. Explicit paths for critical base files
3. Clear separation between shared core components and feature modules

The core directory will be generated once during the first feature creation. Subsequent features will reuse these core components.

**Example Core Files** section added:
markdown
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

## 1. Cubit File (user_profile_cubit.dart):
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
## 2. Repository Contract (user_profile_repository.dart):
```dart
abstract class UserProfileRepository {
  Future<Either<Failure, UserProfileModel>> getProfile();
}
```
## 3. UseCase Template (lib/core/use_cases/use_case.dart):
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
## 4. Failure (lib/core/errors/failure.dart) :
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
## 5. Data Source (featurs/*FeatureName*/data/data_sources/*featurename*_data_source.dart):
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
## 6. Data RepoRepository (featurs/*FeatureName*/data/repo/*featurename*_repo.dart):
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
## 7. Domain Repository (featurs/*FeatureName*/domain/repositories/*featurename*_repository.dart):
```dart
import 'package:dartz/dartz.dart';
import '/Core/Errors/failure.dart';

abstract class FEATURENAMERepository {
  Future<Either<Failure, FEATURENAMEModel>> getFEATURENAME();
}
```
## 7. Domain UseCases (featurs/*FeatureName*/domain/use_cases/*featurename*_use_case_.dart):
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

# Dependencies 📦
These dependencies will added to your pubspec.yaml:
```yaml
dependencies:
  flutter_bloc: 
  injectable: 
  dartz: 
  dio: 

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
This project is licensed under the MIT License - see the [LICENSE](https://opensource.org/licenses/MIT) file for details.
