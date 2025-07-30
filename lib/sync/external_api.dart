import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/api_key.dart';
import '../models/page.dart';
import '../models/workspace.dart';

/// External API service for syncing with Notion
class NotionApiService {
  final ApiKeyManager _apiKeyManager;
  static const String _baseUrl = 'https://api.notion.com/v1';
  
  NotionApiService(this._apiKeyManager);
  
  /// Check if the API key is valid
  Future<bool> validateApiKey() async {
    try {
      final apiKey = _apiKeyManager.activeKeyForService('notion');
      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: _getHeaders(apiKey),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Failed to validate API key: $e');
      return false;
    }
  }
  
  /// Get all workspaces from Notion
  Future<List<Map<String, dynamic>>> getWorkspaces() async {
    try {
      final apiKey = _apiKeyManager.activeKeyForService('notion');
      final response = await http.get(
        Uri.parse('$_baseUrl/search'),
        headers: _getHeaders(apiKey),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>;
        
        return results
            .where((item) => item['object'] == 'database')
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Failed to get workspaces: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to get workspaces: $e');
      return [];
    }
  }
  
  /// Get a page from Notion
  Future<Map<String, dynamic>?> getPage(String pageId) async {
    try {
      final apiKey = _apiKeyManager.activeKeyForService('notion');
      final response = await http.get(
        Uri.parse('$_baseUrl/pages/$pageId'),
        headers: _getHeaders(apiKey),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get page: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to get page: $e');
      return null;
    }
  }
  
  /// Get page content from Notion
  Future<List<Map<String, dynamic>>> getPageContent(String pageId) async {
    try {
      final apiKey = _apiKeyManager.activeKeyForService('notion');
      final response = await http.get(
        Uri.parse('$_baseUrl/blocks/$pageId/children'),
        headers: _getHeaders(apiKey),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>;
        
        return results.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to get page content: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to get page content: $e');
      return [];
    }
  }
  
  /// Create a page in Notion
  Future<Map<String, dynamic>?> createPage(Page page, String parentId) async {
    try {
      final apiKey = _apiKeyManager.activeKeyForService('notion');
      final response = await http.post(
        Uri.parse('$_baseUrl/pages'),
        headers: _getHeaders(apiKey!),
        body: jsonEncode({
          'parent': {'database_id': parentId},
          'properties': {
            'Name': {
              'title': [
                {
                  'text': {'content': page.title}
                }
              ]
            },
            'Tags': {
              'multi_select': page.tags.map((tag) => {'name': tag}).toList()
            }
          }
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create page: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to create page: $e');
      return null;
    }
  }
  
  /// Update a page in Notion
  Future<bool> updatePage(String pageId, Map<String, dynamic> properties) async {
    try {
      final apiKey = _apiKeyManager.activeKeyForService('notion');
      final response = await http.patch(
        Uri.parse('$_baseUrl/pages/$pageId'),
        headers: _getHeaders(apiKey),
        body: jsonEncode({
          'properties': properties,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Failed to update page: $e');
      return false;
    }
  }
  
  /// Add content to a page in Notion
  Future<bool> addPageContent(String pageId, List<Map<String, dynamic>> blocks) async {
    try {
      final apiKey = _apiKeyManager.activeKeyForService('notion');
      final response = await http.patch(
        Uri.parse('$_baseUrl/blocks/$pageId/children'),
        headers: _getHeaders(apiKey),
        body: jsonEncode({
          'children': blocks,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Failed to add page content: $e');
      return false;
    }
  }
  
  /// Delete a page in Notion
  Future<bool> deletePage(String pageId) async {
    try {
      final apiKey = _apiKeyManager.activeKeyForService('notion');
      final response = await http.patch(
        Uri.parse('$_baseUrl/pages/$pageId'),
        headers: _getHeaders(apiKey),
        body: jsonEncode({
          'archived': true,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Failed to delete page: $e');
      return false;
    }
  }
  
  /// Get headers for Notion API requests
  Map<String, String> _getHeaders(ApiKey? apiKey) {
    if (apiKey == null) {
      throw Exception('API key is null');
    }
    return {
      'Authorization': 'Bearer ${apiKey.key}',
      'Content-Type': 'application/json',
      'Notion-Version': '2022-06-28',
    };
  }
}

/// Sync service for synchronizing with external services
class SyncService extends ChangeNotifier {
  final NotionApiService _notionApiService;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  
  SyncService(this._notionApiService);
  
  /// Check if sync is in progress
  bool get isSyncing => _isSyncing;
  
  /// Get the last sync time
  DateTime? get lastSyncTime => _lastSyncTime;
  
  /// Sync with Notion
  Future<bool> syncWithNotion(Workspace workspace) async {
    if (_isSyncing) return false;
    
    try {
      _isSyncing = true;
      notifyListeners();
      
      // Validate API key
      final isValid = await _notionApiService.validateApiKey();
      if (!isValid) {
        throw Exception('Invalid API key');
      }
      
      // Get Notion workspaces
      final notionWorkspaces = await _notionApiService.getWorkspaces();
      if (notionWorkspaces.isEmpty) {
        throw Exception('No workspaces found');
      }
      
      // For simplicity, use the first workspace
      final notionWorkspace = notionWorkspaces.first;
      
      // Sync pages
      for (final pageId in workspace.pageOrder) {
        final page = workspace.pages[pageId];
        if (page == null) continue;
        
        // Create or update page in Notion
        await _syncPage(page, notionWorkspace['id'] as String);
      }
      
      _lastSyncTime = DateTime.now();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to sync with Notion: $e');
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  /// Sync a page with Notion
  Future<void> _syncPage(Page page, String parentId) async {
    // Check if page exists in Notion
    // In a real app, we would store Notion IDs for pages
    // For now, we'll create a new page every time
    final notionPage = await _notionApiService.createPage(page, parentId);
    if (notionPage == null) {
      throw Exception('Failed to create page in Notion');
    }
    
    // Convert blocks to Notion format
    final notionBlocks = _convertBlocksToNotion(page);
    
    // Add content to page
    await _notionApiService.addPageContent(notionPage['id'] as String, notionBlocks);
  }
  
  /// Convert blocks to Notion format
  List<Map<String, dynamic>> _convertBlocksToNotion(Page page) {
    final result = <Map<String, dynamic>>[];
    
    for (final blockId in page.blockOrder) {
      final block = page.blocks[blockId];
      if (block == null) continue;
      
      switch (block.type) {
        case 'paragraph':
          result.add({
            'object': 'block',
            'type': 'paragraph',
            'paragraph': {
              'rich_text': [
                {
                  'type': 'text',
                  'text': {'content': (block as dynamic).plainText}
                }
              ]
            }
          });
          break;
        case 'heading_1':
        case 'heading_2':
        case 'heading_3':
          result.add({
            'object': 'block',
            'type': block.type,
            block.type: {
              'rich_text': [
                {
                  'type': 'text',
                  'text': {'content': (block as dynamic).plainText}
                }
              ]
            }
          });
          break;
        case 'bulleted_list_item':
          result.add({
            'object': 'block',
            'type': 'bulleted_list_item',
            'bulleted_list_item': {
              'rich_text': [
                {
                  'type': 'text',
                  'text': {'content': (block as dynamic).plainText}
                }
              ]
            }
          });
          break;
        case 'numbered_list_item':
          result.add({
            'object': 'block',
            'type': 'numbered_list_item',
            'numbered_list_item': {
              'rich_text': [
                {
                  'type': 'text',
                  'text': {'content': (block as dynamic).plainText}
                }
              ]
            }
          });
          break;
        case 'to_do':
          result.add({
            'object': 'block',
            'type': 'to_do',
            'to_do': {
              'rich_text': [
                {
                  'type': 'text',
                  'text': {'content': (block as dynamic).plainText}
                }
              ],
              'checked': (block as dynamic).checked
            }
          });
          break;
        case 'code':
          result.add({
            'object': 'block',
            'type': 'code',
            'code': {
              'rich_text': [
                {
                  'type': 'text',
                  'text': {'content': (block as dynamic).text}
                }
              ],
              'language': (block as dynamic).language
            }
          });
          break;
        case 'quote':
          result.add({
            'object': 'block',
            'type': 'quote',
            'quote': {
              'rich_text': [
                {
                  'type': 'text',
                  'text': {'content': (block as dynamic).plainText}
                }
              ]
            }
          });
          break;
        case 'divider':
          result.add({
            'object': 'block',
            'type': 'divider',
            'divider': {}
          });
          break;
        // Add more block types as needed
      }
    }
    
    return result;
  }
}
