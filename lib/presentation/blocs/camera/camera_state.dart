part of 'camera_bloc.dart';

/// 相机状态基类
@immutable
abstract class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object> get props => [];
}

/// 初始状态
class CameraInitial extends CameraState {}

/// 相机加载中状态
class CameraLoading extends CameraState {}

/// 相机就绪状态
class CameraReady extends CameraState {
  final List<CameraDescription> cameras;
  final CameraDescription selectedCamera;
  final FlashMode flashMode;

  const CameraReady({
    required this.cameras,
    required this.selectedCamera,
    required this.flashMode,
  });

  @override
  List<Object> get props => [cameras, selectedCamera, flashMode];
}

/// 正在拍照状态
class TakingPicture extends CameraState {}

/// 拍照完成状态
class PictureTaken extends CameraReady {
  final String imagePath;
  final File imageFile;

  const PictureTaken({
    required this.imagePath,
    required this.imageFile,
    required List<CameraDescription> cameras,
    required CameraDescription selectedCamera,
    required FlashMode flashMode,
  }) : super(
          cameras: cameras,
          selectedCamera: selectedCamera,
          flashMode: flashMode,
        );

  @override
  List<Object> get props => [imagePath, imageFile, ...super.props];
}

/// 相机错误状态
class CameraFailure extends CameraState {
  final String message;

  const CameraFailure(this.message);

  @override
  List<Object> get props => [message];
}
