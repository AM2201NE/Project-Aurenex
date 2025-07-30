import 'package:flutter/material.dart';
import '../../models/blocks/base_block.dart';
import '../../models/blocks/text_blocks.dart';
import '../../models/blocks/list_blocks.dart';
import '../../models/blocks/media_blocks.dart';
import '../../models/blocks/advanced_blocks.dart';
import '../../models/blocks/todo_block.dart';
import '../../models/blocks/code_block.dart';
import '../../models/blocks/quote_block.dart';
import '../../models/blocks/divider_block.dart';
import '../../models/blocks/heading_block.dart';
import '../../models/blocks/image_block.dart';
import '../../models/blocks/bookmark_block.dart';
import '../../models/blocks/mermaid_block.dart';
import '../../models/blocks/numbered_list_item_block.dart';
import '../../models/blocks/bulleted_list_item_block.dart';
import '../../models/blocks/paragraph_block.dart';

/// Block editor widget for editing different block types
class BlockEditor extends StatefulWidget {
  final Block block;
  final void Function(String) onAddBlockAfter;
  final VoidCallback onDeleteBlock;
  final void Function(Block) onUpdateBlock;

  const BlockEditor({
    Key? key,
    required this.block,
    required this.onAddBlockAfter,
    required this.onDeleteBlock,
    required this.onUpdateBlock,
  }) : super(key: key);

  @override
  _BlockEditorState createState() => _BlockEditorState();
}

class _BlockEditorState extends State<BlockEditor> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Focus(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: _isFocused
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Block type indicator
              if (_isHovered || _isFocused)
                SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.drag_indicator, size: 16),
                        onPressed: () {},
                        tooltip: 'Drag to reorder',
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () => _showAddBlockMenu(context),
                        tooltip: 'Add block',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 16),
                        onPressed: () => widget.onDeleteBlock(),
                        tooltip: 'Delete block',
                      ),
                    ],
                  ),
                ),

              // Block content
              Expanded(
                child: _buildBlockEditor(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the block editor based on block type
  Widget _buildBlockEditor() {
    switch (widget.block.type) {
      case 'paragraph':
        return _buildParagraphEditor(widget.block as ParagraphBlock);
      case 'heading_1':
      case 'heading_2':
      case 'heading_3':
        return _buildHeadingEditor(widget.block as HeadingBlock);
      case 'bulleted_list_item':
        return _buildBulletedListItemEditor(
            widget.block as BulletedListItemBlock);
      case 'numbered_list_item':
        return _buildNumberedListItemEditor(
            widget.block as NumberedListItemBlock);
      case 'to_do':
        return _buildTodoEditor(widget.block as TodoBlock);
      case 'code':
        return _buildCodeEditor(widget.block as CodeBlock);
      case 'quote':
        return _buildQuoteEditor(widget.block as QuoteBlock);
      case 'divider':
        return _buildDividerEditor();
      case 'image':
        return _buildImageEditor(widget.block as ImageBlock);
      case 'bookmark':
        return _buildBookmarkEditor(widget.block as BookmarkBlock);
      case 'mermaid':
        return _buildMermaidEditor(widget.block as MermaidBlock);
      default:
        return Text('Unsupported block type: ${widget.block.type}');
    }
  }

  /// Build paragraph editor
  Widget _buildParagraphEditor(ParagraphBlock block) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller:
            TextEditingController(text: block.content['text'] as String?),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Type something...',
        ),
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: null,
        onChanged: (value) {
          widget.onUpdateBlock(
              block.copyWith(content: {'text': value}) as ParagraphBlock);
        },
      ),
    );
  }

  /// Build heading editor
  Widget _buildHeadingEditor(HeadingBlock block) {
    TextStyle? style;
    switch (block.level) {
      case 1:
        style = Theme.of(context).textTheme.headlineLarge;
        break;
      case 2:
        style = Theme.of(context).textTheme.headlineMedium;
        break;
      case 3:
        style = Theme.of(context).textTheme.headlineSmall;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller:
            TextEditingController(text: block.content['text'] as String?),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Heading',
        ),
        style: style,
        maxLines: null,
        onChanged: (value) {
          widget.onUpdateBlock(
              block.copyWith(content: {'text': value}) as HeadingBlock);
        },
      ),
    );
  }

  /// Build bulleted list item editor
  Widget _buildBulletedListItemEditor(BulletedListItemBlock block) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4.0, right: 8.0),
            child: Text('•', style: TextStyle(fontSize: 18)),
          ),
          Expanded(
            child: TextField(
              controller: TextEditingController(
                  text: block.content['text'] as String?),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'List item',
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: null,
              onChanged: (value) {
                widget.onUpdateBlock(block.copyWith(content: {
                  'text': value
                }) as BulletedListItemBlock);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build numbered list item editor
  Widget _buildNumberedListItemEditor(NumberedListItemBlock block) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0, right: 8.0),
            child: Text('1.', style: Theme.of(context).textTheme.bodyLarge),
          ),
          Expanded(
            child: TextField(
              controller: TextEditingController(
                  text: block.content['text'] as String?),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'List item',
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: null,
              onChanged: (value) {
                widget.onUpdateBlock(block.copyWith(content: {
                  'text': value
                }) as NumberedListItemBlock);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build todo editor
  Widget _buildTodoEditor(TodoBlock block) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: block.checked,
            onChanged: (value) {
              widget.onUpdateBlock(
                  block.copyWith(content: {'checked': value}) as TodoBlock);
            },
          ),
          Expanded(
            child: TextField(
              controller: TextEditingController(
                  text: block.content['text'] as String?),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'To-do',
              ),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    decoration:
                        block.checked ? TextDecoration.lineThrough : null,
                  ),
              maxLines: null,
              onChanged: (value) {
                widget.onUpdateBlock(
                    block.copyWith(content: {'text': value}) as TodoBlock);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build code editor
  Widget _buildCodeEditor(CodeBlock block) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language selector
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: block.language,
              items: [
                'plaintext',
                'javascript',
                'python',
                'dart',
                'html',
                'css',
                'json',
                'markdown',
              ].map((language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.onUpdateBlock(
                      block.copyWith(content: {'language': value})
                          as CodeBlock);
                }
              },
            ),
          ),

          // Code editor
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: TextEditingController(text: block.text),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter code',
              ),
              style: const TextStyle(
                fontFamily: 'monospace',
              ),
              maxLines: null,
              onChanged: (value) {
                widget.onUpdateBlock(
                    block.copyWith(content: {'code': value}) as CodeBlock);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build quote editor
  Widget _buildQuoteEditor(QuoteBlock block) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 4.0,
          ),
        ),
      ),
      child: TextField(
        controller:
            TextEditingController(text: block.content['text'] as String?),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Quote',
        ),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
            ),
        maxLines: null,
        onChanged: (value) {
          widget.onUpdateBlock(
              block.copyWith(content: {'text': value}) as QuoteBlock);
        },
      ),
    );
  }

  /// Build divider editor
  Widget _buildDividerEditor() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(height: 1.0),
    );
  }

  /// Build image editor
  Widget _buildImageEditor(ImageBlock block) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview
          if (block.source.isNotEmpty)
            block.isAsset
                ? Image.asset(
                    block.source,
                    fit: BoxFit.cover,
                    height: 200,
                  )
                : Image.network(
                    block.source,
                    fit: BoxFit.cover,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 48),
                        ),
                      );
                    },
                  ),

          // Image source input
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextField(
              controller: TextEditingController(text: block.source),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Image URL',
                hintText: 'Enter image URL',
              ),
              onChanged: (value) {
                widget.onUpdateBlock(
                    block.copyWith(content: {'url': value}) as ImageBlock);
              },
            ),
          ),

          // Caption input
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextField(
              controller: TextEditingController(text: block.caption ?? ''),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Caption',
                hintText: 'Enter image caption',
              ),
              onChanged: (value) {
                widget.onUpdateBlock(
                    block.copyWith(content: {'caption': value}) as ImageBlock);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build bookmark editor
  Widget _buildBookmarkEditor(BookmarkBlock block) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // URL input
          TextField(
            controller: TextEditingController(text: block.url),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'URL',
              hintText: 'Enter URL',
            ),
            onChanged: (value) {
              widget.onUpdateBlock(
                  block.copyWith(content: {'url': value}) as BookmarkBlock);
            },
          ),

          // Title input
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextField(
              controller: TextEditingController(text: block.title ?? ''),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title',
                hintText: 'Enter title',
              ),
              onChanged: (value) {
                widget.onUpdateBlock(
                    block.copyWith(content: {'title': value})
                        as BookmarkBlock);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build mermaid editor
  Widget _buildMermaidEditor(MermaidBlock block) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Mermaid Diagram',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          // Code editor
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: TextEditingController(text: block.code),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Mermaid diagram code',
              ),
              style: const TextStyle(
                fontFamily: 'monospace',
              ),
              maxLines: null,
              onChanged: (value) {
                widget.onUpdateBlock(
                    block.copyWith(content: {'code': value}) as MermaidBlock);
              },
            ),
          ),

          // Caption input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: TextEditingController(text: block.caption ?? ''),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Caption',
                hintText: 'Enter diagram caption',
              ),
              onChanged: (value) {
                widget.onUpdateBlock(
                    block.copyWith(content: {'caption': value})
                        as MermaidBlock);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Show add block menu
  void _showAddBlockMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem<String>(
          value: 'paragraph',
          child: Text('Paragraph'),
        ),
        const PopupMenuItem<String>(
          value: 'heading_1',
          child: Text('Heading 1'),
        ),
        const PopupMenuItem<String>(
          value: 'heading_2',
          child: Text('Heading 2'),
        ),
        const PopupMenuItem<String>(
          value: 'heading_3',
          child: Text('Heading 3'),
        ),
        const PopupMenuItem<String>(
          value: 'bulleted_list_item',
          child: Text('Bulleted List'),
        ),
        const PopupMenuItem<String>(
          value: 'numbered_list_item',
          child: Text('Numbered List'),
        ),
        const PopupMenuItem<String>(
          value: 'to_do',
          child: Text('To-do'),
        ),
        const PopupMenuItem<String>(
          value: 'code',
          child: Text('Code'),
        ),
        const PopupMenuItem<String>(
          value: 'quote',
          child: Text('Quote'),
        ),
        const PopupMenuItem<String>(
          value: 'divider',
          child: Text('Divider'),
        ),
      ],
    ).then((value) {
      if (value != null) {
        widget.onAddBlockAfter(value);
      }
    });
  }
}
