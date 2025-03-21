import 'package:equatable/equatable.dart';

/// 汉字实体类
///
/// 表示应用中的汉字对象。
class Character extends Equatable {
  final String id;
  final String character;
  final String pinyin;
  final String englishTranslation;
  final String description;
  final int strokes;
  final String radical;
  final List<String> examples;
  final bool isLearned;
  final double frequency;

  const Character({
    required this.id,
    required this.character,
    required this.pinyin,
    required this.englishTranslation,
    required this.description,
    required this.strokes,
    required this.radical,
    required this.examples,
    this.isLearned = false,
    this.frequency = 0.0,
  });

  @override
  List<Object> get props => [
        id,
        character,
        pinyin,
        englishTranslation,
        description,
        strokes,
        radical,
        examples,
        isLearned,
        frequency,
      ];
}
