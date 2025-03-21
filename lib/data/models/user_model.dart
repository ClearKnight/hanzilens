import 'dart:convert';

import 'package:hanzilens/domain/entities/user_profile.dart';

/// 用户模型类
///
/// 负责用户数据的序列化和反序列化。
class UserModel extends UserProfile {
  const UserModel({
    required String id,
    required String name,
    required String learningLevel,
    required List<String> learnedCharacters,
    required Map<String, dynamic> settings,
    required DateTime createdAt,
    DateTime? lastLoginAt,
  }) : super(
          id: id,
          name: name,
          learningLevel: learningLevel,
          learnedCharacters: learnedCharacters,
          settings: settings,
          createdAt: createdAt,
          lastLoginAt: lastLoginAt,
        );

  /// 从JSON创建模型对象
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      learningLevel: json['learning_level'],
      learnedCharacters: _parseLearnedCharacters(json['learned_characters']),
      settings: _parseSettings(json['settings']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_login_at'])
          : null,
    );
  }

  /// 从实体创建模型对象
  factory UserModel.fromEntity(UserProfile user) {
    return UserModel(
      id: user.id,
      name: user.name,
      learningLevel: user.learningLevel,
      learnedCharacters: List<String>.from(user.learnedCharacters),
      settings: Map<String, dynamic>.from(user.settings),
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'learning_level': learningLevel,
      'learned_characters': jsonEncode(learnedCharacters),
      'settings': jsonEncode(settings),
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_login_at': lastLoginAt?.millisecondsSinceEpoch,
    };
  }

  /// 解析已学习的汉字
  static List<String> _parseLearnedCharacters(dynamic learnedCharacters) {
    if (learnedCharacters == null) return [];

    if (learnedCharacters is String) {
      try {
        final List<dynamic> parsedList = jsonDecode(learnedCharacters);
        return parsedList.map((e) => e.toString()).toList();
      } catch (_) {
        return [];
      }
    }

    if (learnedCharacters is List) {
      return learnedCharacters.map((e) => e.toString()).toList();
    }

    return [];
  }

  /// 解析设置
  static Map<String, dynamic> _parseSettings(dynamic settings) {
    if (settings == null) return {};

    if (settings is String) {
      try {
        final Map<String, dynamic> parsedMap = jsonDecode(settings);
        return parsedMap;
      } catch (_) {
        return {};
      }
    }

    if (settings is Map) {
      return Map<String, dynamic>.from(settings);
    }

    return {};
  }
}
