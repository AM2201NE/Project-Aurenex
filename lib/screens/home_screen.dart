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
import '../config.dart';

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
      aiModel = LlamaCpp(AppConfig.modelPath);
    } catch (e) {
      debugPrint('AI model failed to load: $e');
      aiModel = null;
    }
    _loadWorkspace();
  }
  
  Future<void> _loadWorkspace() async {
    try {
      _pages = await widget.storageService.getAllPages();
      _workspace = await _loadAndParseWorkspace(pages: _pages);
    } on Exception catch (e) {
      debugPrint('A known error occurred while loading workspace: $e');
      _showErrorDialog('Error Loading Workspace', e.toString());
      _workspace = _createDefaultWorkspace();
    } catch (e) {
      debugPrint('An unexpected error occurred while loading workspace: $e');
      _showErrorDialog('Unexpected Error', 'An unexpected error occurred. Please try again.');
      _workspace = _createDefaultWorkspace();
    }
    setState(() {});
  }

  Workspace _createDefaultWorkspace() {
    return Workspace(
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

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<Workspace> _loadAndParseWorkspace({
    String? directoryOverride,
    required List<page_model.Page> pages,
  }) async {
    final workspaceData = await widget.storageService.getWorkspaceData('default', directoryOverride: directoryOverride);
    if (workspaceData.isEmpty) {
      throw Exception('Workspace data is empty');
    }

    final pagesMap = <String, page_model.Page>{};
    for (final page in pages) {
      pagesMap[page.id] = page;
    }
    workspaceData['pages'] = pagesMap;

    // Defensive decoding and sanitization
    _sanitizeWorkspaceData(workspaceData);

    return Workspace.fromMap(workspaceData);
  }

  void _sanitizeWorkspaceData(Map<String, dynamic> data) {
    // Pages
    if (data['pages'] is String) {
      try {
        data['pages'] = data['pages'] != '' ? jsonDecode(data['pages']) : {};
      } catch (e) {
        debugPrint('Error decoding pages: $e');
        data['pages'] = {};
      }
    }
    if (data['pages'] == null || data['pages'] is! Map) {
      data['pages'] = {};
    }

    // Page Order
    var rawPageOrder = data['pageOrder'];
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
      if (e != null) {
        final str = e.toString();
        if (str.isNotEmpty && str != 'null') {
          sanitizedList.add(str);
        }
      }
    }
    data['pageOrder'] = sanitizedList;

    // Settings
    if (data['settings'] is String) {
      try {
        data['settings'] = data['settings'] != '' ? jsonDecode(data['settings']) : {};
      } catch (e) {
        debugPrint('Error decoding settings: $e');
        data['settings'] = {};
      }
    }
    if (data['settings'] == null || data['settings'] is! Map) {
      data['settings'] = {};
    }

    // Other fields
    data['id'] = data['id']?.toString() ?? 'default';
    data['name'] = data['name']?.toString() ?? 'Default Workspace';
    data['createdAt'] = data['createdAt'] is int
        ? data['createdAt']
        : int.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch;
    data['updatedAt'] = data['updatedAt'] is int
        ? data['updatedAt']
        : int.tryParse(data['updatedAt']?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch;
    data['description'] = data['description']?.toString() ?? '';
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
                final page = _pages.firstWhere((p) => p.id == pageId);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PageEditorScreen(page: page),
                  ),
                );
              },
              onCreatePage: () {
                final newPage = page_model.Page(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: 'Untitled',
                  content: [RichTextBlock(text: '')],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                setState(() {
                  _pages.add(newPage);
                });
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PageEditorScreen(page: newPage),
                  ),
                );
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
