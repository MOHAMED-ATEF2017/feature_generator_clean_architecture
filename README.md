# Feature Generator 🛠️

[![Pub Version](https://img.shields.io/pub/v/feature_generator)](https://pub.dev/packages/feature_generator)
[![Build Status](https://img.shields.io/github/actions/workflow/status/MOHAMED-ATEF2017/feature_generator/dart.yml)](https://github.com/MOHAMED-ATEF2017/feature_generator/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

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
### 1. If you use it from [pub.dev](https://pub.dev)

```bash
    dart pub global activate feature_generator
 ```
     For Bash/Zsh
 ```
    export PATH="$PATH:$HOME/.pub-cache/bin"
```
    For PowerShell
```
    $env:Path += ";$env:USERPROFILE\.pub-cache\bin"
```

### 2. If you use it from [GitHub](https://github.com/MOHAMED-ATEF2017/feature_generator)

    Add this lines to yaml
```
dependencies:
  feature_generator:
    git:
      url: https://github.com/MOHAMED-ATEF2017/feature_generator.git
      path: feature_generator/  # Path to package within repo
      ref: master               # Optional: branch/tag/commit
```
    Or run this at terminal 
```
dart pub global activate --source git https://github.com/MOHAMED-ATEF2017/feature_generator.git
```

# Usage 🚀
Generate a new feature structure:
```
feature_generator create --name <FEATURE_NAME>
```
## Example:

```
feature_generator create --name UserProfile
```
## This creates:
```
lib/features/user_profile/
├── Data/
├── Domain/
└── Presentation/
```

# Generated Structure 🌳
```
<feature_name>/
├── Data/
│   ├── DataSources/          # Remote data sources
│   ├── Models/               # Data transfer objects
│   └── Repo/                 # Repository implementations
│
├── Domain/
│   ├── Repositories/         # Abstract repository contracts
│   └── UseCases/             # Business logic components
│
└── Presentation/
    ├── Controller/           # BLoC/Cubit + States
    └── Views/
        ├── Screens/          # Full page views
        └── Widgets/          # Reusable components
```
# Example Code 🧑💻

## 1. Cubit File (user_profile_cubit.dart):
```
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
```
abstract class UserProfileRepository {
  Future<Either<Failure, UserProfileModel>> getProfile();
}
```

# Dependencies 📦
Add these to your pubspec.yaml:
```
dependencies:
  flutter_bloc: ^8.1.3
  injectable: ^2.1.0
  dartz: ^0.10.1
  dio: ^5.3.0

dev_dependencies:
  build_runner: ^2.4.6
  injectable_generator: ^2.1.0
```

Run after code generation:

```
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
```
dart pub global list
```
\# Check PATH configuration
```
echo $PATH
```
### Issue: Missing dependencies
```
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
