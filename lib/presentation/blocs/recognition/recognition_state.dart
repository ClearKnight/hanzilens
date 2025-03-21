import 'package:equatable/equatable.dart';
import 'package:hanzilens/domain/entities/recognition.dart';

/// 识别Bloc状态
abstract class RecognitionState extends Equatable {
  const RecognitionState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class RecognitionInitial extends RecognitionState {}

/// 识别加载中状态
class RecognitionLoading extends RecognitionState {}

/// 识别历史加载中状态
class RecognitionHistoryLoading extends RecognitionState {}

/// 识别成功状态
class RecognitionSuccess extends RecognitionState {
  final Recognition recognition;

  const RecognitionSuccess({required this.recognition});

  @override
  List<Object> get props => [recognition];
}

/// 识别历史加载成功状态
class RecognitionHistorySuccess extends RecognitionState {
  final List<Recognition> recognitions;

  const RecognitionHistorySuccess({required this.recognitions});

  @override
  List<Object> get props => [recognitions];
}

/// 识别失败状态
class RecognitionFailure extends RecognitionState {
  final String message;

  const RecognitionFailure({required this.message});

  @override
  List<Object> get props => [message];
}

/// 保存成功状态
class SaveRecognitionSuccess extends RecognitionState {
  final Recognition recognition;

  const SaveRecognitionSuccess({required this.recognition});

  @override
  List<Object> get props => [recognition];
}

/// 删除成功状态
class DeleteRecognitionSuccess extends RecognitionState {
  final String id;

  const DeleteRecognitionSuccess({required this.id});

  @override
  List<Object> get props => [id];
}
