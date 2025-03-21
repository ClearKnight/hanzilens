import 'dart:io';

/// 图像识别服务接口
///
/// 定义了所有与图像识别相关的远程API操作。
abstract class ImageRecognitionService {
  /// 识别图像中的物体
  ///
  /// 参数：
  /// - [imageFile]: 需要识别的图像文件
  ///
  /// 返回：
  /// 识别结果，包含物体名称、置信度等信息
  Future<ImageRecognitionResult> recognizeImage(File imageFile);

  /// 批量识别图像中的物体
  ///
  /// 参数：
  /// - [imageFiles]: 需要识别的图像文件列表
  ///
  /// 返回：
  /// 识别结果列表
  Future<List<ImageRecognitionResult>> recognizeImages(List<File> imageFiles);
}

/// 图像识别结果类
///
/// 表示从图像识别API返回的结果。
class ImageRecognitionResult {
  /// 识别出的物体英文名称
  final String objectName;

  /// 识别出的物体中文名称（如果API直接返回）
  final String? objectNameChinese;

  /// 置信度，范围0.0-1.0
  final double confidence;

  /// 物体在图像中的位置 [left, top, width, height]，归一化为0.0-1.0
  final List<double>? boundingBox;

  /// 原始API响应的附加信息
  final Map<String, dynamic>? additionalInfo;

  const ImageRecognitionResult({
    required this.objectName,
    this.objectNameChinese,
    required this.confidence,
    this.boundingBox,
    this.additionalInfo,
  });

  /// 判断识别结果是否可信
  bool get isReliable => confidence >= 0.7;

  /// 获取格式化的置信度，如"95.5%"
  String get confidenceFormatted => '${(confidence * 100).toStringAsFixed(1)}%';
}
