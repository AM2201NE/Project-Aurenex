import 'package:flutter_test/flutter_test.dart';
import 'package:neonote/models/workspace.dart';

void main() {
  group('Workspace', () {
    test('fromJson should handle valid data', () {
      final json = {
        'id': '1',
        'name': 'Test Workspace',
        'description': 'A test workspace',
        'createdAt': 1672531200000,
        'updatedAt': 1672531200000,
        'pages': '{}',
        'pageOrder': '[]',
        'settings': '{}',
      };

      final workspace = Workspace.fromJson(json);

      expect(workspace.id, '1');
      expect(workspace.name, 'Test Workspace');
      expect(workspace.description, 'A test workspace');
      expect(workspace.createdAt, 1672531200000);
      expect(workspace.updatedAt, 1672531200000);
      expect(workspace.pages, {});
      expect(workspace.pageOrder, []);
      expect(workspace.settings, {});
    });

    test('fromJson should handle missing data', () {
      final json = {
        'id': '1',
      };

      final workspace = Workspace.fromJson(json);

      expect(workspace.id, '1');
      expect(workspace.name, 'Default Workspace');
      expect(workspace.description, '');
      expect(workspace.createdAt, isA<int>());
      expect(workspace.updatedAt, isA<int>());
      expect(workspace.pages, {});
      expect(workspace.pageOrder, []);
      expect(workspace.settings, {});
    });

    test('fromJson should handle invalid data', () {
      final json = {
        'id': 1,
        'name': 123,
        'description': true,
        'createdAt': 'invalid',
        'updatedAt': 'invalid',
        'pages': 'invalid',
        'pageOrder': 'invalid',
        'settings': 'invalid',
      };

      final workspace = Workspace.fromJson(json);

      expect(workspace.id, '1');
      expect(workspace.name, '123');
      expect(workspace.description, 'true');
      expect(workspace.createdAt, isA<int>());
      expect(workspace.updatedAt, isA<int>());
      expect(workspace.pages, {});
      expect(workspace.pageOrder, []);
      expect(workspace.settings, {});
    });
  });
}
