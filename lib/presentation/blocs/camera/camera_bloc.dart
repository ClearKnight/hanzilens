import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'camera_event.dart';
part 'camera_state.dart';

/// 相机BLoC
///
/// 负责处理相机相关的状态管理。
class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc() : super(CameraInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<TakePicture>(_onTakePicture);
    on<SwitchCamera>(_onSwitchCamera);
    on<ToggleFlash>(_onToggleFlash);
  }

  /// 初始化相机
  Future<void> _onInitializeCamera(
    InitializeCamera event,
    Emitter<CameraState> emit,
  ) async {
    emit(CameraLoading());
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(const CameraFailure('没有可用的相机'));
        return;
      }
      emit(CameraReady(
        cameras: cameras,
        selectedCamera: cameras.first,
        flashMode: FlashMode.auto,
      ));
    } catch (e) {
      emit(CameraFailure(e.toString()));
    }
  }

  /// 拍照
  Future<void> _onTakePicture(
    TakePicture event,
    Emitter<CameraState> emit,
  ) async {
    if (state is CameraReady) {
      final currentState = state as CameraReady;
      emit(TakingPicture());
      try {
        final image = await event.controller.takePicture();
        emit(PictureTaken(
          imagePath: image.path,
          imageFile: File(image.path),
          cameras: currentState.cameras,
          selectedCamera: currentState.selectedCamera,
          flashMode: currentState.flashMode,
        ));
      } catch (e) {
        emit(CameraFailure(e.toString()));
        emit(currentState); // 返回到拍照前的状态
      }
    }
  }

  /// 切换相机
  void _onSwitchCamera(
    SwitchCamera event,
    Emitter<CameraState> emit,
  ) {
    if (state is CameraReady) {
      final currentState = state as CameraReady;
      final cameras = currentState.cameras;

      // 找到下一个相机
      final currentIndex = cameras.indexOf(currentState.selectedCamera);
      final nextIndex = (currentIndex + 1) % cameras.length;

      emit(CameraReady(
        cameras: cameras,
        selectedCamera: cameras[nextIndex],
        flashMode: currentState.flashMode,
      ));
    }
  }

  /// 切换闪光灯
  void _onToggleFlash(
    ToggleFlash event,
    Emitter<CameraState> emit,
  ) {
    if (state is CameraReady) {
      final currentState = state as CameraReady;

      // 切换闪光灯模式
      FlashMode newFlashMode;
      switch (currentState.flashMode) {
        case FlashMode.off:
          newFlashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newFlashMode = FlashMode.always;
          break;
        case FlashMode.always:
          newFlashMode = FlashMode.torch;
          break;
        case FlashMode.torch:
          newFlashMode = FlashMode.off;
          break;
      }

      emit(CameraReady(
        cameras: currentState.cameras,
        selectedCamera: currentState.selectedCamera,
        flashMode: newFlashMode,
      ));
    }
  }
}
