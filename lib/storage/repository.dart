import 'package:sqflite/sqflite.dart';
import '../models/page.dart';
import '../models/workspace.dart';
import '../models/blocks/base_block.dart';

class Repository {
  final Future<Database> _database;

  Repository(this._database);

  Future<void> saveWorkspace(Workspace workspace) async {
    final db = await _database;
    await db.insert(
      'workspaces',
      workspace.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Workspace?> loadWorkspace(String id) async {
    final db = await _database;
    final maps = await db.query(
      'workspaces',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Workspace.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Workspace>> listWorkspaces() async {
    final db = await _database;
    final maps = await db.query('workspaces');
    return maps.map((map) => Workspace.fromMap(map)).toList();
  }

  Future<void> deleteWorkspace(String id) async {
    final db = await _database;
    await db.delete(
      'workspaces',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> savePage(Page page) async {
    final db = await _database;
    await db.insert(
      'pages',
      page.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (final block in page.blocks.values) {
      await db.insert(
        'blocks',
        block.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<Page?> loadPage(String id) async {
    final db = await _database;
    final maps = await db.query(
      'pages',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final page = Page.fromMap(maps.first);
      final blocks = await _loadBlocksForPage(id);
      return page.copyWith(blocks: blocks);
    }
    return null;
  }

  Future<List<Page>> listPages() async {
    final db = await _database;
    final maps = await db.query('pages');
    final pages = <Page>[];
    for (final map in maps) {
      final page = Page.fromMap(map);
      final blocks = await _loadBlocksForPage(page.id);
      pages.add(page.copyWith(blocks: blocks));
    }
    return pages;
  }

  Future<Map<String, Block>> _loadBlocksForPage(String pageId) async {
    final db = await _database;
    final maps = await db.query(
      'blocks',
      where: 'parentId = ?',
      whereArgs: [pageId],
    );

    final blocks = <String, Block>{};
    for (final map in maps) {
      final block = Block.fromMap(map);
      blocks[block.id] = block;
    }
    return blocks;
  }

  Future<void> deletePage(String id) async {
    final db = await _database;
    await db.delete(
      'pages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Page>> searchPagesByTitle(String query) async {
    final db = await _database;
    final maps = await db.query(
      'pages',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );

    final pages = <Page>[];
    for (final map in maps) {
      final page = Page.fromMap(map);
      final blocks = await _loadBlocksForPage(page.id);
      pages.add(page.copyWith(blocks: blocks));
    }
    return pages;
  }

  Future<List<Page>> searchPagesByTag(String tag) async {
    final db = await _database;
    final maps = await db.query(
      'pages',
      where: 'tags LIKE ?',
      whereArgs: ['%$tag%'],
    );

    final pages = <Page>[];
    for (final map in maps) {
      final page = Page.fromMap(map);
      final blocks = await _loadBlocksForPage(page.id);
      pages.add(page.copyWith(blocks: blocks));
    }
    return pages;
  }
}
