import 'package:flutter/material.dart';

/// Toolbar widget for the editor
class Toolbar extends StatelessWidget {
  final Function(String) onAddBlock;
  
  const Toolbar({
    Key? key,
    required this.onAddBlock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildToolbarButton(
              context,
              icon: Icons.text_fields,
              label: 'Text',
              onPressed: () => onAddBlock('paragraph'),
            ),
            _buildToolbarButton(
              context,
              icon: Icons.title,
              label: 'Heading',
              onPressed: () => _showHeadingMenu(context),
            ),
            _buildToolbarButton(
              context,
              icon: Icons.format_list_bulleted,
              label: 'Bullet List',
              onPressed: () => onAddBlock('bulleted_list_item'),
            ),
            _buildToolbarButton(
              context,
              icon: Icons.format_list_numbered,
              label: 'Numbered List',
              onPressed: () => onAddBlock('numbered_list_item'),
            ),
            _buildToolbarButton(
              context,
              icon: Icons.check_box,
              label: 'To-do',
              onPressed: () => onAddBlock('to_do'),
            ),
            _buildToolbarButton(
              context,
              icon: Icons.code,
              label: 'Code',
              onPressed: () => onAddBlock('code'),
            ),
            _buildToolbarButton(
              context,
              icon: Icons.format_quote,
              label: 'Quote',
              onPressed: () => onAddBlock('quote'),
            ),
            _buildToolbarButton(
              context,
              icon: Icons.horizontal_rule,
              label: 'Divider',
              onPressed: () => onAddBlock('divider'),
            ),
            _buildToolbarButton(
              context,
              icon: Icons.image,
              label: 'Image',
              onPressed: () => onAddBlock('image'),
            ),
            _buildToolbarButton(
              context,
              icon: Icons.link,
              label: 'Bookmark',
              onPressed: () => onAddBlock('bookmark'),
            ),
            _buildToolbarButton(
              context,
              icon: Icons.schema,
              label: 'Diagram',
              onPressed: () => onAddBlock('mermaid'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build a toolbar button
  Widget _buildToolbarButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Show heading menu
  void _showHeadingMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    
    showMenu<String>(
      context: context,
      position: position,
      items: [
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
      ],
    ).then((value) {
      if (value != null) {
        onAddBlock(value);
      }
    });
  }
}
