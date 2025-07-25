import 'dart:io';
import 'dart:convert'; // Added for JSON serialization
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/blocks/base_block.dart';
import '../models/blocks/block_factory.dart';
import '../models/page.dart';

class StorageService {
  Future<String> getWritableDirectory() async {
    final List<Future<String?>> potentialPaths = [
      _getPrimaryPath(),
      _getFallbackPath(),
    ];

    for (final futurePath in potentialPaths) {
      final path = await futurePath;
      if (path != null && await _isWritable(path)) {
        return path;
      }
    }

    throw Exception('No writable directory found. Please check permissions.');
  }

  Future<String?> _getPrimaryPath() async {
    if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null) {
        return join(localAppData, 'Neonote', 'neonote_data');
      }
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      return join(appDir.path, 'neonote_data');
    }
    return null;
  }

  Future<String?> _getFallbackPath() async {
    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        return join(userProfile, 'Documents', 'neonote_data');
      }
    }
    return null;
  }

  Future<bool> _isWritable(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final testFile = File(join(path, 'test_write.txt'));
      await testFile.writeAsString('test');
      await testFile.delete();
      return true;
    } catch (e) {
      debugPrint('Path is not writable: $path, error: $e');
      return false;
    }
  }

  // For fallback: get database at custom directory
  Future<Database> getDatabaseAt(String customPath) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dbPath = join(customPath, 'neonote.db');
    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDatabase,
    );
    await db.execute('PRAGMA journal_mode = WAL');
    await db.execute('PRAGMA synchronous = NORMAL');
    await db.execute('PRAGMA cache_size = 1000');
    return db;
  }
  static final StorageService _instance = StorageService._internal();

  factory StorageService() => _instance;

  StorageService._internal();

  Database? _database;
  String? _rootPath;

  Future<String> get rootPath async {
    if (_rootPath != null) return _rootPath!;

    final directory = await getApplicationDocumentsDirectory();
    _rootPath = join(directory.path, 'neonote_data');

    // Create root directory if it doesn't exist
    final rootDir = Directory(_rootPath!);
    if (!await rootDir.exists()) {
      await rootDir.create(recursive: true);
    }

    return _rootPath!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _init();
    return _database!;
  }

  Future<Database> _init() async {
    // Initialize FFI for desktop platforms
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    try {
      debugPrint('Calling getWritableDirectory...');
      path = await getWritableDirectory();
      debugPrint('Writable directory selected: $path');
    } catch (e) {
      debugPrint('No writable directory found: $e');
      rethrow;
    }
    final dbPath = join(path, 'neonote.db');
    debugPrint('Opening database at: $dbPath');
    try {
      final db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: _createDatabase,
      );
      debugPrint('Database opened successfully.');
      await db.execute('PRAGMA journal_mode = WAL');
      await db.execute('PRAGMA synchronous = NORMAL');
      await db.execute('PRAGMA cache_size = 1000');
      return db;
    } on DatabaseException catch (e) {
      debugPrint('A database error occurred while opening the database at $dbPath: $e');
      rethrow;
    } catch (e) {
      debugPrint('An unexpected error occurred while opening the database at $dbPath: $e');
      rethrow;
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create pages table
    await db.execute('''
      CREATE TABLE pages (
        page_id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        tags TEXT,
        created INTEGER NOT NULL,
        updated INTEGER NOT NULL,
        filepath TEXT NOT NULL
      )
    ''');

    // Create blocks table
    await db.execute('''
      CREATE TABLE blocks (
        block_id TEXT PRIMARY KEY,
        page_id TEXT NOT NULL,
        type TEXT NOT NULL,
        content TEXT,
        metadata TEXT,
        position INTEGER NOT NULL,
        parent_id TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (page_id) REFERENCES pages (page_id) ON DELETE CASCADE
      )
    ''');

    // Create workspaces table
    await db.execute('''
      CREATE TABLE workspaces (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        createdAt INTEGER,
        updatedAt INTEGER,
        pages TEXT,
        pageOrder TEXT,
        settings TEXT
      )
    ''');

    // Create default workspace
    await db.insert('workspaces', {
      'id': 'default',
      'name': 'Default Workspace',
      'description': '',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'pages': '',
      'pageOrder': '',
      'settings': '{}'
    });
  }

  // --- Page Operations ---

  Future<List<Page>> getAllPages() async {
    return getAllPagesWithDirectory();
  }

  Future<List<Page>> getAllPagesWithDirectory({String? directoryOverride}) async {
    final db = directoryOverride == null ? await database : await getDatabaseAt(directoryOverride);
    final pagesData = await db.query('pages');

    final pages = <Page>[];
    for (final pageData in pagesData) {
      final page = Page.fromMap(pageData);
      // Defensive: ensure page.id is a non-null, non-empty string
      final safePageId = (page.id.toString().isNotEmpty && page.id.toString() != 'null') ? page.id.toString() : '';

      // Load blocks for this page
      final blocksData = await db.query(
        'blocks',
        where: 'page_id = ?',
        whereArgs: [safePageId],
        orderBy: 'position ASC'
      );

      final blocks = blocksData.map((blockData) {
        // Defensive: ensure block_id is a non-null, non-empty string
        if (blockData['block_id'] == null || blockData['block_id'].toString().isEmpty || blockData['block_id'].toString() == 'null') {
          debugPrint('StorageService: Invalid block_id in blockData: $blockData');
          return null;
        }
        return blockFromMap(blockData);
      }).whereType<Block>().toList();

      pages.add(page.copyWith(blocksList: blocks as List<Block>?));
    }

    return pages;
  }

  Future<Page?> getPage(String id) async {
    final db = await database;
    final pagesData = await db.query(
      'pages',
      where: 'page_id = ?',
      whereArgs: [id]
    );

    if (pagesData.isEmpty) return null;

    final page = Page.fromMap(pagesData.first);

    // Load blocks for this page
    final blocksData = await db.query(
      'blocks',
      where: 'page_id = ?',
      whereArgs: [id],
      orderBy: 'position ASC'
    );

    final blocks = blocksData.map((blockData) => blockFromMap(blockData)).toList();

    return page.copyWith(blocksList: blocks as List<Block>?);
  }

  Future<void> savePage(Page page) async {
    final db = await database;

    // Start a transaction
    await db.transaction((txn) async {
      // Save page metadata
      await txn.insert(
        'pages',
        page.toMetadataMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
      );

      // Delete existing blocks for this page
      await txn.delete(
        'blocks',
        where: 'page_id = ?',
        whereArgs: [page.id]
      );

      // Save blocks
      for (int i = 0; i < page.blocks.length; i++) {
        final block = page.blocks.values.elementAt(i);
        final blockMap = _sanitizeBlockData(block.toMap(), page.id, i);
        await txn.insert(
          'blocks',
          blockMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Map<String, dynamic> _sanitizeBlockData(Map<String, dynamic> blockMap, String pageId, int position) {
    blockMap['block_id'] = blockMap['block_id']?.toString() ?? 'unknown_block_id_${position}_${DateTime.now().millisecondsSinceEpoch}';
    blockMap['page_id'] = pageId;
    blockMap['type'] = blockMap['type']?.toString() ?? 'unknown_type';
    blockMap['content'] = blockMap['content']?.toString() ?? '';
    blockMap['metadata'] = blockMap['metadata']?.toString() ?? '';
    blockMap['position'] = position;
    return blockMap;
  }

  Future<void> deletePage(String id) async {
    final db = await database;

    // Delete page (blocks will be deleted via CASCADE)
    await db.delete(
      'pages',
      where: 'page_id = ?',
      whereArgs: [id]
    );
  }

  // --- Workspace Operations ---

  Future<Map<String, dynamic>> getWorkspaceData(String id) async {
    return getWorkspaceDataWithDirectory(id);
  }

  Future<Map<String, dynamic>> getWorkspaceDataWithDirectory(String id, {String? directoryOverride}) async {
    debugPrint('getWorkspaceDataWithDirectory: id=$id, directoryOverride=$directoryOverride');
    final db = directoryOverride == null ? await database : await getDatabaseAt(directoryOverride);
    debugPrint('Database instance acquired for workspace.');
    try {
      final workspacesData = await db.query(
        'workspaces',
        where: 'id = ?',
        whereArgs: [id]
      );
      debugPrint('Workspace query result: ${workspacesData.length} rows');
      if (workspacesData.isEmpty) {
        debugPrint('No workspace found, returning default workspace.');
        return {
          'id': 'default',
          'name': 'Default Workspace',
          'description': '',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
          'pages': '',
          'pageOrder': '',
          'settings': '{}'
        };
      }
      debugPrint('Returning workspace data: ${workspacesData.first}');
      // Defensive copy to ensure mutability and fix type errors
      final workspace = Map<String, dynamic>.from(workspacesData.first);
      _sanitizeWorkspaceData(workspace);
      return workspace;
    } catch (e) {
      debugPrint('Error loading workspace: $e');
      rethrow;
    }
  }

  void _sanitizeWorkspaceData(Map<String, dynamic> data) {
    data['id'] = data['id']?.toString() ?? 'default';
    data['name'] = data['name']?.toString() ?? 'Default Workspace';
    data['description'] = data['description']?.toString() ?? '';
    data['createdAt'] = data['createdAt'] is int ? data['createdAt'] : DateTime.now().millisecondsSinceEpoch;
    data['updatedAt'] = data['updatedAt'] is int ? data['updatedAt'] : DateTime.now().millisecondsSinceEpoch;
    data['pages'] = _sanitizeJsonField(data['pages'], {});
    data['pageOrder'] = _sanitizeJsonField(data['pageOrder'], []);
    data['settings'] = _sanitizeJsonField(data['settings'], {});
  }

  String _sanitizeJsonField(dynamic value, dynamic defaultValue) {
    if (value == null || value == '' || value == 'null') {
      return jsonEncode(defaultValue);
    }
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map || decoded is List) {
          return jsonEncode(decoded);
        }
      } catch (e) {
        // fall through to default
      }
    }
    if (value is Map || value is List) {
      return jsonEncode(value);
    }
    return jsonEncode(defaultValue);
  }

  Future<void> saveWorkspaceData(Map<String, dynamic> data) async {
    final db = await database;

    // Serialize unsupported types to JSON strings
    final safeData = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is Map || value is List) {
        safeData[key] = jsonEncode(value); // Convert Map/List to JSON string
      } else {
        safeData[key] = value;
      }
    });

    await db.insert(
      'workspaces',
      safeData,
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  // --- File Operations ---

  Future<String> getPageFilePath(String pageId) async {
    final path = await rootPath;
    return join(path, 'pages', pageId);
  }

  Future<File> saveFile(String pageId, String filename, List<int> bytes) async {
    final pagePath = await getPageFilePath(pageId);

    // Create page directory if it doesn't exist
    final pageDir = Directory(pagePath);
    if (!await pageDir.exists()) {
      await pageDir.create(recursive: true);
    }

    final filePath = join(pagePath, filename);
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return file;
  }

  Future<List<int>> readFile(String pageId, String filename) async {
    final pagePath = await getPageFilePath(pageId);
    final filePath = join(pagePath, filename);
    final file = File(filePath);

    return await file.readAsBytes();
  }

  Future<bool> deleteFile(String pageId, String filename) async {
    final pagePath = await getPageFilePath(pageId);
    final filePath = join(pagePath, filename);
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
      return true;
    }

    return false;
  }
}