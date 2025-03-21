import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';

import 'package:hanzilens/core/error/exceptions.dart';
import 'package:hanzilens/core/error/failure.dart';
import 'package:hanzilens/data/datasources/remote/image_recognition_service.dart';
import 'package:hanzilens/data/datasources/remote/chinese_language_service.dart';
import 'package:hanzilens/data/models/recognition_model.dart';
import 'package:hanzilens/domain/entities/recognition.dart';
import 'package:hanzilens/domain/repositories/recognition_repository.dart';

/// 识别存储库实现
///
/// 实现[RecognitionRepository]接口，负责图像识别和结果管理。
class RecognitionRepositoryImpl implements RecognitionRepository {
  final ImageRecognitionService imageRecognitionService;
  final ChineseLanguageService chineseLanguageService;
  final Database database;
  final Uuid uuid = const Uuid();

  RecognitionRepositoryImpl({
    required this.imageRecognitionService,
    required this.chineseLanguageService,
    required this.database,
  });

  @override
  Future<Either<Failure, Recognition>> recognizeImage(File imageFile) async {
    try {
      // 1. 使用图像识别服务识别图像中的物体
      final imageRecognitionResult =
          await imageRecognitionService.recognizeImage(imageFile);

      // 如果识别可信度太低，则返回错误
      if (!imageRecognitionResult.isReliable) {
        return Left(ValidationFailure('图像识别结果可信度过低，请尝试拍摄更清晰的照片'));
      }

      // 2. 使用汉字资源库获取物体的汉语信息
      final chineseWordInfo = await chineseLanguageService.getChineseWordInfo(
        imageRecognitionResult.objectName.toLowerCase(),
      );

      // 3. 创建Recognition实体
      final recognition = RecognitionModel(
        id: uuid.v4(),
        objectName: chineseWordInfo.chinese,
        objectNamePinyin: chineseWordInfo.pinyin,
        objectNameEnglish: chineseWordInfo.englishTranslation,
        confidence: imageRecognitionResult.confidence,
        boundingBox: imageRecognitionResult.boundingBox ?? [0.0, 0.0, 1.0, 1.0],
        timestamp: DateTime.now(),
        imagePath: imageFile.path,
      );

      return Right(recognition);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('识别过程中发生错误: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Recognition>>> getRecentRecognitions() async {
    try {
      // 从数据库获取最近的识别结果，按时间倒序排列
      final List<Map<String, dynamic>> results = await database.query(
        'recognitions',
        orderBy: 'timestamp DESC',
        limit: 20, // 限制返回最近20条
      );

      if (results.isEmpty) {
        return const Right([]);
      }

      // 将数据库结果转换为Recognition对象
      final recognitions =
          results.map((result) => RecognitionModel.fromJson(result)).toList();

      return Right(recognitions);
    } catch (e) {
      return Left(CacheFailure('获取识别历史记录失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveRecognition(Recognition recognition) async {
    try {
      // 将Recognition转换为RecognitionModel，以便使用toJson方法
      final recognitionModel = recognition is RecognitionModel
          ? recognition
          : RecognitionModel.fromEntity(recognition);

      // 保存到数据库
      await database.insert(
        'recognitions',
        recognitionModel.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('保存识别结果失败: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecognition(String id) async {
    try {
      // 从数据库删除指定ID的记录
      final deletedCount = await database.delete(
        'recognitions',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (deletedCount == 0) {
        return Left(CacheFailure('未找到ID为$id的识别记录'));
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('删除识别记录失败: ${e.toString()}'));
    }
  }
}
