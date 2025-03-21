import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hanzilens/core/error/failure.dart';
import 'package:hanzilens/core/usecases/usecase.dart';
import 'package:hanzilens/domain/entities/recognition.dart';
import 'package:hanzilens/domain/repositories/recognition_repository.dart';

/// 识别图像用例
class RecognizeImage implements UseCase<Recognition, RecognizeImageParams> {
  final RecognitionRepository repository;

  RecognizeImage(this.repository);

  @override
  Future<Either<Failure, Recognition>> call(RecognizeImageParams params) async {
    return await repository.recognizeImage(params.imageFile);
  }
}

/// 获取最近识别结果用例
class GetRecentRecognitions implements UseCase<List<Recognition>, NoParams> {
  final RecognitionRepository repository;

  GetRecentRecognitions(this.repository);

  @override
  Future<Either<Failure, List<Recognition>>> call(NoParams params) async {
    return await repository.getRecentRecognitions();
  }
}

/// 保存识别结果用例
class SaveRecognition implements UseCase<void, SaveRecognitionParams> {
  final RecognitionRepository repository;

  SaveRecognition(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveRecognitionParams params) async {
    return await repository.saveRecognition(params.recognition);
  }
}

/// 删除识别结果用例
class DeleteRecognition implements UseCase<void, DeleteRecognitionParams> {
  final RecognitionRepository repository;

  DeleteRecognition(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteRecognitionParams params) async {
    return await repository.deleteRecognition(params.id);
  }
}

/// 识别图像参数
class RecognizeImageParams extends Equatable {
  final File imageFile;

  const RecognizeImageParams({required this.imageFile});

  @override
  List<Object> get props => [imageFile];
}

/// 保存识别结果参数
class SaveRecognitionParams extends Equatable {
  final Recognition recognition;

  const SaveRecognitionParams({required this.recognition});

  @override
  List<Object> get props => [recognition];
}

/// 删除识别结果参数
class DeleteRecognitionParams extends Equatable {
  final String id;

  const DeleteRecognitionParams({required this.id});

  @override
  List<Object> get props => [id];
}
