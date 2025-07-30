import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:neonote/models/page.dart';
import 'package:neonote/models/workspace.dart';
import 'package:neonote/models/blocks/base_block.dart';
import 'package:neonote/models/blocks/text_blocks.dart';
import 'package:neonote/models/blocks/heading_block.dart';
import 'package:neonote/models/blocks/paragraph_block.dart';
import 'package:neonote/storage/repository.dart';

import 'models_test.mocks.dart';

@GenerateMocks([Repository])
void main() {
  group('Page Model Tests', () {
    late Page page;

    setUp(() {
      page = Page(
        title: 'Test Page',
        tags: ['test', 'flutter'],
      );
    });

    test('Page creation with default values', () {
      expect(page.title, equals('Test Page'));
      expect(page.tags, equals(['test', 'flutter']));
      expect(page.blocks, isEmpty);
      expect(page.blockOrder, isEmpty);
      expect(page.id, isNotNull);
      expect(page.createdAt, isNotNull);
      expect(page.updatedAt, isNotNull);
    });

    test('Adding blocks to page', () {
      final block1 = ParagraphBlock(
        richText: const [TextSpan(text: 'Test paragraph')],
        parentId: page.id,
      );

      final block2 = HeadingBlock(
        level: 1,
        richText: const [TextSpan(text: 'Test heading')],
        parentId: page.id,
      );

      page.blocks[block1.id] = block1;
      page.blockOrder.add(block1.id);
      page.blocks[block2.id] = block2;
      page.blockOrder.add(block2.id);

      expect(page.blocks.length, equals(2));
      expect(page.blockOrder.length, equals(2));
      expect(page.blocks[block1.id], equals(block1));
      expect(page.blocks[block2.id], equals(block2));
      expect(page.blockOrder[0], equals(block1.id));
      expect(page.blockOrder[1], equals(block2.id));
    });
  });

  group('Workspace Model Tests', () {
    late Workspace workspace;
    late Page page1;
    late Page page2;

    setUp(() {
      workspace = Workspace(
        name: 'Test Workspace',
        description: 'A test workspace',
      );

      page1 = Page(
        title: 'Page 1',
        tags: ['test'],
      );

      page2 = Page(
        title: 'Page 2',
        tags: ['flutter'],
      );
    });

    test('Workspace creation with default values', () {
      expect(workspace.name, equals('Test Workspace'));
      expect(workspace.description, equals('A test workspace'));
      expect(workspace.pages, isEmpty);
      expect(workspace.pageOrder, isEmpty);
      expect(workspace.id, isNotNull);
      expect(workspace.createdAt, isNotNull);
      expect(workspace.updatedAt, isNotNull);
    });

    test('Adding pages to workspace', () {
      workspace.pages[page1.id] = page1;
      workspace.pageOrder.add(page1.id);
      workspace.pages[page2.id] = page2;
      workspace.pageOrder.add(page2.id);

      expect(workspace.pages.length, equals(2));
      expect(workspace.pageOrder.length, equals(2));
      expect(workspace.pages[page1.id], equals(page1));
      expect(workspace.pages[page2.id], equals(page2));
      expect(workspace.pageOrder[0], equals(page1.id));
      expect(workspace.pageOrder[1], equals(page2.id));
    });
  });

  group('Repository Tests', () {
    late MockRepository repository;
    late Page testPage;
    late Workspace testWorkspace;

    setUp(() {
      repository = MockRepository();

      testPage = Page(
        title: 'Test Page',
        tags: ['test'],
      );

      testWorkspace = Workspace(
        name: 'Test Workspace',
        description: 'A test workspace',
      );
    });

    test('Save and load page', () async {
      // Setup mock behavior
      when(repository.savePage(testPage)).thenAnswer((_) async {});
      when(repository.loadPage(testPage.id))
          .thenAnswer((_) async => testPage);

      // Save page
      await repository.savePage(testPage);
      verify(repository.savePage(testPage)).called(1);

      // Load page
      final loadedPage = await repository.loadPage(testPage.id);
      verify(repository.loadPage(testPage.id)).called(1);

      expect(loadedPage, equals(testPage));
    });

    test('Delete page', () async {
      // Setup mock behavior
      when(repository.deletePage(testPage.id)).thenAnswer((_) async {});
      when(repository.loadPage(testPage.id)).thenAnswer((_) async => null);

      // Delete page
      await repository.deletePage(testPage.id);
      verify(repository.deletePage(testPage.id)).called(1);

      // Try to load deleted page
      final loadedPage = await repository.loadPage(testPage.id);
      verify(repository.loadPage(testPage.id)).called(1);

      expect(loadedPage, isNull);
    });

    test('List pages', () async {
      final page1 = Page(title: 'Page 1');
      final page2 = Page(title: 'Page 2');

      // Setup mock behavior
      when(repository.listPages()).thenAnswer((_) async => [page1, page2]);

      // List pages
      final pages = await repository.listPages();
      verify(repository.listPages()).called(1);

      expect(pages.length, equals(2));
      expect(pages[0], equals(page1));
      expect(pages[1], equals(page2));
    });

    test('Save and load workspace', () async {
      // Setup mock behavior
      when(repository.saveWorkspace(testWorkspace)).thenAnswer((_) async {});
      when(repository.loadWorkspace(testWorkspace.id))
          .thenAnswer((_) async => testWorkspace);

      // Save workspace
      await repository.saveWorkspace(testWorkspace);
      verify(repository.saveWorkspace(testWorkspace)).called(1);

      // Load workspace
      final loadedWorkspace =
          await repository.loadWorkspace(testWorkspace.id);
      verify(repository.loadWorkspace(testWorkspace.id)).called(1);

      expect(loadedWorkspace, equals(testWorkspace));
    });

    test('Search pages by title', () async {
      final page1 = Page(title: 'Flutter Page');

      // Setup mock behavior
      when(repository.searchPagesByTitle('Flutter'))
          .thenAnswer((_) async => [page1]);

      // Search pages
      final results = await repository.searchPagesByTitle('Flutter');
      verify(repository.searchPagesByTitle('Flutter')).called(1);

      expect(results.length, equals(1));
      expect(results[0], equals(page1));
    });

    test('Search pages by tag', () async {
      final page1 = Page(title: 'Page 1', tags: ['flutter']);

      // Setup mock behavior
      when(repository.searchPagesByTag('flutter'))
          .thenAnswer((_) async => [page1]);

      // Search pages
      final results = await repository.searchPagesByTag('flutter');
      verify(repository.searchPagesByTag('flutter')).called(1);

      expect(results.length, equals(1));
      expect(results[0], equals(page1));
    });
  });
}
