import 'base_block.dart';
// Import all block types here
import 'text_blocks.dart';
import 'list_blocks.dart';
import 'layout_blocks.dart';
import 'media_blocks.dart';
import 'database_blocks.dart';
import 'advanced_blocks.dart';
import 'special_blocks.dart';

Block blockFromMap(Map<String, dynamic> map) {
  final type = map['type'] as String?;
  switch (type) {
    case 'paragraph':
      return ParagraphBlock.fromJson(map);
    case 'heading':
      return HeadingBlock.fromJson(map);
    case 'bulleted_list_item':
      return BulletedListItemBlock.fromJson(map);
    case 'numbered_list_item':
      return NumberedListItemBlock.fromJson(map);
    case 'todo':
      return TodoBlock.fromJson(map);
    case 'toggle':
      return ToggleBlock.fromJson(map);
    case 'code':
      return CodeBlock.fromJson(map);
    case 'quote':
      return QuoteBlock.fromJson(map);
    case 'divider':
      return DividerBlock.fromJson(map);
    case 'image':
      return ImageBlock.fromJson(map);
    case 'container':
      return ContainerBlock.fromJson(map);
    case 'row':
      return RowBlock.fromJson(map);
    case 'column':
      return ColumnBlock.fromJson(map);
    // Add more cases for other block types as needed
    default:
      throw Exception('Unknown block type: $type');
  }
}
