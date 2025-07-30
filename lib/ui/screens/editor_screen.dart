import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/page.dart';
import '../../models/blocks/base_block.dart';
import '../../models/blocks/text_blocks.dart';
import '../../models/blocks/list_blocks.dart';
import '../../models/blocks/todo_block.dart';
import '../../models/blocks/code_block.dart';
import '../../models/blocks/quote_block.dart';
import '../../models/blocks/divider_block.dart';
import '../../models/blocks/heading_block.dart';
import '../../storage/repository.dart';
import '../../services/ai_service.dart';
import '../widgets/block_editor.dart';
import '../widgets/toolbar.dart';
import '../widgets/ai_assistant_panel.dart';

/// Editor screen for editing a page
class EditorScreen extends StatefulWidget {
  final Page page;

  const EditorScreen({
    Key? key,
    required this.page,
  }) : super(key: key);

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late Page _page;
  bool _isAiPanelVisible = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _page = widget.page;

    // Add an empty paragraph if the page is empty
    if (_page.blocks.isEmpty) {
      _addEmptyParagraph();
    }
  }

  /// Add an empty paragraph to the page
  void _addEmptyParagraph() {
    final block = ParagraphBlock(
      richText: [const TextSpan(text: '')],
      parentId: _page.id,
    );

    setState(() {
      _page.blocks[block.id] = block;
      _page.blockOrder.add(block.id);
    });
  }

  /// Save the page
  Future<void> _savePage() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = Provider.of<Repository>(context, listen: false);
      await repository.savePage(_page);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Page saved')),
      );
    } catch (e) {
      debugPrint('Failed to save page: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save page: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// Add a new block after the specified block
  void _addBlockAfter(Block block, String type) {
    final index = _page.blockOrder.indexOf(block.id);
    if (index == -1) return;

    final newBlock = _createBlock(type);

    setState(() {
      _page.blocks[newBlock.id] = newBlock;
      _page.blockOrder.insert(index + 1, newBlock.id);
    });
  }

  /// Delete a block
  void _deleteBlock(String blockId) {
    setState(() {
      _page.blocks.remove(blockId);
      _page.blockOrder.remove(blockId);

      // Add an empty paragraph if the page is empty
      if (_page.blocks.isEmpty) {
        _addEmptyParagraph();
      }
    });
  }

  Block _createBlock(String type) {
    switch (type) {
      case 'paragraph':
        return ParagraphBlock(
          richText: [const TextSpan(text: '')],
          parentId: _page.id,
        );
      case 'heading_1':
        return HeadingBlock(
          level: 1,
          richText: [const TextSpan(text: '')],
          parentId: _page.id,
        );
      case 'heading_2':
        return HeadingBlock(
          level: 2,
          richText: [const TextSpan(text: '')],
          parentId: _page.id,
        );
      case 'heading_3':
        return HeadingBlock(
          level: 3,
          richText: [const TextSpan(text: '')],
          parentId: _page.id,
        );
      case 'bulleted_list_item':
        return BulletedListItemBlock(
          richText: [const TextSpan(text: '')],
          parentId: _page.id,
        );
      case 'numbered_list_item':
        return NumberedListItemBlock(
          richText: [const TextSpan(text: '')],
          parentId: _page.id,
        );
      case 'to_do':
        return TodoBlock(
          richText: [const TextSpan(text: '')],
          checked: false,
          parentId: _page.id,
        );
      case 'code':
        return CodeBlock(
          text: '',
          language: 'plaintext',
          parentId: _page.id,
        );
      case 'quote':
        return QuoteBlock(
          richText: [const TextSpan(text: '')],
          parentId: _page.id,
        );
      case 'divider':
        return DividerBlock(
          parentId: _page.id,
        );
      default:
        return ParagraphBlock(
          richText: [const TextSpan(text: '')],
          parentId: _page.id,
        );
    }
  }

  /// Update a block
  void _updateBlock(Block block) {
    setState(() {
      _page.blocks[block.id] = block;
    });
  }

  /// Toggle the AI assistant panel
  void _toggleAiPanel() {
    setState(() {
      _isAiPanelVisible = !_isAiPanelVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_page.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: _toggleAiPanel,
            tooltip: 'AI Assistant',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePage,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Row(
        children: [
          // Main editor
          Expanded(
            child: Column(
              children: [
                // Title editor
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: TextEditingController(text: _page.title),
                    style: Theme.of(context).textTheme.headlineMedium,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Untitled',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _page.title = value;
                      });
                    },
                  ),
                ),

                // Toolbar
                Toolbar(
                  onAddBlock: (type) {
                    if (_page.blocks.isEmpty) {
                      _addEmptyParagraph();
                    } else {
                      final lastBlockId = _page.blockOrder.last;
                      final lastBlock = _page.blocks[lastBlockId];
                      if (lastBlock != null) {
                        _addBlockAfter(lastBlock, type);
                      }
                    }
                  },
                ),

                // Block list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _page.blockOrder.length,
                    itemBuilder: (context, index) {
                      final blockId = _page.blockOrder[index];
                      final block = _page.blocks[blockId];

                      if (block == null) {
                        return const SizedBox.shrink();
                      }

                      return BlockEditor(
                        key: ValueKey(block.id),
                        block: block,
                        onAddBlockAfter: (type) => _addBlockAfter(block, type),
                        onDeleteBlock: () => _deleteBlock(block.id),
                        onUpdateBlock: _updateBlock,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // AI assistant panel
          if (_isAiPanelVisible)
            SizedBox(
              width: 300,
              child: AiAssistantPanel(
                aiService: Provider.of<AIService>(context, listen: false),
                onClose: _toggleAiPanel,
                onInsertBlock: (block) {
                  setState(() {
                    _page.blocks[block.id] = block;
                    _page.blockOrder.add(block.id);
                  });
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_page.blocks.isEmpty) {
            _addEmptyParagraph();
          } else {
            final lastBlockId = _page.blockOrder.last;
            final lastBlock = _page.blocks[lastBlockId];
            if (lastBlock != null) {
              _addBlockAfter(lastBlock, 'paragraph');
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
