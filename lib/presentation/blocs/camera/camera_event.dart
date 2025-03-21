part of 'camera_bloc.dart';

/// 相机事件基类
@immutable
abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object> get props => [];
}

/// 初始化相机事件
class InitializeCamera extends CameraEvent {
  const InitializeCamera();
}

/// 拍照事件
class TakePicture extends CameraEvent {
  final CameraController controller;

  const TakePicture({required this.controller});

  @override
  List<Object> get props => [controller];
}

/// 切换相机事件
class SwitchCamera extends CameraEvent {
  const SwitchCamera();
}

/// 切换闪光灯事件
class ToggleFlash extends CameraEvent {
  const ToggleFlash();
}
