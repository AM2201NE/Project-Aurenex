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
  // Returns a writable directory, typically user's LOCALAPPDATA on Windows
  Future<String> getWritableDirectory() async {
    Directory? writableDir;
    String? fallbackPath;
    if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      debugPrint('LOCALAPPDATA: $localAppData');
      writableDir = Directory(join(localAppData ?? '', 'Neonote'));
      debugPrint('Primary writableDir: ${writableDir.path}');
      fallbackPath = join(Platform.environment['USERPROFILE'] ?? '', 'Documents', 'neonote_data');
      debugPrint('Fallback path: $fallbackPath');
    } else {
      writableDir = await getApplicationDocumentsDirectory();
      debugPrint('Non-Windows writableDir: ${writableDir.path}');
    }
    final writablePath = join(writableDir.path, 'neonote_data');
    final rootDir = Directory(writablePath);
    debugPrint('Testing primary writablePath: $writablePath');
    try {
      if (!await rootDir.exists()) {
        debugPrint('Creating rootDir: $writablePath');
        await rootDir.create(recursive: true);
      }
      // Test write permission
      final testFile = File(join(writablePath, 'test_write.txt'));
      debugPrint('Testing write to: ${testFile.path}');
      await testFile.writeAsString('test');
      await testFile.delete();
      debugPrint('Primary writable directory succeeded.');
      return writablePath;
    } catch (e) {
      debugPrint('Primary writable directory failed: $e');
      // Try fallback to Documents
      if (fallbackPath != null) {
        final fallbackDir = Directory(fallbackPath);
        debugPrint('Testing fallbackDir: $fallbackPath');
        try {
          if (!await fallbackDir.exists()) {
            debugPrint('Creating fallbackDir: $fallbackPath');
            await fallbackDir.create(recursive: true);
          }
          final testFile = File(join(fallbackPath, 'test_write.txt'));
          debugPrint('Testing write to fallback: ${testFile.path}');
          await testFile.writeAsString('test');
          await testFile.delete();
          debugPrint('Fallback to Documents succeeded.');
          return fallbackPath;
        } catch (e2) {
          debugPrint('Fallback writable directory also failed: $e2');
        }
      }
      debugPrint('No writable directory found. Please check permissions.');
      throw Exception('No writable directory found. Please check permissions.');
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
    } catch (e) {
      debugPrint('Error opening database at $dbPath: $e');
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
        final blockMap = block.toMap();
        // Defensive: ensure block_id, page_id, type, and content are non-null strings
        blockMap['block_id'] = (blockMap['block_id'] != null && blockMap['block_id'].toString().isNotEmpty && blockMap['block_id'].toString() != 'null') ? blockMap['block_id'].toString() : 'unknown_block_id_${i}_${DateTime.now().millisecondsSinceEpoch}';
        blockMap['page_id'] = (page.id.toString().isNotEmpty && page.id.toString() != 'null') ? page.id.toString() : 'unknown_page_id';
        blockMap['type'] = (blockMap['type'] != null && blockMap['type'].toString().isNotEmpty && blockMap['type'].toString() != 'null') ? blockMap['type'].toString() : 'unknown_type';
        blockMap['content'] = (blockMap['content'] != null) ? blockMap['content'].toString() : '';
        blockMap['metadata'] = (blockMap['metadata'] != null) ? blockMap['metadata'].toString() : '';
        blockMap['position'] = i;
        // Defensive: log blockMap before insert
        debugPrint('Inserting block: $blockMap');
        await txn.insert(
          'blocks',
          blockMap,
          conflictAlgorithm: ConflictAlgorithm.replace
        );
      }
    });
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
      // Defensive: log all fields and types
      workspace.forEach((k, v) {
        debugPrint('Workspace field: $k, type=${v?.runtimeType}, value=$v');
      });
      // Force all workspace fields to default values if null, empty, or invalid
      workspace['id'] = (workspace['id'] is String && workspace['id'] != null && workspace['id'].toString().isNotEmpty && workspace['id'].toString() != 'null') ? workspace['id'].toString() : 'default';
      workspace['name'] = (workspace['name'] is String && workspace['name'] != null && workspace['name'].toString().isNotEmpty && workspace['name'].toString() != 'null') ? workspace['name'].toString() : 'Default Workspace';
      workspace['description'] = (workspace['description'] is String && workspace['description'] != null && workspace['description'].toString().isNotEmpty && workspace['description'].toString() != 'null') ? workspace['description'].toString() : '';
      workspace['createdAt'] = (workspace['createdAt'] is int && workspace['createdAt'] != null) ? workspace['createdAt'] : DateTime.now().millisecondsSinceEpoch;
      workspace['updatedAt'] = (workspace['updatedAt'] is int && workspace['updatedAt'] != null) ? workspace['updatedAt'] : DateTime.now().millisecondsSinceEpoch;
      // Defensive: always encode pages as JSON string
      if (workspace['pages'] == null || workspace['pages'] == '' || workspace['pages'] == 'null') {
        workspace['pages'] = jsonEncode({});
      } else if (workspace['pages'] is String) {
        try {
          final decodedPages = jsonDecode(workspace['pages']);
          if (decodedPages is Map) {
            workspace['pages'] = jsonEncode(decodedPages);
          } else {
            workspace['pages'] = jsonEncode({});
          }
        } catch (e) {
          workspace['pages'] = jsonEncode({});
        }
      } else if (workspace['pages'] is Map) {
        workspace['pages'] = jsonEncode(workspace['pages']);
      } else {
        workspace['pages'] = jsonEncode({});
      }
      // Defensive: always encode pageOrder as JSON string, and ensure all IDs are String
      if (workspace['pageOrder'] == null || workspace['pageOrder'] == '' || workspace['pageOrder'] == 'null') {
        workspace['pageOrder'] = jsonEncode([]);
      } else if (workspace['pageOrder'] is String) {
        try {
          final decodedOrder = jsonDecode(workspace['pageOrder']);
          if (decodedOrder is List) {
            final safeList = decodedOrder.map((e) => e == null ? '' : e.toString()).where((e) => e.isNotEmpty && e != 'null').toList();
            workspace['pageOrder'] = jsonEncode(safeList);
          } else {
            workspace['pageOrder'] = jsonEncode([]);
          }
        } catch (e) {
          workspace['pageOrder'] = jsonEncode([]);
        }
      } else if (workspace['pageOrder'] is List) {
        final safeList = (workspace['pageOrder'] as List).map((e) => e == null ? '' : e.toString()).where((e) => e.isNotEmpty && e != 'null').toList();
        workspace['pageOrder'] = jsonEncode(safeList);
      } else {
        workspace['pageOrder'] = jsonEncode([]);
      }
      // Defensive: always encode settings as JSON string
      if (workspace['settings'] == null || workspace['settings'] == '' || workspace['settings'] == 'null') {
        workspace['settings'] = '{}';
      } else if (workspace['settings'] is String) {
        try {
          final decodedSettings = jsonDecode(workspace['settings']);
          if (decodedSettings is Map) {
            workspace['settings'] = jsonEncode(decodedSettings);
          } else {
            workspace['settings'] = '{}';
          }
        } catch (e) {
          workspace['settings'] = '{}';
        }
      } else if (workspace['settings'] is Map) {
        workspace['settings'] = jsonEncode(workspace['settings']);
      } else {
        workspace['settings'] = '{}';
      }
      // Extra: check for nulls and log
      // Final patch: guarantee pageOrder is always a valid list of strings
      if (workspace['pageOrder'] == null || workspace['pageOrder'] == '' || (workspace['pageOrder'] is String && workspace['pageOrder'] == '[]')) {
        workspace['pageOrder'] = jsonEncode([]);
      } else {
        try {
          List<dynamic> checkList = [];
          if (workspace['pageOrder'] is String) {
            checkList = jsonDecode(workspace['pageOrder']);
          } else if (workspace['pageOrder'] is List) {
            checkList = workspace['pageOrder'];
          }
          final safeList = checkList.map((e) => e == null ? '' : e.toString()).where((e) => e.isNotEmpty && e != 'null').toList();
          workspace['pageOrder'] = jsonEncode(safeList);
        } catch (e) {
          debugPrint('ERROR: Exception during final pageOrder check, forcibly resetting to empty list: $e');
          workspace['pageOrder'] = jsonEncode([]);
        }
      }
      workspace.forEach((k, v) {
        if (v == null || v == '' || v == 'null') debugPrint('Workspace field $k is NULL/empty/invalid!');
      });
      debugPrint('Workspace data after null checks: $workspace');
      // Print stack trace for error analysis
      try {
        throw Exception('Workspace field validation stack trace');
      } catch (e, stack) {
        debugPrint('Workspace field validation stack trace: $stack');
      }
      return workspace;
    } catch (e) {
      debugPrint('Error loading workspace: $e');
      rethrow;
    }
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