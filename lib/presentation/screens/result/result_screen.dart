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
      appBar: AppBar(
        title: const Text('识别结果'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareResult();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<RecognitionBloc, RecognitionState>(
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
              return _buildSuccessView(context, state.recognition);
            } else if (state is RecognitionFailure) {
              return _buildErrorView(state.message);
            }

            // 默认显示加载中
            return _buildLoadingView();
          },
        ),
      ),
    );
  }

  /// 构建加载中视图
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            '识别中...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  /// 构建错误视图
  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '识别出错',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
            onPressed: _startRecognition,
          ),
        ],
      ),
    );
  }

  /// 构建成功视图
  Widget _buildSuccessView(BuildContext context, Recognition recognition) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图像显示
          _buildImageWithLabels(context, recognition),

          // 识别结果信息
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '识别结果',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 8),

                // 实际识别结果
                _buildRecognitionInfo(
                  chinese: recognition.objectName,
                  pinyin: recognition.objectNamePinyin,
                  english: recognition.objectNameEnglish,
                  confidence: recognition.confidencePercent,
                ),

                const SizedBox(height: 24),

                // 汉字信息
                const Text(
                  '汉字信息',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 8),

                // 汉字详情
                _buildCharacterInfo(recognition),

                const SizedBox(height: 16),

                // MVP阶段隐藏查看详情按钮，因为CharacterDetail页面尚未实现
                // Center(
                //   child: ElevatedButton(
                //     onPressed: () {
                //       Navigator.of(context).pushNamed(
                //         AppRoutes.characterDetail,
                //         arguments: recognition.objectName,
                //       );
                //     },
                //     child: const Text('查看汉字详情'),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建带标签的图像
  Widget _buildImageWithLabels(BuildContext context, Recognition recognition) {
    return Container(
      width: double.infinity,
      height: 300,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
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
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(204),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      recognition.objectName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recognition.objectNamePinyin,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          recognition.objectNameEnglish,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建识别信息
  Widget _buildRecognitionInfo({
    required String chinese,
    required String pinyin,
    required String english,
    required String confidence,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  chinese,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pinyin,
                        style: const TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        english,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('识别置信度:'),
                Chip(
                  label: Text(confidence),
                  backgroundColor: Theme.of(context).primaryColor.withAlpha(51),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建汉字信息
  Widget _buildCharacterInfo([Recognition? recognition]) {
    // 在MVP阶段，可以使用简化的信息
    final examples = [
      '这是一只${recognition?.objectName ?? "猫"}。',
      '我喜欢${recognition?.objectName ?? "猫"}。',
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 使用例句
            const Text(
              '例句:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            for (final example in examples)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $example'),
              ),
          ],
        ),
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
