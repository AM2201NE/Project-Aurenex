import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/page.dart';
import '../models/workspace.dart';
import '../models/blocks/base_block.dart';
import '../models/blocks/text_blocks.dart';
import '../models/blocks/list_blocks.dart';
import '../models/blocks/layout_blocks.dart';
import '../models/blocks/media_blocks.dart';
import '../models/blocks/database_blocks.dart';
import '../models/blocks/advanced_blocks.dart';
import '../models/blocks/special_blocks.dart';

/// Repository for data storage and retrieval
class Repository {
  final String documentsPath;
  final DatabaseManager databaseManager;
  
  Repository({
    required this.documentsPath,
    required this.databaseManager,
  });
  
  /// Initialize the repository
  Future<void> initialize() async {
    // Create necessary directories
    await Directory(path.join(documentsPath, 'pages')).create(recursive: true);
    await Directory(path.join(documentsPath, 'assets')).create(recursive: true);
    await Directory(path.join(documentsPath, 'exports')).create(recursive: true);
  }
  
  /// List all workspaces
  Future<List<Workspace>> listWorkspaces() async {
    final workspaces = await databaseManager.getWorkspaces();
    return workspaces.map((json) => Workspace.fromJson(json, blockFromJson: _blockFromJson)).toList();
  }
  
  /// Get a workspace by ID
  Future<Workspace?> getWorkspace(String id) async {
    final json = await databaseManager.getWorkspace(id);
    if (json == null) {
      return null;
    }
    return Workspace.fromJson(json, blockFromJson: _blockFromJson);
  }
  
  /// Save a workspace
  Future<void> saveWorkspace(Workspace workspace) async {
    await databaseManager.saveWorkspace(workspace.toJson());
  }
  
  /// Delete a workspace
  Future<void> deleteWorkspace(String id) async {
    await databaseManager.deleteWorkspace(id);
  }
  
  /// Get a page by ID
  Future<NotePage?> getPage(String id) async {
    final json = await databaseManager.getPage(id);
    if (json == null) {
      return null;
    }
    return NotePage.fromJson(json, blockFromJson: _blockFromJson);
  }
  
  /// Save a page
  Future<void> savePage(NotePage page) async {
    await databaseManager.savePage(page.toJson());
  }
  
  /// Delete a page
  Future<void> deletePage(String id) async {
    await databaseManager.deletePage(id);
  }
  
  /// Search pages by query
  Future<List<NotePage>> searchPages(String query) async {
    final results = await databaseManager.searchPages(query);
    return results.map((json) => NotePage.fromJson(json, blockFromJson: _blockFromJson)).toList();
  }
  
  /// Export a page to Markdown
  Future<String> exportPageToMarkdown(NotePage page) async {
    // In a real app, this would convert the page to Markdown
    // For now, we'll return a simple representation
    return '# ${page.title}\n\n${page.tags.join(', ')}\n\n${page.blocks.length} blocks';
  }
  
  /// Import a page from Markdown
  Future<NotePage> importPageFromMarkdown(String markdown, {String? parentId}) async {
    // In a real app, this would parse the Markdown and create a page
    // For now, we'll create a simple page
    final lines = markdown.split('\n');
    String title = 'Imported Page';
    
    if (lines.isNotEmpty && lines[0].startsWith('# ')) {
      title = lines[0].substring(2);
    }
    
    final page = NotePage(
      title: title,
    );
    
    // Add a simple paragraph block
    final block = ParagraphBlock(
      richText: [TextSpan(text: markdown)],
      parentId: page.id,
    );
    page.addBlock(block);
    
    return page;
  }
  
  /// Create a block from JSON
  Block _blockFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    
    switch (type) {
      case 'paragraph':
        return ParagraphBlock.fromJson(json);
      case 'heading_1':
      case 'heading_2':
      case 'heading_3':
        return HeadingBlock.fromJson(json);
      case 'bulleted_list_item':
        return BulletedListItemBlock.fromJson(json);
      case 'numbered_list_item':
        return NumberedListItemBlock.fromJson(json);
      case 'to_do':
        return TodoBlock.fromJson(json);
      case 'toggle':
        return ToggleBlock.fromJson(json);
      case 'code':
        return CodeBlock.fromJson(json);
      case 'quote':
        return QuoteBlock.fromJson(json);
      case 'divider':
        return DividerBlock.fromJson(json);
      case 'image':
        return ImageBlock.fromJson(json);
      case 'video':
        return VideoBlock.fromJson(json);
      case 'audio':
        return AudioBlock.fromJson(json);
      case 'file':
        return FileBlock.fromJson(json);
      case 'bookmark':
        return BookmarkBlock.fromJson(json);
      case 'column':
        return ColumnBlock.fromJson(json);
      case 'row':
        return RowBlock.fromJson(json);
      case 'container':
        return ContainerBlock.fromJson(json);
      case 'database':
        return DatabaseBlock.fromJson(json);
      case 'mermaid':
        return MermaidBlock.fromJson(json);
      case 'math':
        return MathBlock.fromJson(json);
      case 'embed':
        return EmbedBlock.fromJson(json);
      case 'ai':
        return AIBlock.fromJson(json);
      case 'link':
        return LinkBlock.fromJson(json);
      case 'template':
        return TemplateBlock.fromJson(json);
      case 'callout':
        return CalloutBlock.fromJson(json);
      default:
        throw Exception('Unknown block type: $type');
    }
  }
}
