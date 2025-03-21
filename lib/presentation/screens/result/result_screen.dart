import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzilens/domain/entities/recognition.dart';
import 'package:hanzilens/presentation/blocs/recognition/recognition_bloc.dart';
import 'package:hanzilens/presentation/blocs/recognition/recognition_event.dart';
import 'package:hanzilens/presentation/blocs/recognition/recognition_state.dart';

/// 识别结果屏幕
///
/// 显示图像识别的结果和相关汉字信息。
class ResultScreen extends StatefulWidget {
  final String imagePath;

  const ResultScreen({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    // 启动识别过程
    _startRecognition();
  }

  /// 启动识别过程
  void _startRecognition() {
    final file = File(widget.imagePath);
    context.read<RecognitionBloc>().add(StartRecognition(imageFile: file));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<RecognitionBloc, RecognitionState>(
        listener: (context, state) {
          if (state is RecognitionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is SaveRecognitionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已添加到学习记录')),
            );
          }
        },
        builder: (context, state) {
          if (state is RecognitionLoading) {
            return _buildLoadingView();
          } else if (state is RecognitionSuccess) {
            return _buildSuccessView(state.recognition);
          } else if (state is RecognitionFailure) {
            return _buildErrorView(state.message);
          }

          // 默认显示加载中
          return _buildLoadingView();
        },
      ),
    );
  }

  /// 构建加载中视图
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            '识别中...',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误视图
  Widget _buildErrorView(String message) {
    return SafeArea(
      child: Column(
        children: [
          // 顶部导航栏
          _buildHeader(hasResult: false),

          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '识别出错',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _startRecognition,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建头部导航栏
  Widget _buildHeader({required bool hasResult}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Row(
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  size: 14,
                  color: Color(0xFF1E88E5),
                ),
                Text(
                  '返回',
                  style: TextStyle(
                    color: Color(0xFF1E88E5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // 页面标题
          const Text(
            '识别结果',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          // 分享按钮
          if (hasResult)
            GestureDetector(
              onTap: _shareResult,
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(
                  Icons.share,
                  color: Color(0xFF1E88E5),
                  size: 20,
                ),
              ),
            )
          else
            const SizedBox(width: 30),
        ],
      ),
    );
  }

  /// 构建成功视图
  Widget _buildSuccessView(Recognition recognition) {
    return SafeArea(
      child: Column(
        children: [
          // 顶部导航栏
          _buildHeader(hasResult: true),

          // 图像和识别信息
          Expanded(
            child: Column(
              children: [
                // 图像与标签
                Expanded(
                  flex: 3,
                  child: _buildImageWithLabels(recognition),
                ),

                // 底部信息卡片
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFFEEEEEE),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 准确度指示行
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '识别准确度',
                            style: TextStyle(
                              color: Color(0xFF777777),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            recognition.confidencePercent,
                            style: const TextStyle(
                              color: Color(0xFF777777),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 汉字详情
                      _buildCharacterDetail(recognition),
                      const SizedBox(height: 16),

                      // 学习笔记
                      const Text(
                        '学习笔记',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• ${recognition.objectName}的正确发音是 ${recognition.objectNamePinyin}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF555555),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• ${recognition.objectName}在英语中表示 ${recognition.objectNameEnglish}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF555555),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 例句
                      Text(
                        '• 例句: 这是一个${recognition.objectName}。',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF555555),
                        ),
                      ),
                      Text(
                        '• 例句: 我喜欢${recognition.objectName}。',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建图像和标签
  Widget _buildImageWithLabels(Recognition recognition) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 图像
          Image.file(
            File(widget.imagePath),
            fit: BoxFit.cover,
          ),

          // 标签
          Positioned(
            bottom: 40,
            left: 20,
            child: _buildLabel(
              character: recognition.objectName,
              pinyin: recognition.objectNamePinyin,
              english: recognition.objectNameEnglish,
              connectorHeight: 40,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建标签
  Widget _buildLabel({
    required String character,
    required String pinyin,
    required String english,
    required double connectorHeight,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 标签连接线
        Positioned(
          bottom: -connectorHeight,
          left: 60,
          child: Container(
            width: 2,
            height: connectorHeight,
            color: const Color(0xFFFFC107),
          ),
        ),

        // 标签内容
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拼音和英文
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pinyin,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    english,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),

              // 汉字
              Text(
                character,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建汉字详情
  Widget _buildCharacterDetail(Recognition recognition) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // 汉字
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                recognition.objectName,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E88E5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // 详情信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recognition.objectNamePinyin,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recognition.objectNameEnglish,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '名词',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '常用',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 分享识别结果
  void _shareResult() {
    final state = context.read<RecognitionBloc>().state;
    if (state is RecognitionSuccess) {
      final recognition = state.recognition;
      final shareText =
          '我通过HanziLens识别出了"${recognition.objectName}"(${recognition.objectNamePinyin}), 意思是"${recognition.objectNameEnglish}"!';

      // 将文本复制到剪贴板
      Clipboard.setData(ClipboardData(text: shareText));

      // 显示提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('识别结果已复制到剪贴板，可以粘贴到其他应用分享'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
