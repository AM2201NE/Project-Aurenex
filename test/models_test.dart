import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:neonote/models/page.dart';
import 'package:neonote/models/workspace.dart';
import 'package:neonote/models/blocks/base_block.dart';
import 'package:neonote/models/blocks/text_blocks.dart';
import 'package:neonote/storage/repository.dart';

// Generate mocks
@GenerateMocks([Repository])
import 'repository_test.mocks.dart';

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
        richText: [TextSpan(text: 'Test paragraph')],
        parentId: page.id,
      );
      
      final block2 = HeadingBlock(
        level: 1,
        richText: [TextSpan(text: 'Test heading')],
        parentId: page.id,
      );
      
      page.addBlock(block1);
      page.addBlock(block2);
      
      expect(page.blocks.length, equals(2));
      expect(page.blockOrder.length, equals(2));
      expect(page.blocks[block1.id], equals(block1));
      expect(page.blocks[block2.id], equals(block2));
      expect(page.blockOrder[0], equals(block1.id));
      expect(page.blockOrder[1], equals(block2.id));
    });
    
    test('Adding block at specific index', () {
      final block1 = ParagraphBlock(
        richText: [TextSpan(text: 'First paragraph')],
        parentId: page.id,
      );
      
      final block2 = ParagraphBlock(
        richText: [TextSpan(text: 'Second paragraph')],
        parentId: page.id,
      );
      
      final block3 = ParagraphBlock(
        richText: [TextSpan(text: 'Inserted paragraph')],
        parentId: page.id,
      );
      
      page.addBlock(block1);
      page.addBlock(block2);
      page.addBlock(block3, index: 1);
      
      expect(page.blockOrder.length, equals(3));
      expect(page.blockOrder[0], equals(block1.id));
      expect(page.blockOrder[1], equals(block3.id));
      expect(page.blockOrder[2], equals(block2.id));
    });
    
    test('Removing blocks from page', () {
      final block1 = ParagraphBlock(
        richText: [TextSpan(text: 'Test paragraph')],
        parentId: page.id,
      );
      
      final block2 = HeadingBlock(
        level: 1,
        richText: [TextSpan(text: 'Test heading')],
        parentId: page.id,
      );
      
      page.addBlock(block1);
      page.addBlock(block2);
      
      expect(page.blocks.length, equals(2));
      
      page.removeBlock(block1.id);
      
      expect(page.blocks.length, equals(1));
      expect(page.blockOrder.length, equals(1));
      expect(page.blocks.containsKey(block1.id), isFalse);
      expect(page.blocks.containsKey(block2.id), isTrue);
      expect(page.blockOrder[0], equals(block2.id));
    });
    
    test('Moving blocks within page', () {
      final block1 = ParagraphBlock(
        richText: [TextSpan(text: 'First paragraph')],
        parentId: page.id,
      );
      
      final block2 = ParagraphBlock(
        richText: [TextSpan(text: 'Second paragraph')],
        parentId: page.id,
      );
      
      final block3 = ParagraphBlock(
        richText: [TextSpan(text: 'Third paragraph')],
        parentId: page.id,
      );
      
      page.addBlock(block1);
      page.addBlock(block2);
      page.addBlock(block3);
      
      expect(page.blockOrder[0], equals(block1.id));
      expect(page.blockOrder[1], equals(block2.id));
      expect(page.blockOrder[2], equals(block3.id));
      
      page.moveBlock(block3.id, toIndex: 0);
      
      expect(page.blockOrder[0], equals(block3.id));
      expect(page.blockOrder[1], equals(block1.id));
      expect(page.blockOrder[2], equals(block2.id));
    });
    
    test('Updating blocks in page', () {
      final block = ParagraphBlock(
        richText: [TextSpan(text: 'Original text')],
        parentId: page.id,
      );
      
      page.addBlock(block);
      
      final updatedBlock = ParagraphBlock(
        id: block.id,
        richText: [TextSpan(text: 'Updated text')],
        parentId: page.id,
      );
      
      page.updateBlock(updatedBlock);
      
      expect(page.blocks[block.id], equals(updatedBlock));
      expect((page.blocks[block.id] as ParagraphBlock).plainText, equals('Updated text'));
    });
    
    test('Getting ordered blocks', () {
      final block1 = ParagraphBlock(
        richText: [TextSpan(text: 'First paragraph')],
        parentId: page.id,
      );
      
      final block2 = HeadingBlock(
        level: 1,
        richText: [TextSpan(text: 'Heading')],
        parentId: page.id,
      );
      
      final block3 = ParagraphBlock(
        richText: [TextSpan(text: 'Second paragraph')],
        parentId: page.id,
      );
      
      page.addBlock(block1);
      page.addBlock(block2);
      page.addBlock(block3);
      
      final orderedBlocks = page.getOrderedBlocks();
      
      expect(orderedBlocks.length, equals(3));
      expect(orderedBlocks[0], equals(block1));
      expect(orderedBlocks[1], equals(block2));
      expect(orderedBlocks[2], equals(block3));
    });
    
    test('Adding and removing tags', () {
      expect(page.tags, equals(['test', 'flutter']));
      
      page.addTag('dart');
      expect(page.tags, equals(['test', 'flutter', 'dart']));
      
      page.removeTag('flutter');
      expect(page.tags, equals(['test', 'dart']));
      
      // Adding duplicate tag should not change anything
      page.addTag('test');
      expect(page.tags, equals(['test', 'dart']));
    });
    
    test('Checking if page has tag', () {
      expect(page.hasTag('test'), isTrue);
      expect(page.hasTag('flutter'), isTrue);
      expect(page.hasTag('dart'), isFalse);
    });
    
    test('Getting blocks by type', () {
      final paragraph1 = ParagraphBlock(
        richText: [TextSpan(text: 'First paragraph')],
        parentId: page.id,
      );
      
      final heading = HeadingBlock(
        level: 1,
        richText: [TextSpan(text: 'Heading')],
        parentId: page.id,
      );
      
      final paragraph2 = ParagraphBlock(
        richText: [TextSpan(text: 'Second paragraph')],
        parentId: page.id,
      );
      
      page.addBlock(paragraph1);
      page.addBlock(heading);
      page.addBlock(paragraph2);
      
      final paragraphs = page.getBlocksByType('paragraph');
      expect(paragraphs.length, equals(2));
      expect(paragraphs.contains(paragraph1), isTrue);
      expect(paragraphs.contains(paragraph2), isTrue);
      
      final headings = page.getBlocksByType('heading_1');
      expect(headings.length, equals(1));
      expect(headings.contains(heading), isTrue);
    });
    
    test('Finding blocks with text', () {
      final paragraph1 = ParagraphBlock(
        richText: [TextSpan(text: 'This is about Flutter')],
        parentId: page.id,
      );
      
      final heading = HeadingBlock(
        level: 1,
        richText: [TextSpan(text: 'Dart Programming')],
        parentId: page.id,
      );
      
      final paragraph2 = ParagraphBlock(
        richText: [TextSpan(text: 'More about Dart and Flutter')],
        parentId: page.id,
      );
      
      page.addBlock(paragraph1);
      page.addBlock(heading);
      page.addBlock(paragraph2);
      
      final flutterBlocks = page.findBlocksWithText('Flutter');
      expect(flutterBlocks.length, equals(2));
      expect(flutterBlocks.contains(paragraph1), isTrue);
      expect(flutterBlocks.contains(paragraph2), isTrue);
      
      final dartBlocks = page.findBlocksWithText('Dart');
      expect(dartBlocks.length, equals(2));
      expect(dartBlocks.contains(heading), isTrue);
      expect(dartBlocks.contains(paragraph2), isTrue);
    });
    
    test('Page copying', () {
      final paragraph = ParagraphBlock(
        richText: [TextSpan(text: 'Test paragraph')],
        parentId: page.id,
      );
      
      final heading = HeadingBlock(
        level: 1,
        richText: [TextSpan(text: 'Test heading')],
        parentId: page.id,
      );
      
      page.addBlock(paragraph);
      page.addBlock(heading);
      
      final copy = page.copy();
      
      expect(copy.id, isNot(equals(page.id)));
      expect(copy.title, equals('Test Page (Copy)'));
      expect(copy.tags, equals(['test', 'flutter']));
      expect(copy.blocks.length, equals(2));
      expect(copy.blockOrder.length, equals(2));
      
      // Blocks should be copied with new IDs
      expect(copy.blocks.keys.toSet().intersection(page.blocks.keys.toSet()), isEmpty);
      
      // Block content should be the same
      final copiedParagraph = copy.blocks.values.firstWhere((b) => b.type == 'paragraph') as ParagraphBlock;
      expect(copiedParagraph.plainText, equals('Test paragraph'));
      
      final copiedHeading = copy.blocks.values.firstWhere((b) => b.type == 'heading_1') as HeadingBlock;
      expect(copiedHeading.plainText, equals('Test heading'));
    });
    
    test('Page to JSON and from JSON', () {
      final paragraph = ParagraphBlock(
        richText: [TextSpan(text: 'Test paragraph')],
        parentId: page.id,
      );
      
      final heading = HeadingBlock(
        level: 1,
        richText: [TextSpan(text: 'Test heading')],
        parentId: page.id,
      );
      
      page.addBlock(paragraph);
      page.addBlock(heading);
      
      final json = page.toJson();
      final fromJson = Page.fromJson(json);
      
      expect(fromJson.id, equals(page.id));
      expect(fromJson.title, equals(page.title));
      expect(fromJson.tags, equals(page.tags));
      expect(fromJson.blocks.length, equals(page.blocks.length));
      expect(fromJson.blockOrder, equals(page.blockOrder));
      
      // Check block content
      final jsonParagraph = fromJson.blocks.values.firstWhere((b) => b.type == 'paragraph') as ParagraphBlock;
      expect(jsonParagraph.plainText, equals('Test paragraph'));
      
      final jsonHeading = fromJson.blocks.values.firstWhere((b) => b.type == 'heading_1') as HeadingBlock;
      expect(jsonHeading.plainText, equals('Test heading'));
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
      workspace.addPage(page1);
      workspace.addPage(page2);
      
      expect(workspace.pages.length, equals(2));
      expect(workspace.pageOrder.length, equals(2));
      expect(workspace.pages[page1.id], equals(page1));
      expect(workspace.pages[page2.id], equals(page2));
      expect(workspace.pageOrder[0], equals(page1.id));
      expect(workspace.pageOrder[1], equals(page2.id));
    });
    
    test('Adding page at specific index', () {
      final page3 = Page(title: 'Page 3');
      
      workspace.addPage(page1);
      workspace.addPage(page2);
      workspace.addPage(page3, index: 1);
      
      expect(workspace.pageOrder.length, equals(3));
      expect(workspace.pageOrder[0], equals(page1.id));
      expect(workspace.pageOrder[1], equals(page3.id));
      expect(workspace.pageOrder[2], equals(page2.id));
    });
    
    test('Removing pages from workspace', () {
      workspace.addPage(page1);
      workspace.addPage(page2);
      
      expect(workspace.pages.length, equals(2));
      
      workspace.removePage(page1.id);
      
      expect(workspace.pages.length, equals(1));
      expect(workspace.pageOrder.length, equals(1));
      expect(workspace.pages.containsKey(page1.id), isFalse);
      expect(workspace.pages.containsKey(page2.id), isTrue);
      expect(workspace.pageOrder[0], equals(page2.id));
    });
    
    test('Moving pages within workspace', () {
      final page3 = Page(title: 'Page 3');
      
      workspace.addPage(page1);
      workspace.addPage(page2);
      workspace.addPage(page3);
      
      expect(workspace.pageOrder[0], equals(page1.id));
      expect(workspace.pageOrder[1], equals(page2.id));
      expect(workspace.pageOrder[2], equals(page3.id));
      
      workspace.movePage(page3.id, toIndex: 0);
      
      expect(workspace.pageOrder[0], equals(page3.id));
      expect(workspace.pageOrder[1], equals(page1.id));
      expect(workspace.pageOrder[2], equals(page2.id));
    });
    
    test('Updating pages in workspace', () {
      workspace.addPage(page1);
      
      final updatedPage = Page(
        id: page1.id,
        title: 'Updated Page 1',
        tags: ['updated'],
      );
      
      workspace.updatePage(updatedPage);
      
      expect(workspace.pages[page1.id], equals(updatedPage));
      expect(workspace.pages[page1.id]!.title, equals('Updated Page 1'));
      expect(workspace.pages[page1.id]!.tags, equals(['updated']));
    });
    
    test('Getting ordered pages', () {
      workspace.addPage(page1);
      workspace.addPage(page2);
      
      final orderedPages = workspace.getOrderedPages();
      
      expect(orderedPages.length, equals(2));
      expect(orderedPages[0], equals(page1));
      expect(orderedPages[1], equals(page2));
    });
    
    test('Finding pages by title', () {
      final page3 = Page(title: 'Flutter Page');
      
      workspace.addPage(page1);
      workspace.addPage(page2);
      workspace.addPage(page3);
      
      final results = workspace.findPagesByTitle('Page');
      expect(results.length, equals(3));
      
      final flutterResults = workspace.findPagesByTitle('Flutter');
      expect(flutterResults.length, equals(1));
      expect(flutterResults[0], equals(page3));
    });
    
    test('Finding pages by tag', () {
      workspace.addPage(page1);
      workspace.addPage(page2);
      
      final testTagPages = workspace.findPagesByTag('test');
      expect(testTagPages.length, equals(1));
      expect(testTagPages[0], equals(page1));
      
      final flutterTagPages = workspace.findPagesByTag('flutter');
      expect(flutterTagPages.length, equals(1));
      expect(flutterTagPages[0], equals(page2));
    });
    
    test('Getting all tags in workspace', () {
      workspace.addPage(page1);
      workspace.addPage(page2);
      
      final allTags = workspace.getAllTags();
      expect(allTags, equals({'test', 'flutter'}));
    });
    
    test('Workspace copying', () {
      workspace.addPage(page1);
      workspace.addPage(page2);
      
      final copy = workspace.copy();
      
      expect(copy.id, isNot(equals(workspace.id)));
      expect(copy.name, equals('Test Workspace (Copy)'));
      expect(copy.description, equals('A test workspace'));
      expect(copy.pages.length, equals(2));
      expect(copy.pageOrder.length, equals(2));
      
      // Pages should be copied with new IDs
      expect(copy.pages.keys.toSet().intersection(workspace.pages.keys.toSet()), isEmpty);
      
      // Page content should be the same
      final copiedPage1 = copy.pages.values.firstWhere((p) => p.title == 'Page 1');
      expect(copiedPage1.tags, equals(['test']));
      
      final copiedPage2 = copy.pages.values.firstWhere((p) => p.title == 'Page 2');
      expect(copiedPage2.tags, equals(['flutter']));
    });
    
    test('Workspace to JSON and from JSON', () {
      workspace.addPage(page1);
      workspace.addPage(page2);
      
      final json = workspace.toJson();
      final fromJson = Workspace.fromJson(json);
      
      expect(fromJson.id, equals(workspace.id));
      expect(fromJson.name, equals(workspace.name));
      expect(fromJson.description, equals(workspace.description));
      expect(fromJson.pages.length, equals(workspace.pages.length));
      expect(fromJson.pageOrder, equals(workspace.pageOrder));
      
      // Check page content
      final jsonPage1 = fromJson.pages.values.firstWhere((p) => p.title == 'Page 1');
      expect(jsonPage1.tags, equals(['test']));
      
      final jsonPage2 = fromJson.pages.values.firstWhere((p) => p.title == 'Page 2');
      expect(jsonPage2.tags, equals(['flutter']));
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
      when(repository.loadPage(testPage.id)).thenAnswer((_) async => testPage);
      
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
      when(repository.loadWorkspace(testWorkspace.id)).thenAnswer((_) async => testWorkspace);
      
      // Save workspace
      await repository.saveWorkspace(testWorkspace);
      verify(repository.saveWorkspace(testWorkspace)).called(1);
      
      // Load workspace
      final loadedWorkspace = await repository.loadWorkspace(testWorkspace.id);
      verify(repository.loadWorkspace(testWorkspace.id)).called(1);
      
      expect(loadedWorkspace, equals(testWorkspace));
    });
    
    test('Search pages by title', () async {
      final page1 = Page(title: 'Flutter Page');
      final page2 = Page(title: 'Dart Page');
      
      // Setup mock behavior
      when(repository.searchPagesByTitle('Flutter')).thenAnswer((_) async => [page1]);
      
      // Search pages
      final results = await repository.searchPagesByTitle('Flutter');
      verify(repository.searchPagesByTitle('Flutter')).called(1);
      
      expect(results.length, equals(1));
      expect(results[0], equals(page1));
    });
    
    test('Search pages by tag', () async {
      final page1 = Page(title: 'Page 1', tags: ['flutter']);
      final page2 = Page(title: 'Page 2', tags: ['dart']);
      
      // Setup mock behavior
      when(repository.searchPagesByTag('flutter')).thenAnswer((_) async => [page1]);
      
      // Search pages
      final results = await repository.searchPagesByTag('flutter');
      verify(repository.searchPagesByTag('flutter')).called(1);
      
      expect(results.length, equals(1));
      expect(results[0], equals(page1));
    });
  });
}
