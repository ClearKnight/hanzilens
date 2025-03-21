import 'dart:convert';

import 'package:hanzilens/domain/entities/character.dart';

/// 汉字模型类
///
/// 负责汉字数据的序列化和反序列化。
class CharacterModel extends Character {
  const CharacterModel({
    required String id,
    required String character,
    required String pinyin,
    required String englishTranslation,
    required String description,
    required int strokes,
    required String radical,
    required List<String> examples,
    bool isLearned = false,
    double frequency = 0.0,
  }) : super(
          id: id,
          character: character,
          pinyin: pinyin,
          englishTranslation: englishTranslation,
          description: description,
          strokes: strokes,
          radical: radical,
          examples: examples,
          isLearned: isLearned,
          frequency: frequency,
        );

  /// 从JSON创建模型对象
  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'],
      character: json['character'],
      pinyin: json['pinyin'],
      englishTranslation: json['english_translation'],
      description: json['description'] ?? '',
      strokes: json['strokes'] ?? 0,
      radical: json['radical'] ?? '',
      examples: _parseExamples(json['examples']),
      isLearned: json['is_learned'] == 1,
      frequency: json['frequency']?.toDouble() ?? 0.0,
    );
  }

  /// 从实体创建模型对象
  factory CharacterModel.fromEntity(Character character) {
    return CharacterModel(
      id: character.id,
      character: character.character,
      pinyin: character.pinyin,
      englishTranslation: character.englishTranslation,
      description: character.description,
      strokes: character.strokes,
      radical: character.radical,
      examples: character.examples,
      isLearned: character.isLearned,
      frequency: character.frequency,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'character': character,
      'pinyin': pinyin,
      'english_translation': englishTranslation,
      'description': description,
      'strokes': strokes,
      'radical': radical,
      'examples': jsonEncode(examples),
      'is_learned': isLearned ? 1 : 0,
      'frequency': frequency,
    };
  }

  /// 解析例句
  static List<String> _parseExamples(dynamic examples) {
    if (examples == null) return [];

    if (examples is String) {
      try {
        final List<dynamic> parsedList = jsonDecode(examples);
        return parsedList.map((e) => e.toString()).toList();
      } catch (_) {
        return [examples];
      }
    }

    if (examples is List) {
      return examples.map((e) => e.toString()).toList();
    }

    return [];
  }
}
