import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:hanzilens/core/error/failure.dart';
import 'package:hanzilens/domain/entities/recognition.dart';

/// 识别存储库接口
///
/// 定义了所有与图像识别相关的数据操作。
abstract class RecognitionRepository {
  /// 识别图像
  Future<Either<Failure, Recognition>> recognizeImage(File imageFile);

  /// 获取最近识别结果
  Future<Either<Failure, List<Recognition>>> getRecentRecognitions();

  /// 保存识别结果
  Future<Either<Failure, void>> saveRecognition(Recognition recognition);

  /// 删除识别结果
  Future<Either<Failure, void>> deleteRecognition(String id);
}
