import 'dart:io';
import 'package:test/test.dart';
import 'package:feature_generator/src/directory_creator.dart';

void main() {
  group('Add UseCase Individual Files Tests', () {
    late Directory testDir;

    setUp(() {
      // Create a temporary test directory
      testDir = Directory.systemTemp.createTempSync('feature_generator_test_');
      Directory.current = testDir;
      print('Test directory: ${testDir.path}');
    });

    tearDown(() {
      // Clean up test directory
      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
    });

    test('should create individual files for each use case', () {
      // First, create a basic feature structure
      createFeatureStructure('Auth');

      // Now add a new use case to the existing feature
      addUseCaseToFeature('Auth', 'Login');

      // Verify all expected individual files were created
      final expectedFiles = [
        'lib/features/Auth/domain/use_cases/login_use_case.dart',
        'lib/features/Auth/data/models/login_auth_model.dart',
        'lib/features/Auth/data/data_sources/auth_data_source.dart',
        'lib/features/Auth/data/repo/auth_repo.dart',
        'lib/features/Auth/domain/repositories/auth_repository.dart',
      ];

      print('\n=== Individual Files Created for Login Use Case ===');

      // Check if files exist and show their content
      for (final filePath in expectedFiles) {
        final file = File('${testDir.path}/$filePath');
        expect(file.existsSync(), isTrue,
            reason: 'File should exist: $filePath');

        if (file.existsSync()) {
          final content = file.readAsStringSync();
          print('\n📄 File: $filePath');
          print('=' * 60);
          print(content);
          print('=' * 60);
        }
      }
    });

    test('should create separate files for multiple use cases', () {
      // Create initial feature
      createFeatureStructure('User');

      // Add multiple use cases
      addUseCaseToFeature('User', 'Register');
      addUseCaseToFeature('User', 'GetProfile');

      print('\n=== Files for Multiple Use Cases ===');

      // Check Register use case files
      final registerFiles = [
        'lib/features/User/domain/use_cases/register_use_case.dart',
        'lib/features/User/data/models/register_user_model.dart',
      ];

      // Check GetProfile use case files
      final getProfileFiles = [
        'lib/features/User/domain/use_cases/getprofile_use_case.dart',
        'lib/features/User/data/models/getprofile_user_model.dart',
      ];

      // Shared files (should exist once)
      final sharedFiles = [
        'lib/features/User/data/data_sources/user_data_source.dart',
        'lib/features/User/data/repo/user_repo.dart',
        'lib/features/User/domain/repositories/user_repository.dart',
      ];

      print('\n--- Register Use Case Files ---');
      for (final filePath in registerFiles) {
        final file = File('${testDir.path}/$filePath');
        expect(file.existsSync(), isTrue,
            reason: 'Register file should exist: $filePath');
        if (file.existsSync()) {
          print('\n📄 $filePath:');
          print(file.readAsStringSync());
        }
      }

      print('\n--- GetProfile Use Case Files ---');
      for (final filePath in getProfileFiles) {
        final file = File('${testDir.path}/$filePath');
        expect(file.existsSync(), isTrue,
            reason: 'GetProfile file should exist: $filePath');
        if (file.existsSync()) {
          print('\n📄 $filePath:');
          print(file.readAsStringSync());
        }
      }

      print('\n--- Shared Infrastructure Files ---');
      for (final filePath in sharedFiles) {
        final file = File('${testDir.path}/$filePath');
        expect(file.existsSync(), isTrue,
            reason: 'Shared file should exist: $filePath');
        if (file.existsSync()) {
          print('\n📄 $filePath:');
          print(file.readAsStringSync());
        }
      }
    });
  });
}
