import 'package:flutter/material.dart';
import 'base_block.dart';

/// Mermaid diagram block for creating diagrams
class MermaidBlock extends Block {
  String code;
  String? caption;
  
  MermaidBlock({
    String? id,
    required String code,
    String? caption,
    String? parentId,
  }) : code = code,
       caption = caption,
       super(
         id: id,
         type: 'mermaid',
         parentId: parentId,
       );
  
  @override
  Block copy() {
    return MermaidBlock(
      code: code,
      caption: caption,
      parentId: parentId ?? '',
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'parent_id': parentId,
      'code': code,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Create a mermaid block from a JSON map
  factory MermaidBlock.fromJson(Map<String, dynamic> json) {
    return MermaidBlock(
      id: json['id'] as String,
      code: json['code'] as String,
      caption: json['caption'] as String?,
      parentId: (json['parent_id'] as String?) ?? '',
    );
  }
}

/// Math equation block using LaTeX
class MathBlock extends Block {
  String equation;
  bool isInline;
  
  MathBlock({
    String? id,
    required String equation,
    bool isInline = false,
    required String parentId,
  }) : equation = equation,
       isInline = isInline,
       super(
         id: id,
         type: 'math',
         parentId: parentId,
       );
  
  @override
  Block copy() {
    return MathBlock(
      equation: equation,
      isInline: isInline,
      parentId: parentId ?? '',
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'parent_id': parentId,
      'equation': equation,
      'is_inline': isInline,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Create a math block from a JSON map
  factory MathBlock.fromJson(Map<String, dynamic> json) {
    return MathBlock(
      id: json['id'] as String,
      equation: json['equation'] as String,
      isInline: json['is_inline'] as bool,
      parentId: (json['parent_id'] as String?) ?? '',
    );
  }
}

/// Embed block for external content
class EmbedBlock extends Block {
  String url;
  String? html;
  double? aspectRatio;
  
  EmbedBlock({
    String? id,
    required String url,
    String? html,
    double? aspectRatio,
    required String parentId,
  }) : url = url,
       html = html,
       aspectRatio = aspectRatio,
       super(
         id: id,
         type: 'embed',
         parentId: parentId,
       );
  
  @override
  Block copy() {
    return EmbedBlock(
      url: url,
      html: html,
      aspectRatio: aspectRatio,
      parentId: parentId ?? '',
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'parent_id': parentId,
      'url': url,
      'html': html,
      'aspect_ratio': aspectRatio,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Create an embed block from a JSON map
  factory EmbedBlock.fromJson(Map<String, dynamic> json) {
    return EmbedBlock(
      id: json['id'] as String,
      url: json['url'] as String,
      html: json['html'] as String?,
      aspectRatio: json['aspect_ratio'] as double?,
      parentId: (json['parent_id'] as String?) ?? '',
    );
  }
}

/// AI-generated content block
class AIBlock extends Block {
  String prompt;
  String content;
  String model;
  
  AIBlock({
    String? id,
    required String prompt,
    required String content,
    required String model,
    required String parentId,
  }) : prompt = prompt,
       content = content,
       model = model,
       super(
         id: id,
         type: 'ai',
         parentId: parentId,
       );
  
  @override
  Block copy() {
    return AIBlock(
      prompt: prompt,
      content: content,
      model: model,
      parentId: parentId ?? '',
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'parent_id': parentId,
      'prompt': prompt,
      'content': content,
      'model': model,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Create an AI block from a JSON map
  factory AIBlock.fromJson(Map<String, dynamic> json) {
    return AIBlock(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      content: json['content'] as String,
      model: json['model'] as String,
      parentId: (json['parent_id'] as String?) ?? '',
    );
  }
}
