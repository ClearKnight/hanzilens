import 'package:equatable/equatable.dart';

/// 用户配置实体类
///
/// 表示用户的配置和学习进度。
class UserProfile extends Equatable {
  final String id;
  final String name;
  final String learningLevel; // beginner, intermediate, advanced
  final List<String> learnedCharacters;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.learningLevel,
    required this.learnedCharacters,
    required this.settings,
    required this.createdAt,
    this.lastLoginAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        learningLevel,
        learnedCharacters,
        settings,
        createdAt,
        lastLoginAt,
      ];

  // 检查汉字是否已学习
  bool hasLearned(String character) {
    return learnedCharacters.contains(character);
  }

  // 获取学习级别的显示名称
  String get learningLevelName {
    switch (learningLevel) {
      case 'beginner':
        return '初级';
      case 'intermediate':
        return '中级';
      case 'advanced':
        return '高级';
      default:
        return '未知';
    }
  }
}
