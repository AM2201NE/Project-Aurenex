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
  Workspace? _workspace;
  List<page_model.Page> _pages = [];
  LlamaCpp? aiModel;
  bool _isLoading = true;
  String? _errorMessage;
  
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _pages = await widget.storageService.getAllPages();
      _workspace = await _loadAndParseWorkspace(pages: _pages);
    } on Exception catch (e) {
      debugPrint('A known error occurred while loading workspace: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } catch (e) {
      debugPrint('An unexpected error occurred while loading workspace: $e');
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

    return Workspace.fromMap(workspaceData);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadWorkspace,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
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
