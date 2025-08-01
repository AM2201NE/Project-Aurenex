import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/page.dart';
import '../models/blocks/base_block.dart';
import '../models/blocks/text_blocks.dart';
import '../storage/repository.dart';
import '../ai/llm_interface.dart';
import 'widgets/block_editor.dart';
import 'widgets/toolbar.dart';
import 'widgets/ai_assistant_panel.dart';

/// Editor screen for editing a page
class EditorScreen extends StatefulWidget {
  final NotePage page;
  
  const EditorScreen({
    Key? key,
    required this.page,
  }) : super(key: key);

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late NotePage _page;
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
      richText: [TextSpan(text: '')],
      parentId: _page.id,
    );
    
    setState(() {
      _page.addBlock(block);
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
    
    Block newBlock;
    
    switch (type) {
      case 'paragraph':
        newBlock = ParagraphBlock(
          richText: [TextSpan(text: '')],
          parentId: _page.id,
        );
        break;
      case 'heading_1':
        newBlock = HeadingBlock(
          level: 1,
          richText: [TextSpan(text: '')],
          parentId: _page.id,
        );
        break;
      case 'heading_2':
        newBlock = HeadingBlock(
          level: 2,
          richText: [TextSpan(text: '')],
          parentId: _page.id,
        );
        break;
      case 'heading_3':
        newBlock = HeadingBlock(
          level: 3,
          richText: [TextSpan(text: '')],
          parentId: _page.id,
        );
        break;
      case 'bulleted_list_item':
        newBlock = BulletedListItemBlock(
          richText: [TextSpan(text: '')],
          parentId: _page.id,
        );
        break;
      case 'numbered_list_item':
        newBlock = NumberedListItemBlock(
          richText: [TextSpan(text: '')],
          parentId: _page.id,
        );
        break;
      case 'to_do':
        newBlock = TodoBlock(
          richText: [TextSpan(text: '')],
          checked: false,
          parentId: _page.id,
        );
        break;
      case 'code':
        newBlock = CodeBlock(
          text: '',
          language: 'plaintext',
          parentId: _page.id,
        );
        break;
      case 'quote':
        newBlock = QuoteBlock(
          richText: [TextSpan(text: '')],
          parentId: _page.id,
        );
        break;
      case 'divider':
        newBlock = DividerBlock(
          parentId: _page.id,
        );
        break;
      default:
        newBlock = ParagraphBlock(
          richText: [TextSpan(text: '')],
          parentId: _page.id,
        );
    }
    
    setState(() {
      _page.addBlock(newBlock);
      _page.moveBlock(newBlock.id, toIndex: index + 1);
    });
  }
  
  /// Delete a block
  void _deleteBlock(String blockId) {
    setState(() {
      _page.removeBlock(blockId);
      
      // Add an empty paragraph if the page is empty
      if (_page.blocks.isEmpty) {
        _addEmptyParagraph();
      }
    });
  }
  
  /// Update a block
  void _updateBlock(Block block) {
    setState(() {
      _page.updateBlock(block);
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
                page: _page,
                onClose: _toggleAiPanel,
                onInsertBlock: (block) {
                  setState(() {
                    _page.addBlock(block);
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
