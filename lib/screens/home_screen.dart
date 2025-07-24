import 'package:flutter/material.dart' hide Page;
import '../services/storage_service.dart';
import '../services/theme_service.dart';
import '../models/page.dart' as page_model;
import '../models/workspace.dart';
import '../models/blocks/rich_text_block.dart';
import 'ai_chat_screen.dart';
import 'dashboard_screen.dart';
import 'page_editor_screen.dart';
import '../ffi/llama_ffi.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  final ThemeService themeService;
  
  const HomeScreen({
    super.key,
    required this.storageService,
    required this.themeService,
  });
  
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Workspace _workspace;
  List<page_model.Page> _pages = [];
  LlamaCpp? aiModel;
  
  @override
  void initState() {
    super.initState();
    try {
      // Use absolute path for Windows
      final modelPath = r'C:\Users\nsc\Desktop\notion_offline - Copie\assets\ai_model\Qwen2-VL-2B-Instruct-Q4_K_M.gguf';
      aiModel = LlamaCpp(modelPath);
    } catch (e) {
      debugPrint('AI model failed to load: $e');
      aiModel = null;
    }
    _loadWorkspace();
  }
  
  Future<void> _loadWorkspace() async {
    try {
      // Try loading workspace data from default location
      final workspaceData = await widget.storageService.getWorkspaceData('default');
      if (workspaceData.isEmpty) {
        throw Exception('Workspace data is empty');
      }
      // Defensive: ensure required keys exist and are not null and correct type
      debugPrint('Raw workspaceData:');
      workspaceData.forEach((k, v) {
        debugPrint('  $k: ${v.runtimeType} = $v');
      });

      // Defensive decode for pages
      debugPrint('Before decode pages: ${workspaceData['pages']} (${workspaceData['pages'].runtimeType})');
      if (workspaceData['pages'] is String) {
        try {
          workspaceData['pages'] = workspaceData['pages'] != '' ? jsonDecode(workspaceData['pages']) : {};
          debugPrint('After decode pages: ${workspaceData['pages']} (${workspaceData['pages'].runtimeType})');
        } catch (e) {
          debugPrint('Error decoding pages: $e');
          workspaceData['pages'] = {};
        }
      }
      if (workspaceData['pages'] == null || workspaceData['pages'] is! Map) {
        debugPrint('Pages is null or not a Map, setting to empty map');
        workspaceData['pages'] = {};
      }
      debugPrint('Final pages: ${workspaceData['pages']} (${workspaceData['pages'].runtimeType})');

      // Defensive decode for pageOrder
      debugPrint('Before decode pageOrder: ${workspaceData['pageOrder']} (${workspaceData['pageOrder'].runtimeType})');
      var rawPageOrder = workspaceData['pageOrder'];
      if (rawPageOrder is String) {
        try {
          rawPageOrder = rawPageOrder.isNotEmpty ? jsonDecode(rawPageOrder) : [];
          debugPrint('After decode pageOrder: $rawPageOrder (${rawPageOrder.runtimeType})');
        } catch (e) {
          debugPrint('Error decoding pageOrder: $e');
          rawPageOrder = [];
        }
      }
      if (rawPageOrder == null || rawPageOrder is! List) {
        debugPrint('PageOrder is null or not a List, setting to empty list');
        rawPageOrder = [];
      }
      // Defensive: Only allow non-null, non-empty strings, forcibly convert all entries to String
      List<String> safePageOrder = [];
      for (var e in rawPageOrder) {
        if (e == null) {
          debugPrint('pageOrder entry is null, skipping');
          continue;
        }
        String str = e.toString();
        if (str.isNotEmpty && str != 'null') {
          safePageOrder.add(str);
        } else {
          debugPrint('pageOrder entry is not a valid string: $e');
        }
      }
      debugPrint('DEBUG: safePageOrder after initial conversion: $safePageOrder');
      workspaceData['pageOrder'] = safePageOrder;
      // Final check: if any entry in pageOrder is not a string, reset to empty and log error
      if (workspaceData['pageOrder'] is List) {
        bool allStrings = true;
        for (var e in workspaceData['pageOrder']) {
          if (e == null || e is! String || e == '' || e == 'null') {
            allStrings = false;
            debugPrint('ERROR: pageOrder entry is not a valid String before Workspace.fromMap: type=${e?.runtimeType}, value=$e');
          }
        }
        if (!allStrings) {
          debugPrint('ERROR: Forcibly resetting pageOrder to empty list before Workspace.fromMap due to invalid entry.');
          workspaceData['pageOrder'] = <String>[];
        }
      }
      debugPrint('Final pageOrder before Workspace.fromMap: ${workspaceData['pageOrder']} (${workspaceData['pageOrder'].runtimeType})');

      // Defensive decode for settings
      debugPrint('Before decode settings: ${workspaceData['settings']} (${workspaceData['settings'].runtimeType})');
      if (workspaceData['settings'] is String) {
        try {
          workspaceData['settings'] = workspaceData['settings'] != '' ? jsonDecode(workspaceData['settings']) : {};
          debugPrint('After decode settings: ${workspaceData['settings']} (${workspaceData['settings'].runtimeType})');
        } catch (e) {
          debugPrint('Error decoding settings: $e');
          workspaceData['settings'] = {};
        }
      }
      if (workspaceData['settings'] == null || workspaceData['settings'] is! Map) {
        debugPrint('Settings is null or not a Map, setting to empty map');
        workspaceData['settings'] = {};
      }
      debugPrint('Final settings: ${workspaceData['settings']} (${workspaceData['settings'].runtimeType})');

      workspaceData['id'] = (workspaceData['id'] is String && workspaceData['id'] != null)
        ? workspaceData['id']
        : (workspaceData['id'] != null ? workspaceData['id'].toString() : 'default');
      workspaceData['name'] = (workspaceData['name'] is String && workspaceData['name'] != null)
        ? workspaceData['name']
        : (workspaceData['name'] != null ? workspaceData['name'].toString() : 'Default Workspace');
      workspaceData['createdAt'] = (workspaceData['createdAt'] is int && workspaceData['createdAt'] != null)
        ? workspaceData['createdAt']
        : (workspaceData['createdAt'] != null ? int.tryParse(workspaceData['createdAt'].toString()) ?? DateTime.now().millisecondsSinceEpoch : DateTime.now().millisecondsSinceEpoch);
      workspaceData['updatedAt'] = (workspaceData['updatedAt'] is int && workspaceData['updatedAt'] != null)
        ? workspaceData['updatedAt']
        : (workspaceData['updatedAt'] != null ? int.tryParse(workspaceData['updatedAt'].toString()) ?? DateTime.now().millisecondsSinceEpoch : DateTime.now().millisecondsSinceEpoch);
      workspaceData['description'] = (workspaceData['description'] is String && workspaceData['description'] != null)
        ? workspaceData['description']
        : (workspaceData['description'] != null ? workspaceData['description'].toString() : '');
      // Final check: if any entry in pageOrder is not a string, reset to empty and log error
      if (workspaceData['pageOrder'] is List) {
        final sanitizedList = <String>[];
        for (var e in workspaceData['pageOrder']) {
          if (e == null) {
            debugPrint('ERROR: pageOrder entry is null before Workspace.fromMap, skipping');
            continue;
          }
          final str = e.toString();
          if (str.isNotEmpty && str != 'null') {
            sanitizedList.add(str);
          } else {
            debugPrint('ERROR: pageOrder entry is not a valid string before Workspace.fromMap: type=${e.runtimeType}, value=$e');
          }
        }
        workspaceData['pageOrder'] = sanitizedList;
      }
      _workspace = Workspace.fromMap(workspaceData);

      // Load pages
      _pages = await widget.storageService.getAllPages();

      // Update workspace with pages
      final pagesMap = <String, page_model.Page>{};
      for (final page in _pages) {
        pagesMap[page.id] = page;
      }

      _workspace = _workspace.copyWith(pages: pagesMap);
    } catch (e) {
      debugPrint('Error loading workspace: $e');
      // If error is read-only, fallback to user Documents directory
      if (e.toString().contains('read-only')) {
        try {
          final documentsDir = await widget.storageService.getWritableDirectory();
          debugPrint('Falling back to writable directory: $documentsDir');
          final workspaceData = await widget.storageService.getWorkspaceDataWithDirectory('default', directoryOverride: documentsDir);
          if (workspaceData.isEmpty) {
            throw Exception('Workspace data is empty (writable fallback)');
          }
          debugPrint('Raw workspaceData:');
          workspaceData.forEach((k, v) {
            debugPrint('  $k: ${v.runtimeType} = $v');
          });

          // Defensive decode for pages
          if (workspaceData['pages'] is String) {
            try {
              workspaceData['pages'] = workspaceData['pages'] != '' ? jsonDecode(workspaceData['pages']) : {};
            } catch (e) {
              debugPrint('Error decoding pages: $e');
              workspaceData['pages'] = {};
            }
          }
          if (workspaceData['pages'] == null || workspaceData['pages'] is! Map) {
            workspaceData['pages'] = {};
          }

          // Defensive decode for pageOrder
          var rawPageOrder = workspaceData['pageOrder'];
          if (rawPageOrder is String) {
            try {
              rawPageOrder = rawPageOrder.isNotEmpty ? jsonDecode(rawPageOrder) : [];
            } catch (e) {
              debugPrint('Error decoding pageOrder: $e');
              rawPageOrder = [];
            }
          }
          if (rawPageOrder == null || rawPageOrder is! List) {
            rawPageOrder = [];
          }
          final sanitizedList = <String>[];
          for (var e in rawPageOrder) {
            if (e == null) {
              debugPrint('ERROR: pageOrder entry is null before Workspace.fromMap (fallback), skipping');
              continue;
            }
            final str = e.toString();
            if (str.isNotEmpty && str != 'null') {
              sanitizedList.add(str);
            } else {
              debugPrint('ERROR: pageOrder entry is not a valid string before Workspace.fromMap (fallback): type=${e.runtimeType}, value=$e');
            }
          }
          workspaceData['pageOrder'] = sanitizedList;

          // Defensive decode for settings
          if (workspaceData['settings'] is String) {
            try {
              workspaceData['settings'] = workspaceData['settings'] != '' ? jsonDecode(workspaceData['settings']) : {};
            } catch (e) {
              debugPrint('Error decoding settings: $e');
              workspaceData['settings'] = {};
            }
          }
          if (workspaceData['settings'] == null || workspaceData['settings'] is! Map) {
            workspaceData['settings'] = {};
          }

          workspaceData['id'] = (workspaceData['id'] is String && workspaceData['id'] != null) ? workspaceData['id'] : 'default';
          workspaceData['name'] = (workspaceData['name'] is String && workspaceData['name'] != null) ? workspaceData['name'] : 'Default Workspace';
          workspaceData['createdAt'] = (workspaceData['createdAt'] is int && workspaceData['createdAt'] != null) ? workspaceData['createdAt'] : DateTime.now().millisecondsSinceEpoch;
          workspaceData['updatedAt'] = (workspaceData['updatedAt'] is int && workspaceData['updatedAt'] != null) ? workspaceData['updatedAt'] : DateTime.now().millisecondsSinceEpoch;
          workspaceData['description'] = (workspaceData['description'] is String && workspaceData['description'] != null) ? workspaceData['description'] : '';
          _workspace = Workspace.fromMap(workspaceData);

          // Load pages
          _pages = await widget.storageService.getAllPagesWithDirectory(directoryOverride: documentsDir);

          // Update workspace with pages
          final pagesMap = <String, page_model.Page>{};
          for (final page in _pages) {
            pagesMap[page.id] = page;
          }

          _workspace = _workspace.copyWith(pages: pagesMap);
        } catch (e2) {
          debugPrint('Writable fallback also failed: $e2');
          _workspace = Workspace(
            id: 'default',
            name: 'Default Workspace',
            pages: {},
            pageOrder: [],
            createdAt: DateTime.now().millisecondsSinceEpoch,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
            description: '',
            settings: {},
          );
        }
      }
    }
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: DashboardScreen(
              pages: _pages,
              onOpenPage: (pageId) {
                // Implement page open logic here
              },
              onCreatePage: () {
                // Implement page creation logic here
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('AI Chat'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AIChatScreen(
                      onSendPrompt: (prompt) async {
                        if (aiModel != null) {
                          try {
                            return await Future(() => aiModel!.generate(prompt));
                          } catch (e) {
                            return 'AI error: $e';
                          }
                        } else {
                          return 'AI model not loaded.';
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
