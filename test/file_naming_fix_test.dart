import 'dart:io';
import 'package:test/test.dart';
import 'package:feature_generator/src/directory_creator.dart';

void main() {
  group('Fixed File Naming Tests', () {
    late Directory testDir;

    setUp(() {
      // Create a temporary test directory
      testDir = Directory.systemTemp.createTempSync('file_naming_test_');
      Directory.current = testDir;
      print('Test directory: ${testDir.path}');
    });

    tearDown(() {
      // Clean up test directory
      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
    });

    test('should create files named after use case, not feature', () {
      print('\n🏗️  Step 1: Creating Fe feature...');

      // Step 1: Create the Fe feature structure
      createFeatureStructure('Fe');

      print('\n🔐 Step 2: Adding Login use case...');

      // Step 2: Add Login use case
      addUseCaseToFeature('Fe', 'Login');

      print('\n📝 Step 3: Verifying correct file names...');

      // Verify files are named after the use case, not the feature
      final expectedFiles = [
        // Should be named after LOGIN use case, not Fe feature
        'lib/features/Fe/domain/use_cases/login_use_case.dart',
        'lib/features/Fe/data/models/login_fe_model.dart',
        'lib/features/Fe/data/data_sources/login_data_source.dart',
        'lib/features/Fe/data/repo/login_repo.dart',
        'lib/features/Fe/domain/repositories/login_repository.dart',
      ];

      // Wrong files that should NOT exist (old naming pattern)
      final wrongFiles = [
        'lib/features/Fe/domain/repositories/fe_repository.dart',
        'lib/features/Fe/data/data_sources/fe_data_source.dart',
        'lib/features/Fe/data/repo/fe_repo.dart',
      ];

      print('\n✅ Verifying CORRECT files exist:');
      for (final filePath in expectedFiles) {
        final file = File('${testDir.path}/$filePath');
        expect(file.existsSync(), isTrue,
            reason: 'File should exist: $filePath');
        print('✅ $filePath');
      }

      print('\n❌ Verifying WRONG files do NOT exist:');
      for (final filePath in wrongFiles) {
        final file = File('${testDir.path}/$filePath');
        expect(file.existsSync(), isFalse,
            reason: 'File should NOT exist: $filePath');
        print('❌ $filePath (correctly NOT created)');
      }

      // Verify file contents have correct class names
      print('\n📋 Verifying class names in files:');

      // Check Login repository has LoginRepository class
      final loginRepoFile = File(
          '${testDir.path}/lib/features/Fe/domain/repositories/login_repository.dart');
      if (loginRepoFile.existsSync()) {
        final content = loginRepoFile.readAsStringSync();
        expect(content.contains('abstract class LoginRepository'), isTrue,
            reason: 'Should contain LoginRepository class');
        expect(content.contains('LoginFeModel'), isTrue,
            reason: 'Should reference LoginFeModel');
        print('✅ LoginRepository class found');
      }

      // Check Login data source has LoginRemoteDataSource class
      final loginDataSourceFile = File(
          '${testDir.path}/lib/features/Fe/data/data_sources/login_data_source.dart');
      if (loginDataSourceFile.existsSync()) {
        final content = loginDataSourceFile.readAsStringSync();
        expect(content.contains('abstract class LoginRemoteDataSource'), isTrue,
            reason: 'Should contain LoginRemoteDataSource class');
        expect(content.contains('LoginRemoteDataSourceImplementation'), isTrue,
            reason: 'Should contain LoginRemoteDataSourceImplementation class');
        print('✅ LoginRemoteDataSource classes found');
      }

      // Check Login repo implementation has LoginRepoImpl class
      final loginRepoImplFile =
          File('${testDir.path}/lib/features/Fe/data/repo/login_repo.dart');
      if (loginRepoImplFile.existsSync()) {
        final content = loginRepoImplFile.readAsStringSync();
        expect(content.contains('class LoginRepoImpl extends LoginRepository'),
            isTrue,
            reason: 'Should contain LoginRepoImpl class');
        print('✅ LoginRepoImpl class found');
      }

      print('\n🎯 SUMMARY:');
      print('- ✅ Files named after use case (Login) instead of feature (Fe)');
      print('- ✅ Class names follow use case naming pattern');
      print('- ✅ No incorrect feature-named files created');
      print('- ✅ Individual use case files created properly');
    });

    test('should create multiple use cases with correct individual naming', () {
      // Create feature and add multiple use cases
      createFeatureStructure('Fe');
      addUseCaseToFeature('Fe', 'Login');
      addUseCaseToFeature('Fe', 'Signup');
      addUseCaseToFeature('Fe', 'Logout');

      // Verify each use case gets its own files
      final useCases = ['Login', 'Signup', 'Logout'];

      for (final useCase in useCases) {
        final expectedFiles = [
          'lib/features/Fe/domain/use_cases/${useCase.toLowerCase()}_use_case.dart',
          'lib/features/Fe/data/models/${useCase.toLowerCase()}_fe_model.dart',
          'lib/features/Fe/data/data_sources/${useCase.toLowerCase()}_data_source.dart',
          'lib/features/Fe/data/repo/${useCase.toLowerCase()}_repo.dart',
          'lib/features/Fe/domain/repositories/${useCase.toLowerCase()}_repository.dart',
        ];

        for (final filePath in expectedFiles) {
          final file = File('${testDir.path}/$filePath');
          expect(file.existsSync(), isTrue,
              reason: '$useCase should have individual file: $filePath');
        }
      }

      print('✅ All use cases have individual files with correct naming');
    });
  });
}
