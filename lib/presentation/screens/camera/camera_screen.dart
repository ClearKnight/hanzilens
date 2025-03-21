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

  /// 显示相机错误
  void _showCameraError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('相机错误: $message')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('拍照识别'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              context.read<CameraBloc>().add(const ToggleFlash());
            },
          ),
        ],
      ),
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
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CameraReady || state is TakingPicture) {
            return _buildCameraPreview();
          }

          return const Center(
            child: Text('初始化相机中...'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 构建相机预览
  Widget _buildCameraPreview() {
    final cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1 / cameraController.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CameraPreview(cameraController),
                // 添加取景框
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(60),
                  ),
                ),
                // 指导文本
                Positioned(
                  bottom: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '将物体放在框内，点击拍照按钮',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
