import 'dart:convert';

import 'package:hanzilens/domain/entities/recognition.dart';

/// 识别模型类
///
/// 负责识别数据的序列化和反序列化。
class RecognitionModel extends Recognition {
  const RecognitionModel({
    required String id,
    required String objectName,
    required String objectNamePinyin,
    required String objectNameEnglish,
    required double confidence,
    required List<double> boundingBox,
    required DateTime timestamp,
    String? imagePath,
  }) : super(
          id: id,
          objectName: objectName,
          objectNamePinyin: objectNamePinyin,
          objectNameEnglish: objectNameEnglish,
          confidence: confidence,
          boundingBox: boundingBox,
          timestamp: timestamp,
          imagePath: imagePath,
        );

  /// 从JSON创建模型对象
  factory RecognitionModel.fromJson(Map<String, dynamic> json) {
    return RecognitionModel(
      id: json['id'],
      objectName: json['object_name'],
      objectNamePinyin: json['object_name_pinyin'],
      objectNameEnglish: json['object_name_english'],
      confidence: json['confidence']?.toDouble() ?? 0.0,
      boundingBox: _parseBoundingBox(json['bounding_box']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      imagePath: json['image_path'],
    );
  }

  /// 从实体创建模型对象
  factory RecognitionModel.fromEntity(Recognition recognition) {
    return RecognitionModel(
      id: recognition.id,
      objectName: recognition.objectName,
      objectNamePinyin: recognition.objectNamePinyin,
      objectNameEnglish: recognition.objectNameEnglish,
      confidence: recognition.confidence,
      boundingBox: List<double>.from(recognition.boundingBox),
      timestamp: recognition.timestamp,
      imagePath: recognition.imagePath,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object_name': objectName,
      'object_name_pinyin': objectNamePinyin,
      'object_name_english': objectNameEnglish,
      'confidence': confidence,
      'bounding_box': jsonEncode(boundingBox),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'image_path': imagePath,
    };
  }

  /// 解析边界框数据
  static List<double> _parseBoundingBox(dynamic boundingBox) {
    if (boundingBox == null) {
      return [0.0, 0.0, 0.0, 0.0];
    }

    if (boundingBox is String) {
      try {
        final List<dynamic> parsedList = jsonDecode(boundingBox);
        return parsedList.map((e) => double.parse(e.toString())).toList();
      } catch (_) {
        return [0.0, 0.0, 0.0, 0.0];
      }
    }

    if (boundingBox is List) {
      return boundingBox.map((e) => double.parse(e.toString())).toList();
    }

    return [0.0, 0.0, 0.0, 0.0];
  }
}
