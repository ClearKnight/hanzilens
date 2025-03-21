import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:hanzilens/app/routes.dart';
import 'package:hanzilens/presentation/blocs/camera/camera_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

/// 相机屏幕
///
/// 用于拍照识别物体。
class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    // App state changed before camera was initialized
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeControllerForCamera(cameraController.description);
    }
  }

  /// 请求相机权限
  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      // 请求相机初始化
      context.read<CameraBloc>().add(const InitializeCamera());
    }
  }

  /// 为指定的相机初始化控制器
  Future<void> _initializeControllerForCamera(
      CameraDescription cameraDescription) async {
    final CameraController controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _cameraController = controller;

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {});
      }
    } on CameraException catch (e) {
      _showCameraError(e.description ?? '相机初始化失败');
    }
  }

  /// 拍照
  Future<void> _takePicture() async {
    final cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      _showCameraError('相机未初始化');
      return;
    }

    if (cameraController.value.isTakingPicture) {
      return;
    }

    context.read<CameraBloc>().add(TakePicture(controller: cameraController));
  }

  /// 切换闪光灯
  void _toggleFlash() {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });

      _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    }
  }

  /// 显示相机错误
  void _showCameraError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('相机错误: $message')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<CameraBloc, CameraState>(
        listener: (context, state) {
          if (state is CameraReady && _cameraController == null) {
            _initializeControllerForCamera(state.selectedCamera);
          } else if (state is PictureTaken) {
            Navigator.of(context).pushNamed(
              AppRoutes.result,
              arguments: state.imagePath,
            );
          } else if (state is CameraFailure) {
            _showCameraError(state.message);
          }
        },
        builder: (context, state) {
          if (state is CameraLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          if (state is CameraReady || state is TakingPicture) {
            return _buildCameraUI();
          }

          return const Center(
            child: Text(
              '初始化相机中...',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  /// 构建相机UI
  Widget _buildCameraUI() {
    final cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    return Stack(
      children: [
        // 相机预览
        Positioned.fill(
          child: AspectRatio(
            aspectRatio: cameraController.value.aspectRatio,
            child: CameraPreview(cameraController),
          ),
        ),

        // 顶部控制栏
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 关闭按钮
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  // 闪光灯和计时器控制
                  Row(
                    children: [
                      // 闪光灯按钮
                      GestureDetector(
                        onTap: _toggleFlash,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.only(right: 16.0),
                          child: Icon(
                            _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      // 计时器按钮
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('计时器功能尚未实现'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: const Icon(
                            Icons.timer,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // 底部控制栏
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 缩略图（假的，目前不可点击）
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      color: Colors.black.withAlpha(77),
                    ),
                  ),

                  // 快门按钮
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(77),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black.withAlpha(51),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                    ),
                  ),

                  // 翻转相机按钮
                  GestureDetector(
                    onTap: () {
                      context.read<CameraBloc>().add(const SwitchCamera());
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.withAlpha(128),
                      ),
                      child: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
