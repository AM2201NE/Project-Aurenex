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
    this.name = 'Default Workspace',
    this.description = '',
    this.createdAt,
    this.updatedAt,
    Map<String, page_model.Page>? pages,
    List<dynamic>? pageOrder,
    this.settings,
  })  : pages = pages ?? {},
        pageOrder = _sanitizePageOrder(pageOrder),
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch,
        settings = settings ?? {};

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
    try {
      print('Workspace.fromJson input: $json');
      final pageMap = <String, page_model.Page>{};
      if (json['pages'] is String && json['pages'].isNotEmpty) {
        try {
          final decodedPages = jsonDecode(json['pages']) as Map<String, dynamic>;
          decodedPages.forEach((key, value) {
            if (pageFromJson != null) {
              pageMap[key] = pageFromJson(value as Map<String, dynamic>);
            } else {
              pageMap[key] = page_model.Page.fromJson(value as Map<String, dynamic>);
            }
          });
        } catch (e) {
          print('Error decoding pages in Workspace.fromJson: $e');
        }
      } else if (json['pages'] is Map) {
        (json['pages'] as Map).forEach((key, value) {
          if (pageFromJson != null) {
            pageMap[key as String] = pageFromJson(value as Map<String, dynamic>);
          } else {
            pageMap[key as String] = page_model.Page.fromJson(value as Map<String, dynamic>);
          }
        });
      }

      List<String> pageOrder = [];
      if (json['pageOrder'] is String && json['pageOrder'].isNotEmpty) {
        try {
          final decodedPageOrder = jsonDecode(json['pageOrder']) as List<dynamic>;
          pageOrder = decodedPageOrder.map((e) => e.toString()).toList();
        } catch (e) {
          print('Error decoding pageOrder in Workspace.fromJson: $e');
        }
      } else if (json['pageOrder'] is List) {
        pageOrder = (json['pageOrder'] as List).map((e) => e.toString()).toList();
      }

      Map<String, dynamic> settings = {};
      if (json['settings'] is String && json['settings'].isNotEmpty) {
        try {
          settings = jsonDecode(json['settings']) as Map<String, dynamic>;
        } catch (e) {
          print('Error decoding settings in Workspace.fromJson: $e');
        }
      } else if (json['settings'] is Map) {
        settings = json['settings'] as Map<String, dynamic>;
      }

      final workspace = Workspace(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Default Workspace',
        description: json['description']?.toString() ?? '',
        createdAt: int.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt: int.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch,
        pages: pageMap,
        pageOrder: pageOrder,
        settings: settings,
      );
      print('Workspace.fromJson output: ${workspace.toJson()}');
      return workspace;
    } catch (e, stacktrace) {
      print('Error in Workspace.fromJson: $e');
      print(stacktrace);
      return Workspace(
        id: 'default',
        name: 'Default Workspace',
        pages: {},
        pageOrder: [],
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        description: 'Error loading workspace: $e',
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
