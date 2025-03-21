import 'package:equatable/equatable.dart';

/// 识别结果实体类
///
/// 表示图像识别的结果。
class Recognition extends Equatable {
  final String id;
  final String objectName;
  final String objectNamePinyin;
  final String objectNameEnglish;
  final double confidence;
  final List<double> boundingBox; // [left, top, right, bottom] 相对坐标
  final DateTime timestamp;
  final String? imagePath;

  const Recognition({
    required this.id,
    required this.objectName,
    required this.objectNamePinyin,
    required this.objectNameEnglish,
    required this.confidence,
    required this.boundingBox,
    required this.timestamp,
    this.imagePath,
  });

  @override
  List<Object?> get props => [
        id,
        objectName,
        objectNamePinyin,
        objectNameEnglish,
        confidence,
        boundingBox,
        timestamp,
        imagePath,
      ];

  // 获取可读的置信度百分比
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  // 判断置信度是否足够高
  bool get isConfident => confidence >= 0.7;
}
