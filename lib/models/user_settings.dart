import 'package:flutter/foundation.dart';

/// User settings model for application preferences
class UserSettings {
  // Theme settings
  String themeMode; // 'light', 'dark', or 'system'
  String accentColor;
  bool useSystemAccent;
  double fontSize;
  String fontFamily;
  
  // Editor settings
  bool spellCheck;
  bool autoSave;
  int autoSaveInterval; // in seconds
  bool showLineNumbers;
  bool wordWrap;
  
  // Sync settings
  bool enableSync;
  String syncProvider; // 'none', 'notion', 'custom'
  int syncInterval; // in minutes
  
  // Notification settings
  bool enableNotifications;
  bool enableSoundEffects;
  bool enableHapticFeedback;
  
  // AI settings
  bool enableAI;
  String aiModel; // 'qwen2.5-7b', 'custom'
  String aiTemperature;
  int aiMaxTokens;
  
  // Privacy settings
  bool collectAnalytics;
  bool shareUsageData;
  
  // Accessibility settings
  bool highContrast;
  bool reduceMotion;
  double textScaleFactor;
  
  UserSettings({
    this.themeMode = 'system',
    this.accentColor = '#6200EE',
    this.useSystemAccent = true,
    this.fontSize = 16.0,
    this.fontFamily = 'Inter',
    
    this.spellCheck = true,
    this.autoSave = true,
    this.autoSaveInterval = 30,
    this.showLineNumbers = false,
    this.wordWrap = true,
    
    this.enableSync = false,
    this.syncProvider = 'none',
    this.syncInterval = 15,
    
    this.enableNotifications = true,
    this.enableSoundEffects = true,
    this.enableHapticFeedback = true,
    
    this.enableAI = true,
    this.aiModel = 'qwen2.5-7b',
    this.aiTemperature = '0.7',
    this.aiMaxTokens = 2048,
    
    this.collectAnalytics = false,
    this.shareUsageData = false,
    
    this.highContrast = false,
    this.reduceMotion = false,
    this.textScaleFactor = 1.0,
  });
  
  /// Create a copy of the settings with some values changed
  UserSettings copyWith({
    String? themeMode,
    String? accentColor,
    bool? useSystemAccent,
    double? fontSize,
    String? fontFamily,
    bool? spellCheck,
    bool? autoSave,
    int? autoSaveInterval,
    bool? showLineNumbers,
    bool? wordWrap,
    bool? enableSync,
    String? syncProvider,
    int? syncInterval,
    bool? enableNotifications,
    bool? enableSoundEffects,
    bool? enableHapticFeedback,
    bool? enableAI,
    String? aiModel,
    String? aiTemperature,
    int? aiMaxTokens,
    bool? collectAnalytics,
    bool? shareUsageData,
    bool? highContrast,
    bool? reduceMotion,
    double? textScaleFactor,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      useSystemAccent: useSystemAccent ?? this.useSystemAccent,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      spellCheck: spellCheck ?? this.spellCheck,
      autoSave: autoSave ?? this.autoSave,
      autoSaveInterval: autoSaveInterval ?? this.autoSaveInterval,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      wordWrap: wordWrap ?? this.wordWrap,
      enableSync: enableSync ?? this.enableSync,
      syncProvider: syncProvider ?? this.syncProvider,
      syncInterval: syncInterval ?? this.syncInterval,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableAI: enableAI ?? this.enableAI,
      aiModel: aiModel ?? this.aiModel,
      aiTemperature: aiTemperature ?? this.aiTemperature,
      aiMaxTokens: aiMaxTokens ?? this.aiMaxTokens,
      collectAnalytics: collectAnalytics ?? this.collectAnalytics,
      shareUsageData: shareUsageData ?? this.shareUsageData,
      highContrast: highContrast ?? this.highContrast,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }
  
  /// Convert the settings to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'theme_mode': themeMode,
      'accent_color': accentColor,
      'use_system_accent': useSystemAccent,
      'font_size': fontSize,
      'font_family': fontFamily,
      'spell_check': spellCheck,
      'auto_save': autoSave,
      'auto_save_interval': autoSaveInterval,
      'show_line_numbers': showLineNumbers,
      'word_wrap': wordWrap,
      'enable_sync': enableSync,
      'sync_provider': syncProvider,
      'sync_interval': syncInterval,
      'enable_notifications': enableNotifications,
      'enable_sound_effects': enableSoundEffects,
      'enable_haptic_feedback': enableHapticFeedback,
      'enable_ai': enableAI,
      'ai_model': aiModel,
      'ai_temperature': aiTemperature,
      'ai_max_tokens': aiMaxTokens,
      'collect_analytics': collectAnalytics,
      'share_usage_data': shareUsageData,
      'high_contrast': highContrast,
      'reduce_motion': reduceMotion,
      'text_scale_factor': textScaleFactor,
    };
  }
  
  /// Create settings from a JSON map
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      themeMode: json['theme_mode'] as String? ?? 'system',
      accentColor: json['accent_color'] as String? ?? '#6200EE',
      useSystemAccent: json['use_system_accent'] as bool? ?? true,
      fontSize: (json['font_size'] as num?)?.toDouble() ?? 16.0,
      fontFamily: json['font_family'] as String? ?? 'Inter',
      spellCheck: json['spell_check'] as bool? ?? true,
      autoSave: json['auto_save'] as bool? ?? true,
      autoSaveInterval: json['auto_save_interval'] as int? ?? 30,
      showLineNumbers: json['show_line_numbers'] as bool? ?? false,
      wordWrap: json['word_wrap'] as bool? ?? true,
      enableSync: json['enable_sync'] as bool? ?? false,
      syncProvider: json['sync_provider'] as String? ?? 'none',
      syncInterval: json['sync_interval'] as int? ?? 15,
      enableNotifications: json['enable_notifications'] as bool? ?? true,
      enableSoundEffects: json['enable_sound_effects'] as bool? ?? true,
      enableHapticFeedback: json['enable_haptic_feedback'] as bool? ?? true,
      enableAI: json['enable_ai'] as bool? ?? true,
      aiModel: json['ai_model'] as String? ?? 'qwen2.5-7b',
      aiTemperature: json['ai_temperature'] as String? ?? '0.7',
      aiMaxTokens: json['ai_max_tokens'] as int? ?? 2048,
      collectAnalytics: json['collect_analytics'] as bool? ?? false,
      shareUsageData: json['share_usage_data'] as bool? ?? false,
      highContrast: json['high_contrast'] as bool? ?? false,
      reduceMotion: json['reduce_motion'] as bool? ?? false,
      textScaleFactor: (json['text_scale_factor'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

/// Settings manager for handling user preferences
class SettingsManager extends ChangeNotifier {
  UserSettings _settings = UserSettings();
  
  /// Get the current settings
  UserSettings get settings => _settings;
  
  /// Initialize the settings manager
  Future<void> initialize() async {
    // In a real app, this would load settings from storage
    // For now, we'll use default settings
    _settings = UserSettings();
  }
  
  /// Update the settings
  void updateSettings(UserSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
    _saveSettings();
  }
  
  /// Update a specific setting
  void updateSetting<T>(String key, T value) {
    final Map<String, dynamic> settingsMap = _settings.toJson();
    settingsMap[key] = value;
    _settings = UserSettings.fromJson(settingsMap);
    notifyListeners();
    _saveSettings();
  }
  
  /// Save the settings to storage
  Future<void> _saveSettings() async {
    // In a real app, this would save settings to storage
    // For now, we'll just print the settings
    debugPrint('Settings updated: ${_settings.toJson()}');
  }
}

/// Notification manager for handling app notifications
class NotificationManager {
  /// Initialize the notification manager
  Future<void> initialize() async {
    // In a real app, this would initialize notification services
    debugPrint('Notification manager initialized');
  }
  
  /// Schedule a notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    DateTime? scheduledTime,
  }) async {
    // In a real app, this would schedule a notification
    debugPrint('Notification scheduled: $title - $body');
  }
  
  /// Cancel a notification
  Future<void> cancelNotification(int id) async {
    // In a real app, this would cancel a notification
    debugPrint('Notification canceled: $id');
  }
  
  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    // In a real app, this would cancel all notifications
    debugPrint('All notifications canceled');
  }
}
