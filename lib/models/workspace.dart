import '../models/page.dart' as page_model;


import 'dart:convert';
/// Workspace model representing a collection of pages
class Workspace {
  final String id;
  String? name;
  String? description;
  int? createdAt;
  int? updatedAt;
  Map<String, page_model.Page>? pages;
  List<String>? pageOrder;
  Map<String, dynamic>? settings;

  Workspace({
    required this.id,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    Map<String, page_model.Page>? pages,
    List<dynamic>? pageOrder,
    this.settings,
  })  : pages = pages ?? {},
        pageOrder = _sanitizePageOrder(pageOrder);

  // Defensive: sanitize pageOrder input everywhere
  static List<String> _sanitizePageOrder(dynamic po) {
    if (po == null) return <String>[];
    if (po is List) {
      return po.where((e) => e != null && e.toString().isNotEmpty && e.toString() != 'null').map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  /// Create a copy with updated properties
  Workspace copy({
    String? id,
    String? name,
    String? description,
    int? createdAt,
    int? updatedAt,
    Map<String, page_model.Page>? pages,
    List<String>? pageOrder,
    Map<String, dynamic>? settings,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name ?? '',
      description: description ?? this.description ?? '',
      createdAt: createdAt ?? this.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: updatedAt ?? this.updatedAt ?? DateTime.now().millisecondsSinceEpoch,
      pages: pages ?? Map.from(this.pages ?? {}),
      pageOrder: _sanitizePageOrder(pageOrder ?? List.from(this.pageOrder ?? [])),
      settings: settings ?? Map.from(this.settings ?? {}),
    );
  }

  Workspace copyWith({
    String? id,
    String? name,
    String? description,
    int? createdAt,
    int? updatedAt,
    Map<String, page_model.Page>? pages,
    List<String>? pageOrder,
    Map<String, dynamic>? settings,
  }) => copy(
    id: id,
    name: name,
    description: description,
    createdAt: createdAt,
    updatedAt: updatedAt,
    pages: pages,
    pageOrder: pageOrder,
    settings: settings,
  );

  void addPage(page_model.Page page, {int? index}) {
    (pages ?? {})[page.id.toString()] = page;
    pageOrder = _sanitizePageOrder(pageOrder);
    final po = pageOrder ?? <String>[];
    if (index != null && index >= 0 && index <= po.length) {
      po.insert(index, page.id.toString());
    } else {
      po.add(page.id.toString());
    }
    pageOrder = _sanitizePageOrder(po);
    if ((pageOrder ?? <String>[]).any((e) => e == 'null' || e.isEmpty)) {
      print('Workspace.addPage: pageOrder contains invalid entries after mutation: $pageOrder');
    }
  }

  void removePage(String pageId) {
    (pages ?? {}).remove(pageId.toString());
    pageOrder = _sanitizePageOrder(pageOrder);
    final po = pageOrder ?? <String>[];
    po.remove(pageId.toString());
    pageOrder = _sanitizePageOrder(po);
    if ((pageOrder ?? <String>[]).any((e) => e == 'null' || e.isEmpty)) {
      print('Workspace.removePage: pageOrder contains invalid entries after mutation: $pageOrder');
    }
  }

  void updatePage(page_model.Page page) {
    if ((pages ?? {}).containsKey(page.id.toString())) {
      (pages ?? {})[page.id.toString()] = page;
    }
  }

  void movePage(String pageId, int toIndex) {
    pageOrder = _sanitizePageOrder(pageOrder);
    final pid = pageId.toString();
    final po = pageOrder ?? <String>[];
    final pg = pages ?? {};
    if (!pg.containsKey(pid) || !po.contains(pid)) return;
    po.remove(pid);
    po.insert(toIndex.clamp(0, po.length), pid);
    pageOrder = _sanitizePageOrder(po);
    if ((pageOrder ?? <String>[]).any((e) => e == 'null' || e.isEmpty)) {
      print('Workspace.movePage: pageOrder contains invalid entries after mutation: $pageOrder');
    }
  }

  List<page_model.Page> getOrderedPages() {
    pageOrder = _sanitizePageOrder(pageOrder);
    final po = pageOrder ?? <String>[];
    final pg = pages ?? {};
    return po.map((id) => pg[id.toString()]).whereType<page_model.Page>().toList();
  }

  List<page_model.Page> findPagesByTitle(String title) {
    return (pages ?? {}).values.where((p) => p.title.contains(title)).toList();
  }

  List<page_model.Page> findPagesByTag(String tag) {
    return (pages ?? {}).values.where((p) => p.tags.contains(tag)).toList();
  }

  List<String> getAllTags() {
    return (pages ?? {}).values.expand((p) => p.tags).toSet().toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name ?? '',
      'description': description ?? '',
      'createdAt': createdAt ?? DateTime.now().millisecondsSinceEpoch,
      'updatedAt': updatedAt ?? DateTime.now().millisecondsSinceEpoch,
      'pages': (pages ?? {}).map((k, v) => MapEntry(k, v.toJson())),
      'pageOrder': pageOrder ?? <String>[],
      'settings': settings ?? {},
    };
  }

  static Workspace fromJson(Map<String, dynamic> json, {page_model.Page Function(Map<String, dynamic>)? pageFromJson}) {
    // Debug: print all incoming fields and types
    json.forEach((k, v) {
      print('Workspace.fromJson: $k: ${v.runtimeType} = $v');
    });
    // Defensive decode for pages, pageOrder, settings
    dynamic rawPages = json['pages'];
    if (rawPages is String) {
      try {
        rawPages = rawPages.isNotEmpty ? jsonDecode(rawPages) : {};
      } catch (_) {
        rawPages = {};
      }
    }
    final pageMap = <String, page_model.Page>{};
    if (rawPages is Map) {
      rawPages.forEach((k, v) {
        final keyStr = k?.toString() ?? '';
        if (keyStr.isEmpty) return;
        if (v != null && v is Map<String, dynamic>) {
          if (pageFromJson != null) {
            pageMap[keyStr] = pageFromJson(Map<String, dynamic>.from(v));
          } else {
            // If no pageFromJson, skip or add a stub Page if needed
          }
        }
      });
    }

    dynamic rawSettings = json['settings'];
    if (rawSettings is String) {
      try {
        rawSettings = rawSettings.isNotEmpty ? jsonDecode(rawSettings) : {};
      } catch (err) {
        print('Workspace.fromJson: Failed to decode settings string: $err');
        rawSettings = {};
      }
    }

    // Always reconstruct pageOrder from valid page IDs in pages
    List<String> reconstructedPageOrder = pageMap.keys.where((k) => k.toString().isNotEmpty && k.toString() != 'null').map((k) => k.toString()).toList();
    int parseInt(dynamic value, [int fallback = 0]) {
      try {
        if (value == null) return fallback;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) {
          final parsed = int.tryParse(value);
          return parsed ?? fallback;
        }
        return fallback;
      } catch (err) {
        print('Workspace.fromJson: ERROR casting int field: $err, value=$value, type=${value.runtimeType}');
        return fallback;
      }
    }
    try {
      // Use reconstructedPageOrder for Workspace construction
      String id = '';
      String name = 'Default Workspace';
      String description = '';
      int createdAt = DateTime.now().millisecondsSinceEpoch;
      int updatedAt = DateTime.now().millisecondsSinceEpoch;
      try { id = (json['id'] != null) ? json['id'].toString() : ''; } catch (err) { print('Workspace.fromJson: ERROR casting id: $err, value=${json['id']}, type=${json['id']?.runtimeType}'); }
      try { name = (json['name'] != null) ? json['name'].toString() : 'Default Workspace'; } catch (err) { print('Workspace.fromJson: ERROR casting name: $err, value=${json['name']}, type=${json['name']?.runtimeType}'); }
      try { description = (json['description'] != null) ? json['description'].toString() : ''; } catch (err) { print('Workspace.fromJson: ERROR casting description: $err, value=${json['description']}, type=${json['description']?.runtimeType}'); }
      try { createdAt = parseInt(json['createdAt'], DateTime.now().millisecondsSinceEpoch); } catch (err) { print('Workspace.fromJson: ERROR casting createdAt: $err, value=${json['createdAt']}, type=${json['createdAt']?.runtimeType}'); }
      try { updatedAt = parseInt(json['updatedAt'], DateTime.now().millisecondsSinceEpoch); } catch (err) { print('Workspace.fromJson: ERROR casting updatedAt: $err, value=${json['updatedAt']}, type=${json['updatedAt']?.runtimeType}'); }
      Map<String, dynamic> settings = {};
      try { settings = rawSettings is Map ? Map<String, dynamic>.from(rawSettings) : {}; } catch (err) { print('Workspace.fromJson: ERROR casting settings: $err, value=$rawSettings, type=${rawSettings?.runtimeType}'); }
      return Workspace(
        id: id,
        name: name,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
        pages: pageMap,
        pageOrder: reconstructedPageOrder,
        settings: settings,
      );
    } catch (err, stack) {
      print('Workspace.fromJson: ERROR constructing Workspace: $err\n$stack');
      print('Workspace.fromJson: Failing data: id=${json['id']}, name=${json['name']}, pageOrder=RECONSTRUCTED');
      return Workspace(
        id: '',
        name: 'Error Workspace',
        description: 'Failed to load workspace: $err',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        pages: {},
        pageOrder: [],
        settings: {},
      );
    }
  }

  // For legacy support
  Map<String, dynamic> toMap() => toJson();
  factory Workspace.fromMap(Map<String, dynamic> map) => fromJson(map);

  // Getters for tests
  String get getDescription => description ?? '';
  int get getCreatedAt => createdAt ?? DateTime.now().millisecondsSinceEpoch;
  int get getUpdatedAt => updatedAt ?? DateTime.now().millisecondsSinceEpoch;
}
