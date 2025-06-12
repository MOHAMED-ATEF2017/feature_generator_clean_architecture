import 'dart:io';
import 'package:test/test.dart';
import 'package:feature_generator/src/directory_creator.dart';

void main() {
  group('Add UseCase Tests', () {
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

    test(
        'should create all necessary files for a new use case without entities',
        () {
      // First, create a basic feature structure
      createFeatureStructure('Auth');

      // Now add a new use case to the existing feature
      addUseCaseToFeature('Auth', 'Login');

      // Verify all expected files were created
      final expectedFiles = [
        'lib/features/Auth/domain/use_cases/login_use_case.dart',
        'lib/features/Auth/data/models/login_auth_model.dart',
      ];

      // Check if files exist
      for (final filePath in expectedFiles) {
        final file = File('${testDir.path}/$filePath');
        expect(file.existsSync(), isTrue,
            reason: 'File should exist: $filePath');

        if (file.existsSync()) {
          final content = file.readAsStringSync();
          print('\n=== File: $filePath ===');
          print(content);
          print('=== End of $filePath ===\n');
        }
      }

      // Verify repository files were updated
      final repositoryFiles = [
        'lib/features/Auth/domain/repositories/auth_repository.dart',
        'lib/features/Auth/data/repo/auth_repo.dart',
        'lib/features/Auth/data/data_sources/auth_data_source.dart',
      ];

      for (final filePath in repositoryFiles) {
        final file = File('${testDir.path}/$filePath');
        if (file.existsSync()) {
          final content = file.readAsStringSync();
          print('\n=== Updated File: $filePath ===');
          print(content);
          print('=== End of $filePath ===\n');
        }
      }

      // Verify no entity files were created
      final entityDir =
          Directory('${testDir.path}/lib/features/Auth/domain/entities');
      expect(entityDir.existsSync(), isFalse,
          reason: 'Entity directory should not be created');
    });

    test('should create multiple use cases for the same feature', () {
      // Create initial feature
      createFeatureStructure('User');

      // Add multiple use cases
      addUseCaseToFeature('User', 'Register');
      addUseCaseToFeature('User', 'GetProfile');
      addUseCaseToFeature('User', 'UpdateProfile');

      // Verify all use case files exist
      final useCaseFiles = [
        'lib/features/User/domain/use_cases/register_use_case.dart',
        'lib/features/User/domain/use_cases/getprofile_use_case.dart',
        'lib/features/User/domain/use_cases/updateprofile_use_case.dart',
      ];

      final modelFiles = [
        'lib/features/User/data/models/register_user_model.dart',
        'lib/features/User/data/models/getprofile_user_model.dart',
        'lib/features/User/data/models/updateprofile_user_model.dart',
      ];

      print('\n=== Multiple Use Cases Test ===');

      for (final filePath in useCaseFiles) {
        final file = File('${testDir.path}/$filePath');
        expect(file.existsSync(), isTrue,
            reason: 'Use case file should exist: $filePath');
        if (file.existsSync()) {
          print('\n--- Use Case File: $filePath ---');
          print(file.readAsStringSync());
        }
      }

      for (final filePath in modelFiles) {
        final file = File('${testDir.path}/$filePath');
        expect(file.existsSync(), isTrue,
            reason: 'Model file should exist: $filePath');
        if (file.existsSync()) {
          print('\n--- Model File: $filePath ---');
          print(file.readAsStringSync());
        }
      }

      // Check that repository files contain all methods
      final repoFile =
          File('${testDir.path}/lib/features/User/data/repo/user_repo.dart');
      if (repoFile.existsSync()) {
        final content = repoFile.readAsStringSync();
        print('\n--- Updated Repository Implementation ---');
        print(content);

        // Verify all methods are present
        expect(content.contains('register()'), isTrue);
        expect(content.contains('getprofile()'), isTrue);
        expect(content.contains('updateprofile()'), isTrue);
      }
    });
  });
}
