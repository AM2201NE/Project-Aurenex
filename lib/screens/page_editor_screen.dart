import 'package:flutter/material.dart';
import '../models/page.dart' as page_model;
import '../models/blocks/base_block.dart';
import '../models/blocks/rich_text_block.dart';
import 'ai_chat_screen.dart';

class PageEditorScreen extends StatefulWidget {
  final page_model.Page page;
  final Future<String> Function(String prompt) onSendPrompt;
  const PageEditorScreen({Key? key, required this.page, required this.onSendPrompt}) : super(key: key);

  @override
  State<PageEditorScreen> createState() => _PageEditorScreenState();
}

class _PageEditorScreenState extends State<PageEditorScreen> {
  late page_model.Page _page;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _page = widget.page;
    _titleController.text = _page.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Page Title'),
          style: Theme.of(context).textTheme.titleLarge,
          onChanged: (val) => setState(() => _page.title = val),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'AI Chat',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AIChatScreen(onSendPrompt: widget.onSendPrompt),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._page.blocks.values.map((block) => _buildBlockWidget(block)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Block'),
            onPressed: _addBlock,
          ),
        ],
      ),
    );
  }

  Widget _buildBlockWidget(Block block) {
    // For demo: just show block type and content
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(block.type),
        subtitle: Text(block.plainText),
      ),
    );
  }

  void _addBlock() {
    setState(() {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      _page.blocks[id] = RichTextBlock(
        id: id,
        type: 'paragraph',
        richText: [],
        parentId: _page.id,
      );
    });
  }
}
