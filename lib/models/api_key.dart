import 'package:flutter/foundation.dart';

/// API key model for external services
class ApiKey {
  final String id;
  String name;
  String key;
  String service;
  bool isActive;
  DateTime createdAt;
  DateTime? expiresAt;
  
  ApiKey({
    String? id,
    required this.name,
    required this.key,
    required this.service,
    this.isActive = true,
    DateTime? createdAt,
    this.expiresAt,
  }) : 
    id = id ?? _generateId(),
    createdAt = createdAt ?? DateTime.now();
  
  /// Generate a unique ID for the API key
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (10000 + (DateTime.now().microsecond % 10000)).toString();
  }
  
  /// Check if the API key is expired
  bool get isExpired {
    if (expiresAt == null) {
      return false;
    }
    return expiresAt!.isBefore(DateTime.now());
  }
  
  /// Check if the API key is valid
  bool get isValid {
    return isActive && !isExpired;
  }
  
  /// Convert the API key to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'key': key,
      'service': service,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
  
  /// Create an API key from a JSON map
  factory ApiKey.fromJson(Map<String, dynamic> json) {
    return ApiKey(
      id: json['id'] as String,
      name: json['name'] as String,
      key: json['key'] as String,
      service: json['service'] as String,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at'] as String) 
          : null,
    );
  }
}

/// API key manager for handling external service keys
class ApiKeyManager extends ChangeNotifier {
  final List<ApiKey> _keys = [];
  
  /// Get all API keys
  List<ApiKey> get keys => List.unmodifiable(_keys);
  
  /// Get API keys for a specific service
  List<ApiKey> keysForService(String service) {
    return _keys.where((key) => key.service == service).toList();
  }
  
  /// Get the active API key for a service
  ApiKey? activeKeyForService(String service) {
    return _keys.firstWhere(
      (key) => key.service == service && key.isValid,
      orElse: () => throw Exception('No active API key found for $service'),
    );
  }
  
  /// Add a new API key
  void addKey(ApiKey key) {
    _keys.add(key);
    notifyListeners();
  }
  
  /// Update an existing API key
  void updateKey(ApiKey key) {
    final index = _keys.indexWhere((k) => k.id == key.id);
    if (index >= 0) {
      _keys[index] = key;
      notifyListeners();
    }
  }
  
  /// Remove an API key
  void removeKey(String id) {
    _keys.removeWhere((key) => key.id == id);
    notifyListeners();
  }
  
  /// Load API keys from storage
  Future<void> loadKeys() async {
    // In a real app, this would load keys from secure storage
    // For now, we'll use an empty list
    _keys.clear();
    notifyListeners();
  }
  
  /// Save API keys to storage
  Future<void> saveKeys() async {
    // In a real app, this would save keys to secure storage
    // For now, we'll just print the keys
    debugPrint('API keys saved: ${_keys.length} keys');
  }
}
