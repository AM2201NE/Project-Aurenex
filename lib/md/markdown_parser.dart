import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/block.dart';
import '../models/page.dart' as app_models;
import 'dart:io';
import 'package:path/path.dart' as path;

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
    for (final blockId in page.blockOrder) {
      final block = page.blocks[blockId];
      if (block != null) {
        buffer.writeln(_blockToMarkdown(block));
      }
    }

    return buffer.toString();
  }

  /// Convert a block to Markdown
  String _blockToMarkdown(Block block) {
    switch (block.type) {
      case 'paragraph':
        return _paragraphToMarkdown(block);
      case 'heading_1':
      case 'heading_2':
      case 'heading_3':
        return _headingToMarkdown(block);
      case 'bulleted_list_item':
        return _bulletedListItemToMarkdown(block);
      case 'numbered_list_item':
        return _numberedListItemToMarkdown(block);
      case 'to_do':
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
    return '${block.content['text']}\n\n';
  }

  String _headingToMarkdown(Block block) {
    String prefix = '#';
    if (block.type == 'heading_1') {
      prefix = '#';
    } else if (block.type == 'heading_2') {
      prefix = '##';
    } else if (block.type == 'heading_3') {
      prefix = '###';
    }
    return '$prefix ${block.content['text']}\n\n';
  }

  String _bulletedListItemToMarkdown(Block block) {
    return '- ${block.content['text']}\n';
  }

  String _numberedListItemToMarkdown(Block block) {
    return '1. ${block.content['text']}\n';
  }

  String _todoToMarkdown(Block block) {
    final checked = block.content['checked'] == true;
    final checkbox = checked ? '[x]' : '[ ]';
    return '- $checkbox ${block.content['text']}\n';
  }

  String _toggleToMarkdown(Block block) {
    final buffer = StringBuffer();
    buffer.writeln('<details>');
    buffer.writeln('<summary>${block.content['text']}</summary>');
    buffer.writeln();

    final childrenIds = block.childrenOrder;
    if (childrenIds.isNotEmpty) {
      for (final childId in childrenIds) {
        final childBlock = block.children[childId];
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
    final language = block.content['language'] as String? ?? '';
    final text = block.content['code'] as String? ?? '';
    return '```$language\n$text\n```\n\n';
  }

  String _quoteToMarkdown(Block block) {
    final lines = (block.content['text'] as String).split('\n');
    final buffer = StringBuffer();

    for (final line in lines) {
      buffer.writeln('> $line');
    }

    buffer.writeln();
    return buffer.toString();
  }

  String _imageToMarkdown(Block block) {
    final source = block.content['url'] as String? ?? '';
    final caption = block.content['caption'] as String?;
    final captionText = caption != null ? ' "$caption"' : '';
    return '![Image$captionText]($source)\n\n';
  }

  String _bookmarkToMarkdown(Block block) {
    final url = block.content['url'] as String? ?? '';
    final title = block.content['title'] as String? ?? url;
    return '[$title]($url)\n\n';
  }

  String _mermaidToMarkdown(Block block) {
    final code = block.content['code'] as String? ?? '';
    final caption = block.content['caption'] as String?;
    final captionText = caption != null ? '$caption\n\n' : '';
    return '```mermaid\n$code\n```\n\n$captionText';
  }

  String _mathToMarkdown(Block block) {
    final equation = block.content['equation'] as String? ?? '';
    final isInline = block.content['isInline'] == true;

    if (isInline) {
      return '\$${equation}\$\n\n';
    } else {
      return '\$\$\n$equation\n\$\$\n\n';
    }
  }

  /// Parse Markdown to create a page
  Future<app_models.Page> markdownToPage(String markdown,
      {String? title}) async {
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
      title: pageTitle,
      tags: tags,
    );

    // Parse blocks
    int i = 0;
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
          type: 'heading_1',
          content: {'text': text},
          parentId: page.id,
        );
        page.blocks[block.id] = block;
        page.blockOrder.add(block.id);
      } else if (line.startsWith('## ')) {
        // Heading 2
        final text = line.substring(3).trim();
        final block = Block(
          type: 'heading_2',
          content: {'text': text},
          parentId: page.id,
        );
        page.blocks[block.id] = block;
        page.blockOrder.add(block.id);
      } else if (line.startsWith('### ')) {
        // Heading 3
        final text = line.substring(4).trim();
        final block = Block(
          type: 'heading_3',
          content: {'text': text},
          parentId: page.id,
        );
        page.blocks[block.id] = block;
        page.blockOrder.add(block.id);
      } else if (line.startsWith('- ')) {
        // Bulleted list item or todo
        final text = line.substring(2).trim();
        if (text.startsWith('[x] ') || text.startsWith('[ ] ')) {
          final checked = text.startsWith('[x] ');
          final todoText = text.substring(4).trim();
          final block = Block(
            type: 'to_do',
            content: {'text': todoText, 'checked': checked},
            parentId: page.id,
          );
          page.blocks[block.id] = block;
          page.blockOrder.add(block.id);
        } else {
          final block = Block(
            type: 'bulleted_list_item',
            content: {'text': text},
            parentId: page.id,
          );
          page.blocks[block.id] = block;
          page.blockOrder.add(block.id);
        }
      } else if (line.startsWith('1. ') ||
          RegExp(r'^\d+\. ').hasMatch(line)) {
        // Numbered list item
        final text = line.substring(line.indexOf('. ') + 2).trim();
        final block = Block(
          type: 'numbered_list_item',
          content: {'text': text},
          parentId: page.id,
        );
        page.blocks[block.id] = block;
        page.blockOrder.add(block.id);
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
          type: 'quote',
          content: {'text': buffer.toString().trim()},
          parentId: page.id,
        );
        page.blocks[block.id] = block;
        page.blockOrder.add(block.id);
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
          type: 'code',
          content: {'code': buffer.toString().trim(), 'language': language},
          parentId: page.id,
        );
        page.blocks[block.id] = block;
        page.blockOrder.add(block.id);
      } else if (line == '---') {
        // Divider
        final block = Block(
          type: 'divider',
          content: {},
          parentId: page.id,
        );
        page.blocks[block.id] = block;
        page.blockOrder.add(block.id);
      } else if (line.startsWith('![')) {
        // Image
        final regex = RegExp(r'!\[(.*?)\]\((.*?)\)');
        final match = regex.firstMatch(line);

        if (match != null) {
          final caption = match.group(1)!.trim();
          final source = match.group(2)!.trim();

          final block = Block(
            type: 'image',
            content: {
              'url': source,
              'caption': caption.isEmpty ? null : caption
            },
            parentId: page.id,
          );
          page.blocks[block.id] = block;
          page.blockOrder.add(block.id);
        }
      } else if (line.startsWith('[') && line.contains('](')) {
        // Bookmark
        final regex = RegExp(r'\[(.*?)\]\((.*?)\)');
        final match = regex.firstMatch(line);

        if (match != null) {
          final title = match.group(1)!.trim();
          final url = match.group(2)!.trim();

          final block = Block(
            type: 'bookmark',
            content: {'url': url, 'title': title},
            parentId: page.id,
          );
          page.blocks[block.id] = block;
          page.blockOrder.add(block.id);
        }
      } else {
        // Paragraph
        final buffer = StringBuffer(line);

        i++;
        while (i < lines.length &&
            lines[i].trim().isNotEmpty &&
            !_isSpecialLine(lines[i])) {
          buffer.writeln(lines[i]);
          i++;
        }
        i--; // Adjust for the outer loop increment

        final block = Block(
          type: 'paragraph',
          content: {'text': buffer.toString().trim()},
          parentId: page.id,
        );
        page.blocks[block.id] = block;
        page.blockOrder.add(block.id);
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
    final sanitizedTitle =
        page.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    final filePath = path.join(directory, '$sanitizedTitle.md');

    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(markdown);

    return file;
  }

  /// Import a page from a Markdown file
  Future<app_models.Page> importPageFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }
    final markdown = await file.readAsString();

    final fileName = path.basename(filePath);
    final title = path.basenameWithoutExtension(fileName);

    return markdownToPage(markdown, title: title);
  }
}
