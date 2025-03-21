import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:hanzilens/domain/entities/recognition.dart';

/// 识别Bloc事件
abstract class RecognitionEvent extends Equatable {
  const RecognitionEvent();

  @override
  List<Object?> get props => [];
}

/// 开始图像识别事件
class StartRecognition extends RecognitionEvent {
  final File imageFile;

  const StartRecognition({required this.imageFile});

  @override
  List<Object> get props => [imageFile];
}

/// 保存识别结果事件
class SaveRecognitionResult extends RecognitionEvent {
  final Recognition recognition;

  const SaveRecognitionResult({required this.recognition});

  @override
  List<Object> get props => [recognition];
}

/// 加载最近识别历史事件
class LoadRecentRecognitions extends RecognitionEvent {}

/// 删除识别结果事件
class DeleteRecognition extends RecognitionEvent {
  final String id;

  const DeleteRecognition({required this.id});

  @override
  List<Object> get props => [id];
}

/// 重置识别状态事件
class ResetRecognition extends RecognitionEvent {}
