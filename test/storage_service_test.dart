import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:neonote/services/storage_service.dart';

void main() {
  // Initialize FFI
  sqfliteFfiInit();
  // Set the database factory to FFI
  databaseFactory = databaseFactoryFfi;

  group('StorageService', () {
    late StorageService storageService;

    setUp(() {
      storageService = StorageService();
    });

    test('getWorkspaceDataWithDirectory should return default workspace if database is empty', () async {
      final workspaceData = await storageService.getWorkspaceDataWithDirectory('default');
      expect(workspaceData['id'], 'default');
      expect(workspaceData['name'], 'Default Workspace');
    });
  });
}
