import 'package:flutter/material.dart';

class BlockRenderer extends StatelessWidget {
  final dynamic block;
  final void Function(dynamic)? onEdit;
  final void Function(dynamic)? onDelete;
  
  const BlockRenderer({
    super.key,
    required this.block,
    this.onEdit,
    this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case 'paragraph':
        return _buildParagraph(context);
      case 'heading1':
        return _buildHeading(context, 1);
      case 'heading2':
        return _buildHeading(context, 2);
      case 'heading3':
        return _buildHeading(context, 3);
      case 'bulletedListItem':
        return _buildBulletedListItem(context);
      case 'numberedListItem':
        return _buildNumberedListItem(context);
      case 'toDo':
        return _buildTodoItem(context);
      case 'toggle':
        return _buildToggle(context);
      case 'code':
        return _buildCode(context);
      case 'quote':
        return _buildQuote(context);
      case 'divider':
        return _buildDivider(context);
      case 'image':
        return _buildImage(context);
      case 'bookmark':
        return _buildBookmark(context);
      case 'mermaid':
        return _buildMermaid(context);
      case 'math':
        return _buildMath(context);
      default:
        return _buildUnsupported(context);
    }
  }
  
  Widget _buildParagraph(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(block.plainText),
    );
  }
  
  Widget _buildHeading(BuildContext context, int level) {
    double fontSize = 24;
    switch (level) {
      case 1:
        fontSize = 24;
        break;
      case 2:
        fontSize = 20;
        break;
      case 3:
        fontSize = 18;
        break;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        block.plainText,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildBulletedListItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(block.plainText)),
        ],
      ),
    );
  }
  
  Widget _buildNumberedListItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(block.plainText)),
        ],
      ),
    );
  }
  
  Widget _buildTodoItem(BuildContext context) {
    final checked = block.metadata?['checked'] == true;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: checked,
            onChanged: (value) {
              if (onEdit != null) {
                final updatedBlock = block.copyWith(
                  metadata: {...(block.metadata ?? {}), 'checked': value},
                );
                onEdit!(updatedBlock);
              }
            },
          ),
          Expanded(
            child: Text(
              block.plainText,
              style: checked
                  ? const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildToggle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(block.plainText),
        children: [
          // This would render child blocks
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Toggle content would go here'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCode(BuildContext context) {
    final language = block.metadata?['language'] as String? ?? '';
    final text = block.metadata?['text'] as String? ?? block.plainText;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                language,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuote(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.grey.shade400,
            width: 4,
          ),
        ),
      ),
      child: Text(
        block.plainText,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
  
  Widget _buildDivider(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(),
    );
  }
  
  Widget _buildImage(BuildContext context) {
    final source = block.metadata?['source'] as String? ?? '';
    final caption = block.metadata?['caption'] as String?;
    final isAsset = block.metadata?['isAsset'] == true;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: isAsset
              ? Image.asset(source)
              : source.startsWith('http')
                  ? Image.network(source)
                  : const Placeholder(),
        ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              caption,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildBookmark(BuildContext context) {
    final url = block.metadata?['url'] as String? ?? '';
    final title = block.metadata?['title'] as String? ?? url;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            url,
            style: TextStyle(
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMermaid(BuildContext context) {
    // This would use the MermaidRenderer widget
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text('Mermaid diagram would render here'),
      ),
    );
  }
  
  Widget _buildMath(BuildContext context) {
    final equation = block.metadata?['equation'] as String? ?? block.plainText;
    final isInline = block.metadata?['isInline'] == true;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isInline ? '\$$equation\$' : '\$\$$equation\$\$',
        style: const TextStyle(
          fontFamily: 'serif',
        ),
      ),
    );
  }
  
  Widget _buildUnsupported(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        'Unsupported block type: ${block.type}',
        style: TextStyle(
          color: Colors.red.shade700,
        ),
      ),
    );
  }
}
