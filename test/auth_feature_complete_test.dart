import 'dart:io';
import 'package:test/test.dart';
import 'package:feature_generator/src/directory_creator.dart';

void main() {
  group('Auth Feature with Login and Signup Use Cases', () {
    late Directory testDir;

    setUp(() {
      // Create a temporary test directory
      testDir = Directory.systemTemp.createTempSync('auth_feature_test_');
      Directory.current = testDir;
      print('Test directory: ${testDir.path}');
    });

    tearDown(() {
      // Clean up test directory
      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
    });

    test('should create Auth feature and add Login and Signup use cases', () {
      print('\n🏗️  Step 1: Creating Auth feature...');

      // Step 1: Create the Auth feature structure
      createFeatureStructure('Auth');

      print('\n✅ Auth feature created successfully!');

      // Verify basic feature structure exists
      final featureDir = Directory('${testDir.path}/lib/features/Auth');
      expect(featureDir.existsSync(), isTrue,
          reason: 'Auth feature directory should exist');

      print('\n🔐 Step 2: Adding Login use case...');

      // Step 2: Add Login use case
      addUseCaseToFeature('Auth', 'Login');

      print('\n📝 Step 3: Adding Signup use case...');

      // Step 3: Add Signup use case
      addUseCaseToFeature('Auth', 'Signup');

      print('\n🎉 All use cases added successfully!');

      // Verify all files were created
      final expectedFiles = [
        // Login use case files
        'lib/features/Auth/domain/use_cases/login_use_case.dart',
        'lib/features/Auth/data/models/login_auth_model.dart',

        // Signup use case files
        'lib/features/Auth/domain/use_cases/signup_use_case.dart',
        'lib/features/Auth/data/models/signup_auth_model.dart',

        // Shared infrastructure files
        'lib/features/Auth/data/data_sources/auth_data_source.dart',
        'lib/features/Auth/data/repo/auth_repo.dart',
        'lib/features/Auth/domain/repositories/auth_repository.dart',

        // Original feature files
        'lib/features/Auth/presentation/controller/auth_cubit.dart',
        'lib/features/Auth/presentation/controller/auth_state.dart',
        'lib/features/Auth/presentation/views/auth_views.dart',
      ];

      print('\n📋 Verifying all files were created:');

      for (final filePath in expectedFiles) {
        final file = File('${testDir.path}/$filePath');
        expect(file.existsSync(), isTrue,
            reason: 'File should exist: $filePath');
        print('✅ $filePath');
      }

      // Display file contents
      print('\n📄 FILE CONTENTS:');
      print('=' * 80);

      // Show Login use case
      final loginUseCaseFile = File(
          '${testDir.path}/lib/features/Auth/domain/use_cases/login_use_case.dart');
      if (loginUseCaseFile.existsSync()) {
        print('\n🔐 LOGIN USE CASE:');
        print('-' * 50);
        print(loginUseCaseFile.readAsStringSync());
      }

      // Show Login model
      final loginModelFile = File(
          '${testDir.path}/lib/features/Auth/data/models/login_auth_model.dart');
      if (loginModelFile.existsSync()) {
        print('\n📦 LOGIN MODEL:');
        print('-' * 50);
        print(loginModelFile.readAsStringSync());
      }

      // Show Signup use case
      final signupUseCaseFile = File(
          '${testDir.path}/lib/features/Auth/domain/use_cases/signup_use_case.dart');
      if (signupUseCaseFile.existsSync()) {
        print('\n📝 SIGNUP USE CASE:');
        print('-' * 50);
        print(signupUseCaseFile.readAsStringSync());
      }

      // Show Signup model
      final signupModelFile = File(
          '${testDir.path}/lib/features/Auth/data/models/signup_auth_model.dart');
      if (signupModelFile.existsSync()) {
        print('\n📦 SIGNUP MODEL:');
        print('-' * 50);
        print(signupModelFile.readAsStringSync());
      }

      // Show shared data source
      final dataSourceFile = File(
          '${testDir.path}/lib/features/Auth/data/data_sources/auth_data_source.dart');
      if (dataSourceFile.existsSync()) {
        print('\n🌐 SHARED DATA SOURCE:');
        print('-' * 50);
        print(dataSourceFile.readAsStringSync());
      }

      // Show shared repository implementation
      final repoFile =
          File('${testDir.path}/lib/features/Auth/data/repo/auth_repo.dart');
      if (repoFile.existsSync()) {
        print('\n🏛️  SHARED REPOSITORY IMPLEMENTATION:');
        print('-' * 50);
        print(repoFile.readAsStringSync());
      }

      // Show shared domain repository
      final domainRepoFile = File(
          '${testDir.path}/lib/features/Auth/domain/repositories/auth_repository.dart');
      if (domainRepoFile.existsSync()) {
        print('\n🏛️  SHARED DOMAIN REPOSITORY:');
        print('-' * 50);
        print(domainRepoFile.readAsStringSync());
      }

      // Show Cubit (original feature file)
      final cubitFile = File(
          '${testDir.path}/lib/features/Auth/presentation/controller/auth_cubit.dart');
      if (cubitFile.existsSync()) {
        print('\n🔄 AUTH CUBIT (Original Feature):');
        print('-' * 50);
        print(cubitFile.readAsStringSync());
      }

      print('\n${'=' * 80}');
      print('🎯 SUMMARY:');
      print('- ✅ Auth feature created with complete folder structure');
      print('- ✅ Login use case added with standalone model');
      print('- ✅ Signup use case added with standalone model');
      print('- ✅ No entity files created (as requested)');
      print('- ✅ Shared infrastructure files created once');
      print('- ✅ Original feature files preserved');
      print('=' * 80);
    });

    test('should verify no entity directories were created', () {
      // Create feature and add use cases
      createFeatureStructure('Auth');
      addUseCaseToFeature('Auth', 'Login');
      addUseCaseToFeature('Auth', 'Signup');

      // Verify no entity directory exists
      final entityDir =
          Directory('${testDir.path}/lib/features/Auth/domain/entities');
      expect(entityDir.existsSync(), isFalse,
          reason: 'Entity directory should NOT be created');

      print('✅ Confirmed: No entity directory created (as requested)');
    });

    test('should create separate model files for each use case', () {
      // Create feature and add use cases
      createFeatureStructure('Auth');
      addUseCaseToFeature('Auth', 'Login');
      addUseCaseToFeature('Auth', 'Signup');

      // Verify separate model files exist
      final loginModel = File(
          '${testDir.path}/lib/features/Auth/data/models/login_auth_model.dart');
      final signupModel = File(
          '${testDir.path}/lib/features/Auth/data/models/signup_auth_model.dart');

      expect(loginModel.existsSync(), isTrue,
          reason: 'Login model should exist');
      expect(signupModel.existsSync(), isTrue,
          reason: 'Signup model should exist');

      // Verify they are different files with different content
      final loginContent = loginModel.readAsStringSync();
      final signupContent = signupModel.readAsStringSync();

      expect(loginContent.contains('LoginAuthModel'), isTrue);
      expect(signupContent.contains('SignupAuthModel'), isTrue);
      expect(loginContent != signupContent, isTrue,
          reason: 'Models should have different content');

      print('✅ Confirmed: Separate model files created for each use case');
    });
  });
}
