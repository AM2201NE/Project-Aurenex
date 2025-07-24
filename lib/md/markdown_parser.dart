import 'package:flutter/material.dart';
import '../models/block.dart';
import '../models/page.dart' as app_models;
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Block type enum
enum BlockType {
  paragraph,
  heading1,
  heading2,
  heading3,
  bulletedListItem,
  numberedListItem,
  toDo,
  toggle,
  code,
  quote,
  divider,
  image,
  bookmark,
  mermaid,
  math,
  link,
}

/// Markdown parser for import and export
class MarkdownParser {
  /// Convert a page to Markdown
  String pageToMarkdown(app_models.Page page) {
    final buffer = StringBuffer();
    
    // Add title
    buffer.writeln('# ${page.title}');
    buffer.writeln();
    
    // Add tags if present
    if (page.tags.isNotEmpty) {
      buffer.writeln('Tags: ${page.tags.join(', ')}');
      buffer.writeln();
    }
    
    // Add blocks
    for (final block in page.blocks) {
      buffer.writeln(_blockToMarkdown(block));
    }
    
    return buffer.toString();
  }
  
  /// Convert a block to Markdown
  String _blockToMarkdown(Block block) {
    switch (block.type) {
      case 'paragraph':
        return _paragraphToMarkdown(block);
      case 'heading1':
      case 'heading2':
      case 'heading3':
        return _headingToMarkdown(block);
      case 'bulletedListItem':
        return _bulletedListItemToMarkdown(block);
      case 'numberedListItem':
        return _numberedListItemToMarkdown(block);
      case 'toDo':
        return _todoToMarkdown(block);
      case 'toggle':
        return _toggleToMarkdown(block);
      case 'code':
        return _codeToMarkdown(block);
      case 'quote':
        return _quoteToMarkdown(block);
      case 'divider':
        return '---\n';
      case 'image':
        return _imageToMarkdown(block);
      case 'bookmark':
        return _bookmarkToMarkdown(block);
      case 'mermaid':
        return _mermaidToMarkdown(block);
      case 'math':
        return _mathToMarkdown(block);
      default:
        return '<!-- Unsupported block type: ${block.type} -->\n';
    }
  }
  
  String _paragraphToMarkdown(Block block) {
    return '${block.plainText}\n\n';
  }
  
  String _headingToMarkdown(Block block) {
    String prefix = '#';
    if (block.type == 'heading1') {
      prefix = '#';
    } else if (block.type == 'heading2') {
      prefix = '##';
    } else if (block.type == 'heading3') {
      prefix = '###';
    }
    return '$prefix ${block.plainText}\n\n';
  }
  
  String _bulletedListItemToMarkdown(Block block) {
    return '- ${block.plainText}\n';
  }
  
  String _numberedListItemToMarkdown(Block block) {
    return '1. ${block.plainText}\n';
  }
  
  String _todoToMarkdown(Block block) {
    final checked = block.metadata?['checked'] == true;
    final checkbox = checked ? '[x]' : '[ ]';
    return '- $checkbox ${block.plainText}\n';
  }
  
  String _toggleToMarkdown(Block block) {
    final buffer = StringBuffer();
    buffer.writeln('<details>');
    buffer.writeln('<summary>${block.plainText}</summary>');
    buffer.writeln();
    
    final childrenIds = block.metadata?['childrenOrder'] as List<dynamic>?;
    if (childrenIds != null) {
      for (final childId in childrenIds) {
        final childBlock = block.metadata?['children']?[childId] as Block?;
        if (childBlock != null) {
          buffer.writeln(_blockToMarkdown(childBlock));
        }
      }
    }
    
    buffer.writeln('</details>');
    buffer.writeln();
    return buffer.toString();
  }
  
  String _codeToMarkdown(Block block) {
    final language = block.metadata?['language'] as String? ?? '';
    final text = block.metadata?['text'] as String? ?? block.plainText;
    return '```$language\n$text\n```\n\n';
  }
  
  String _quoteToMarkdown(Block block) {
    final lines = block.plainText.split('\n');
    final buffer = StringBuffer();
    
    for (final line in lines) {
      buffer.writeln('> $line');
    }
    
    buffer.writeln();
    return buffer.toString();
  }
  
  String _imageToMarkdown(Block block) {
    final source = block.metadata?['source'] as String? ?? '';
    final caption = block.metadata?['caption'] as String?;
    final captionText = caption != null ? ' "$caption"' : '';
    return '![Image$captionText]($source)\n\n';
  }
  
  String _bookmarkToMarkdown(Block block) {
    final url = block.metadata?['url'] as String? ?? '';
    final title = block.metadata?['title'] as String? ?? url;
    return '[$title]($url)\n\n';
  }
  
  String _mermaidToMarkdown(Block block) {
    final code = block.metadata?['code'] as String? ?? '';
    final caption = block.metadata?['caption'] as String?;
    final captionText = caption != null ? '$caption\n\n' : '';
    return '```mermaid\n$code\n```\n\n$captionText';
  }
  
  String _mathToMarkdown(Block block) {
    final equation = block.metadata?['equation'] as String? ?? block.plainText;
    final isInline = block.metadata?['isInline'] == true;
    
    if (isInline) {
      return '$${equation}$\n\n';
    } else {
      return '$$\n$equation\n$$\n\n';
    }
  }
  
  /// Parse Markdown to create a page
  Future<app_models.Page> markdownToPage(String markdown, {String? title}) async {
    final lines = markdown.split('\n');
    String pageTitle = title ?? 'Imported Page';
    final List<String> tags = [];
    
    // Extract title from first heading if available
    if (lines.isNotEmpty && lines[0].startsWith('# ')) {
      pageTitle = lines[0].substring(2).trim();
      lines.removeAt(0);
    }
    
    // Extract tags if available
    final tagLineIndex = lines.indexWhere((line) => line.startsWith('Tags:'));
    if (tagLineIndex >= 0) {
      final tagLine = lines[tagLineIndex];
      final tagPart = tagLine.substring(5).trim();
      tags.addAll(tagPart.split(',').map((tag) => tag.trim()));
      lines.removeAt(tagLineIndex);
    }
    
    // Create page
    final page = app_models.Page(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: pageTitle,
      tags: tags,
      created: DateTime.now().millisecondsSinceEpoch,
      updated: DateTime.now().millisecondsSinceEpoch,
      filePath: '',
      blocks: [],
    );
    
    // Parse blocks
    int i = 0;
    int position = 0;
    while (i < lines.length) {
      final line = lines[i].trim();
      
      if (line.isEmpty) {
        i++;
        continue;
      }
      
      if (line.startsWith('# ')) {
        // Heading 1
        final text = line.substring(2).trim();
        final block = Block(
          id: '${page.id}_block_$position',
          type: 'heading1',
          richText: [TextSpan(text: text)],
          parentId: page.id,
        );
        page.blocks.add(block);
        position++;
      } else if (line.startsWith('## ')) {
        // Heading 2
        final text = line.substring(3).trim();
        final block = Block(
          id: '${page.id}_block_$position',
          type: 'heading2',
          richText: [TextSpan(text: text)],
          parentId: page.id,
        );
        page.blocks.add(block);
        position++;
      } else if (line.startsWith('### ')) {
        // Heading 3
        final text = line.substring(4).trim();
        final block = Block(
          id: '${page.id}_block_$position',
          type: 'heading3',
          richText: [TextSpan(text: text)],
          parentId: page.id,
        );
        page.blocks.add(block);
        position++;
      } else if (line.startsWith('- ')) {
        // Bulleted list item or todo
        final text = line.substring(2).trim();
        if (text.startsWith('[x] ') || text.startsWith('[ ] ')) {
          final checked = text.startsWith('[x] ');
          final todoText = text.substring(4).trim();
          final block = Block(
            id: '${page.id}_block_$position',
            type: 'toDo',
            richText: [TextSpan(text: todoText)],
            parentId: page.id,
            metadata: {'checked': checked},
          );
          page.blocks.add(block);
          position++;
        } else {
          final block = Block(
            id: '${page.id}_block_$position',
            type: 'bulletedListItem',
            richText: [TextSpan(text: text)],
            parentId: page.id,
          );
          page.blocks.add(block);
          position++;
        }
      } else if (line.startsWith('1. ') || RegExp(r'^\d+\. ').hasMatch(line)) {
        // Numbered list item
        final text = line.substring(line.indexOf('. ') + 2).trim();
        final block = Block(
          id: '${page.id}_block_$position',
          type: 'numberedListItem',
          richText: [TextSpan(text: text)],
          parentId: page.id,
        );
        page.blocks.add(block);
        position++;
      } else if (line.startsWith('> ')) {
        // Quote
        final buffer = StringBuffer();
        buffer.writeln(line.substring(2).trim());
        
        i++;
        while (i < lines.length && lines[i].startsWith('> ')) {
          buffer.writeln(lines[i].substring(2).trim());
          i++;
        }
        i--; // Adjust for the outer loop increment
        
        final block = Block(
          id: '${page.id}_block_$position',
          type: 'quote',
          richText: [TextSpan(text: buffer.toString().trim())],
          parentId: page.id,
        );
        page.blocks.add(block);
        position++;
      } else if (line.startsWith('```')) {
        // Code block
        final language = line.substring(3).trim();
        final buffer = StringBuffer();
        
        i++;
        while (i < lines.length && !lines[i].startsWith('```')) {
          buffer.writeln(lines[i]);
          i++;
        }
        
        final block = Block(
          id: '${page.id}_block_$position',
          type: 'code',
          richText: [TextSpan(text: buffer.toString().trim())],
          parentId: page.id,
          metadata: {
            'language': language,
            'text': buffer.toString().trim(),
          },
        );
        page.blocks.add(block);
        position++;
      } else if (line == '---') {
        // Divider
        final block = Block(
          id: '${page.id}_block_$position',
          type: 'divider',
          richText: [],
          parentId: page.id,
        );
        page.blocks.add(block);
        position++;
      } else if (line.startsWith('![')) {
        // Image
        final regex = RegExp(r'!\[(.*?)\]\((.*?)\)');
        final match = regex.firstMatch(line);
        
        if (match != null) {
          final caption = match.group(1)!.trim();
          final source = match.group(2)!.trim();
          
          final block = Block(
            id: '${page.id}_block_$position',
            type: 'image',
            richText: [],
            parentId: page.id,
            metadata: {
              'source': source,
              'isAsset': false,
              'caption': caption.isEmpty ? null : caption,
            },
          );
          page.blocks.add(block);
          position++;
        }
      } else if (line.startsWith('[') && line.contains('](')) {
        // Bookmark
        final regex = RegExp(r'\[(.*?)\]\((.*?)\)');
        final match = regex.firstMatch(line);
        
        if (match != null) {
          final title = match.group(1)!.trim();
          final url = match.group(2)!.trim();
          
          final block = Block(
            id: '${page.id}_block_$position',
            type: 'bookmark',
            richText: [],
            parentId: page.id,
            metadata: {
              'url': url,
              'title': title,
            },
          );
          page.blocks.add(block);
          position++;
        }
      } else {
        // Paragraph
        final buffer = StringBuffer(line);
        
        i++;
        while (i < lines.length && lines[i].trim().isNotEmpty && !_isSpecialLine(lines[i])) {
          buffer.writeln(lines[i]);
          i++;
        }
        i--; // Adjust for the outer loop increment
        
        final block = Block(
          id: '${page.id}_block_$position',
          type: 'paragraph',
          richText: [TextSpan(text: buffer.toString().trim())],
          parentId: page.id,
        );
        page.blocks.add(block);
        position++;
      }
      
      i++;
    }
    
    return page;
  }
  
  /// Check if a line is a special Markdown element
  bool _isSpecialLine(String line) {
    line = line.trim();
    return line.startsWith('#') ||
           line.startsWith('- ') ||
           line.startsWith('1. ') ||
           RegExp(r'^\d+\. ').hasMatch(line) ||
           line.startsWith('> ') ||
           line.startsWith('```') ||
           line == '---' ||
           line.startsWith('![') ||
           (line.startsWith('[') && line.contains(']('));
  }
  
  /// Export a page to a Markdown file
  Future<File> exportPageToFile(app_models.Page page, String directory) async {
    final markdown = pageToMarkdown(page);
    final sanitizedTitle = page.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    final filePath = path.join(directory, '$sanitizedTitle.md');
    
    final file = File(filePath);
    await file.writeAsString(markdown);
    
    return file;
  }
  
  /// Import a page from a Markdown file
  Future<app_models.Page> importPageFromFile(String filePath) async {
    final file = File(filePath);
    final markdown = await file.readAsString();
    
    final fileName = path.basename(filePath);
    final title = path.basenameWithoutExtension(fileName);
    
    return markdownToPage(markdown, title: title);
  }
}
