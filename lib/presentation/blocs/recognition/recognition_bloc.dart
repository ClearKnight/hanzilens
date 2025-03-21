import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:hanzilens/core/error/failure.dart';
import 'package:hanzilens/domain/entities/recognition.dart';
import 'package:hanzilens/domain/usecases/recognize_image.dart' as use_cases;
import 'package:hanzilens/presentation/blocs/recognition/recognition_event.dart';
import 'package:hanzilens/presentation/blocs/recognition/recognition_state.dart';

/// 识别Bloc
///
/// 负责处理图像识别相关的状态管理。
class RecognitionBloc extends Bloc<RecognitionEvent, RecognitionState> {
  final use_cases.RecognizeImage recognizeImage;

  RecognitionBloc({required this.recognizeImage})
      : super(RecognitionInitial()) {
    on<StartRecognition>(_onStartRecognition);
    on<SaveRecognitionResult>(_onSaveRecognitionResult);
    on<LoadRecentRecognitions>(_onLoadRecentRecognitions);
    on<DeleteRecognition>(_onDeleteRecognition);
    on<ResetRecognition>(_onResetRecognition);
  }

  /// 处理开始识别事件
  Future<void> _onStartRecognition(
    StartRecognition event,
    Emitter<RecognitionState> emit,
  ) async {
    emit(RecognitionLoading());

    // 调用识别用例
    final result = await recognizeImage(
      use_cases.RecognizeImageParams(imageFile: event.imageFile),
    );

    // 处理识别结果，根据Either类型分发成功或失败状态
    emit(_eitherSuccessOrFailure(result));
  }

  /// 处理保存识别结果事件
  Future<void> _onSaveRecognitionResult(
    SaveRecognitionResult event,
    Emitter<RecognitionState> emit,
  ) async {
    // 这里我们假设有一个SaveRecognition用例，在完整实现中应该注入该依赖
    // 由于MVP阶段简化，我们暂时直接返回成功状态
    emit(SaveRecognitionSuccess(recognition: event.recognition));
  }

  /// 处理加载最近识别历史事件
  Future<void> _onLoadRecentRecognitions(
    LoadRecentRecognitions event,
    Emitter<RecognitionState> emit,
  ) async {
    emit(RecognitionHistoryLoading());

    // 这里我们假设有一个GetRecentRecognitions用例，在完整实现中应该注入该依赖
    // 由于MVP阶段简化，我们暂时直接返回空列表
    emit(const RecognitionHistorySuccess(recognitions: []));
  }

  /// 处理删除识别结果事件
  Future<void> _onDeleteRecognition(
    DeleteRecognition event,
    Emitter<RecognitionState> emit,
  ) async {
    // 这里我们假设有一个DeleteRecognition用例，在完整实现中应该注入该依赖
    // 由于MVP阶段简化，我们暂时直接返回成功状态
    emit(DeleteRecognitionSuccess(id: event.id));
  }

  /// 处理重置识别状态事件
  void _onResetRecognition(
    ResetRecognition event,
    Emitter<RecognitionState> emit,
  ) {
    emit(RecognitionInitial());
  }

  /// 将Either结果转换为对应的状态
  RecognitionState _eitherSuccessOrFailure(
    Either<Failure, Recognition> result,
  ) {
    return result.fold(
      (failure) => RecognitionFailure(message: _mapFailureToMessage(failure)),
      (recognition) => RecognitionSuccess(recognition: recognition),
    );
  }

  /// 将Failure类型映射为用户友好的错误消息
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return '服务器错误: ${failure.message}';
      case NetworkFailure:
        return '网络错误: ${failure.message}';
      case ValidationFailure:
        return failure.message;
      default:
        return '未知错误: ${failure.message}';
    }
  }
}
