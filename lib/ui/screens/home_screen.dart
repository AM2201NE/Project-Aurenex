// This file contains the HomeScreen widget and related functionality.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/workspace.dart';
import '../../models/page.dart' as neonote_page;
import '../../storage/repository.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../widgets/sidebar.dart';
import '../widgets/page_list.dart';
import '../widgets/empty_state.dart';

/// Home screen for the application
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Model asset path and ready flag
  String? _modelPath;
  bool _modelReady = false;
  bool _isLoading = true;
  String? _selectedWorkspaceId;
  String? _selectedPageId;
  List<Workspace> _workspaces = [];

  @override
  void initState() {
    super.initState();
    _loadWorkspaces();
  }

  /// Prepare Qwen2-VL-2B model asset: copy from assets to writable path
  Future<String> prepareModelAsset() async {
    debugPrint('prepareModelAsset: Copying Qwen2-VL-2B asset to writable path...');
    const assetPath = 'assets/ai_model/Qwen2-VL-2B-Instruct-Q4_K_M.gguf';
    final data = await rootBundle.load(assetPath);
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/qwen2-vl-2b-instruct.gguf');
    if (!await file.exists()) {
      await file.writeAsBytes(data.buffer.asUint8List());
      debugPrint('prepareModelAsset: Asset copied to ${file.path}');
    } else {
      debugPrint('prepareModelAsset: Asset already exists at ${file.path}');
    }
    return file.path;
  }

  /// Initialize Qwen2-VL-2B model via FFI and mark as ready only on success
  Future<void> initializeModelFFI(String modelPath) async {
    debugPrint('initializeModelFFI: Initializing Qwen2-VL-2B model at $modelPath...');
    final initResult = await QwenFFI.initialize(modelPath, {/* config */});
    if (initResult == null || !(initResult.success ?? false)) {
      // Handle initialization failure
    }
  }

  /// Full model setup: copy asset, initialize FFI, mark ready
  Future<void> setupModel() async {
    try {
      _modelPath = await prepareModelAsset();
      await initializeModelFFI(_modelPath!);
      debugPrint('setupModel: Model is ready and path is $_modelPath');
    } catch (e, stack) {
      debugPrint('setupModel: ERROR: $e');
      debugPrint('setupModel: Stack: $stack');
      _modelReady = false;
    }
  }

  /// Load workspaces from repository
  Future<void> _loadWorkspaces() async {
    debugPrint('Loading workspaces: logging modelPath and ready flags...');
    final repository = Provider.of<Repository>(context, listen: false);
    try {
      final workspaces = await repository.listWorkspaces();
      final sanitizedWorkspaces = <Workspace>[];
      for (final ws in workspaces) {
        debugPrint('Loaded workspace: id=${ws.id}, name=${ws.name}, pageOrder=${ws.pageOrder.runtimeType}=${ws.pageOrder}, pages=${ws.pages.runtimeType}, settings=${ws.settings.runtimeType}');
        // Always reconstruct pageOrder from valid page IDs in pages
        ws.pageOrder = ws.pages?.keys.map((k) => k.toString()).where((k) => k.isNotEmpty && k != 'null').toList() ?? <String>[];
        sanitizedWorkspaces.add(ws);
      }
      setState(() {
        _workspaces = sanitizedWorkspaces;
        _isLoading = false;
        if (sanitizedWorkspaces.isNotEmpty) {
          _selectedWorkspaceId = sanitizedWorkspaces.first.id;
        }
      });
    } catch (e, stack) {
      debugPrint('Failed to load workspaces: $e');
      debugPrint('Error stack: $stack');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Create a new workspace
  Future<void> _createWorkspace() async {
    await setupModel();
    debugPrint('Creating workspace with modelPath=$_modelPath, modelReady=$_modelReady');
    final repository = Provider.of<Repository>(context, listen: false);
    final workspace = Workspace(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'New Workspace',
      description: 'Created on ${DateTime.now().toLocal()}',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      pages: {},
      pageOrder: [],
      settings: {},
    );
    try {
      await repository.saveWorkspace(workspace);
      setState(() {
        _workspaces.add(workspace);
        _selectedWorkspaceId = workspace.id;
        _selectedPageId = null;
      });
    } catch (e) {
      debugPrint('Failed to create workspace: $e');
    }
  }

  /// Create a new page
  Future<void> _createPage() async {
    debugPrint('Creating page: modelPath=$_modelPath, modelReady=$_modelReady');
    if (_selectedWorkspaceId == null) return;
    final repository = Provider.of<Repository>(context, listen: false);
    final workspace = _workspaces.firstWhere((w) => w.id == _selectedWorkspaceId);
    final page = neonote_page.Page(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Page',
      description: '',
      tags: [],
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      filePath: '',
      blocks: {},
      blockOrder: [],
    );
    try {
      workspace.addPage(page);
      await repository.saveWorkspace(workspace);
      setState(() {
        _selectedPageId = page.id;
      });
      _openEditor(page);
    } catch (e) {
      debugPrint('Failed to create page: $e');
    }
  }

  /// Open the editor for a page
  void _openEditor(neonote_page.Page page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditorScreen(page: page),
      ),
    ).then((_) {
      _loadWorkspaces();
    });
  }

  /// Get the selected workspace
  Workspace? get _selectedWorkspace {
    if (_selectedWorkspaceId == null) return null;
    try {
      final ws = _workspaces.firstWhere((w) => w.id == _selectedWorkspaceId);
      // Force all fields to robust defaults
      ws.name = (ws.name != null && ws.name!.isNotEmpty && ws.name != 'null') ? ws.name : 'Default Workspace';
      ws.description = (ws.description != null && ws.description!.isNotEmpty && ws.description != 'null') ? ws.description : '';
      ws.pages = ws.pages ?? {};
      ws.pageOrder = (ws.pageOrder ?? <String>[]).where((e) => e != null && e.toString().isNotEmpty && e.toString() != 'null').map((e) => e.toString()).toList();
      ws.settings = ws.settings ?? {};
      debugPrint('Selected workspace: id=${ws.id}, name=${ws.name}, pageOrder=${ws.pageOrder.runtimeType}=${ws.pageOrder}, pages=${ws.pages.runtimeType}, settings=${ws.settings.runtimeType}');
      return ws;
    } catch (e, stack) {
      debugPrint('Error finding selected workspace: $e');
      debugPrint('Error stack: $stack');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neonote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Open settings
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPage,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build the main content
  Widget _buildContent() {
    if (_workspaces.isEmpty) {
      return EmptyState(
        title: 'No Workspaces',
        message: 'Create a workspace to get started',
        buttonText: 'Create Workspace',
        onButtonPressed: _createWorkspace,
      );
    }
    return Row(
      children: [
        SizedBox(
          width: 250,
          child: Sidebar(
            workspaces: _workspaces,
            selectedWorkspaceId: _selectedWorkspaceId,
            onWorkspaceSelected: (id) {
              setState(() {
                _selectedWorkspaceId = id;
                _selectedPageId = null;
              });
            },
            onCreateWorkspace: _createWorkspace,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _selectedWorkspace != null
              ? PageList(
                  workspace: _selectedWorkspace!,
                  selectedPageId: _selectedPageId,
                  onPageSelected: (id) {
                    setState(() {
                      _selectedPageId = id;
                    });
                    final page = _selectedWorkspace!.pages != null ? _selectedWorkspace!.pages![id] : null;
                    if (page != null) {
                      _openEditor(page);
                    }
                  },
                  onCreatePage: _createPage,
                )
              : const EmptyState(
                  title: 'No Workspace Selected',
                  message: 'Select a workspace to view pages',
                ),
        ),
      ],
    );
  }

}
