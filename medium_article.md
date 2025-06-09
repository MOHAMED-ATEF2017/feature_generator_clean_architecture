# Building Flutter Apps Faster: A CLI Tool for Clean Architecture with BLoC Pattern

*Stop writing boilerplate code and start building features that matter*



<!-- ![Flutter Clean Architecture](https://miro.medium.com/v2/resize:fill:88:88/1*aA5T3WI33P2gc9A2xvaXqg.jpeg) -->
As Flutter developers, we've all been there: starting a new feature and spending hours setting up the same folder structure, writing boilerplate BLoC code, and creating repository patterns. What if I told you there's a way to generate a complete Clean Architecture feature structure in seconds?

## The Problem with Manual Setup

When building enterprise Flutter applications, maintaining a consistent Clean Architecture pattern is crucial for:
- **Maintainability**: Code that's easy to understand and modify
- **Testability**: Clear separation of concerns
- **Scalability**: Structure that grows with your app
- **Team Collaboration**: Consistent patterns across developers

However, manually setting up each feature involves:
- Creating 10+ folders and files
- Writing repetitive BLoC/Cubit boilerplate
- Setting up repository patterns
- Implementing use cases
- Configuring dependency injection

This process can take 30-60 minutes per feature and is prone to inconsistencies.

## Introducing Feature Generator

**Feature Generator** is a command-line tool that automates the creation of Clean Architecture folder structures with complete BLoC/Cubit implementation for Flutter projects.

### Key Features

✅ **Complete Clean Architecture Setup** - Generates data, domain, and presentation layers  
✅ **BLoC/Cubit Integration** - Pre-configured state management with proper states  
✅ **Dependency Injection Ready** - Injectable annotations and GetIt configuration  
✅ **Error Handling** - Built-in failure classes with Dio integration  
✅ **Cross-Platform** - Works on Windows, macOS, and Linux  
✅ **Zero Configuration** - Works out of the box with sensible defaults  

## Installation & Setup

### 1. Install the Package

```bash
flutter pub global activate feature_generator
```

### 2. Configure PATH (Automatic)

```bash
dart pub global run feature_generator:_post_install
```

This automatically detects your shell (Bash, Zsh, Fish) and adds the tool to your PATH.

### 3. Initialize Your Project

```bash
feature_generator install
```

This command:
- Creates core directories (`lib/core/errors`, `lib/core/use_cases`, `lib/core/utils`)
- Generates service locator configuration
- Installs required dependencies (flutter_bloc, injectable, dartz, dio, get_it)

## Usage: Creating Your First Feature

Let's create an authentication feature:

```bash
feature_generator create --name Auth
```

This single command generates:

```
lib/
├── core/
│   ├── errors/failure.dart
│   ├── use_cases/use_case.dart
│   └── utils/service_locator.dart
└── features/
    └── auth/
        ├── data/
        │   ├── data_sources/auth_data_source.dart
        │   ├── models/
        │   └── repo/auth_repo.dart
        ├── domain/
        │   ├── repositories/auth_repository.dart
        │   └── use_cases/auth_use_case.dart
        └── presentation/
            ├── controller/
            │   ├── auth_cubit.dart
            │   └── auth_state.dart
            └── views/
                ├── screens/
                └── widgets/
```

## Generated Code Examples

### 1. BLoC/Cubit with State Management

**auth_cubit.dart**
```dart
@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.fetchAuthUseCase) : super(AuthState());

  final FetchAuthUseCase fetchAuthUseCase;
  late AuthModel authModel = AuthModel.fromJson({});

  Future<void> fetchAuthData(BuildContext ctx) async {
    emit(AuthStateStart());
    Either<Failure, AuthModel> result = await fetchAuthUseCase.call();
    result.fold(
      (failure) {
        emit(AuthStateFailed(message: failure.message));
      },
      (request) {
        authModel = request;
        if (authModel.status == 200) {
          emit(AuthStateSuccess(authModel: authModel));
        } else {
          emit(AuthStateFailed(message: authModel.message));
        }
      },
    );
  }
}
```

**auth_state.dart**
```dart
part of 'auth_cubit.dart';

class AuthState {}

final class AuthStateInitial extends AuthState {}
final class AuthStateStart extends AuthState {}
final class AuthStateSuccess extends AuthState {
  final AuthModel authModel;
  AuthStateSuccess({required this.authModel});
}
final class AuthStateFailed extends AuthState {
  final String message;
  AuthStateFailed({required this.message});
}
```

### 2. Repository Pattern Implementation

**Domain Repository (Contract)**
```dart
abstract class AuthRepository {
  Future<Either<Failure, AuthModel>> getAuth();
}
```

**Data Repository (Implementation)**
```dart
@Singleton(as: AuthRepository)
class AuthRepoImpl extends AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AuthModel>> getAuth() async {
    try {
      AuthModel request = await remoteDataSource.getAuth();
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

### 3. Use Case Implementation

```dart
@lazySingleton
class FetchAuthUseCase extends UseCases<AuthModel> {
  final AuthRepository authRepository;

  FetchAuthUseCase({required this.authRepository});
  
  @override
  Future<Either<Failure, AuthModel>> call() async {
    return await authRepository.getAuth();
  }
}
```

### 4. Data Source with API Integration

```dart
@Singleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImplementation extends AuthRemoteDataSource {
  final DioHelper dioHelper;
  
  AuthRemoteDataSourceImplementation({required this.dioHelper});

  @override
  Future<AuthModel> getAuth() async {
    final response = await dioHelper.getData(
      ApisEndPoints.kGetAuthDataUrl,
      headers: headersMapWithToken()
    );
    return AuthModel.fromJson(response.data ?? {});
  }
}
```

## Advanced Features

### Error Handling

The tool generates a comprehensive failure system:

```dart
class ServerFailure extends Failure {
  factory ServerFailure.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure(message: 'Connection timed out');
      case DioExceptionType.badResponse:
        return ServerFailure.fromBadResponse(e.response!);
      // ... more cases
    }
  }
}
```

### Dependency Injection Setup

The service locator is automatically configured:

```dart
@InjectableInit()
void configureDependencies() => getIt.init();
```

Just call this in your `main.dart` and run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Real-World Usage

Let's create multiple features for a complete app:

```bash
# User management
feature_generator create --name User

# Product catalog
feature_generator create --name Product

# Shopping cart
feature_generator create --name Cart

# Order processing
feature_generator create --name Order
```

Each command generates a complete, testable feature following Clean Architecture principles.

## Benefits in Production

### 🚀 **Development Speed**
- **90% faster** feature setup
- Consistent code structure across teams
- Immediate focus on business logic

### 🛠 **Code Quality**
- Enforced Clean Architecture patterns
- Built-in error handling
- Type-safe state management

### 🧪 **Testing Ready**
- Clear separation of concerns
- Mockable dependencies
- Isolated business logic

### 👥 **Team Productivity**
- Standardized folder structure
- Reduced onboarding time
- Consistent naming conventions

## Customization Options

The tool provides flexibility for different project needs:

```bash
# Create feature with dependency installation
feature_generator create --name Profile --install-deps

# Install only core dependencies
feature_generator install --core

# Add individual use cases to existing features
feature_generator add-usecase --feature=Auth --usecase=Login
```

## Advanced Feature: Adding Use Cases

Beyond creating complete features, you can add individual use cases to existing features:

```bash
# Add a login use case to the auth feature
feature_generator add-usecase --feature=Auth --usecase=Login

# Add a logout use case
feature_generator add-usecase --feature=Auth --usecase=Logout

# Add password reset functionality
feature_generator add-usecase --feature=Auth --usecase=ResetPassword
```

Each `add-usecase` command generates:

### 1. Domain Entity
```dart
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
  
  // Equality operators and toString method included
}
```

### 2. Data Model with JSON Serialization
```dart
class LoginAuthModel extends LoginAuthEntity {
  const LoginAuthModel({
    super.id,
    super.message,
    super.success,
    super.data,
  });

  factory LoginAuthModel.fromJson(Map<String, dynamic> json) {
    return LoginAuthModel(
      id: json['id'] as int?,
      message: json['message'] as String?,
      success: json['success'] as bool?,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'success': success,
      'data': data,
    };
  }

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

### 3. Use Case Implementation
```dart
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

### 4. Automatic Repository Updates
The tool automatically updates your repository interface and implementation to include the new method, maintaining Clean Architecture principles.

## What's Next?

Future versions will include:
- Custom template support
- Integration with popular state management solutions
- API code generation from OpenAPI specs
- Unit test scaffolding

## Try It Yourself

Ready to boost your Flutter development productivity?

1. **Install**: `flutter pub global activate feature_generator`
2. **Setup**: `dart pub global run feature_generator:_post_install`
3. **Initialize**: `feature_generator install`
4. **Create**: `feature_generator create --name YourFeature`

## Conclusion

Manual setup of Clean Architecture in Flutter doesn't have to be tedious. With Feature Generator, you can:

- **Focus on business logic** instead of boilerplate
- **Maintain consistency** across your entire team
- **Scale faster** with proven architectural patterns
- **Ship features quicker** with ready-to-use components

The tool has generated over **1000+ features** for Flutter developers worldwide, saving countless hours of repetitive work.

---

**Links:**
- 📦 [Package on pub.dev](https://pub.dev/packages/feature_generator)
- 🔧 [GitHub Repository](https://github.com/MOHAMED-ATEF2017/feature_generator)
- 📚 [Documentation](https://pub.dev/documentation/feature_generator/latest/)

---

*Have you tried Feature Generator? Share your experience in the comments below! 👇*

**Tags:** #Flutter #CleanArchitecture #BLoC #CLI #DevTools #Productivity #MobileApp #StateManagement #DartLang #FlutterDev
