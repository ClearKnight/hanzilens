import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:hanzilens/core/error/exceptions.dart';
import 'package:hanzilens/data/datasources/remote/image_recognition_service.dart';

/// Google Cloud Vision API服务实现
///
/// 使用Google Cloud Vision API进行图像识别。
class GoogleVisionService implements ImageRecognitionService {
  final http.Client client;
  final String apiKey;
  final String apiEndpoint = 'https://vision.googleapis.com/v1/images:annotate';
  final Uuid uuid = const Uuid();

  GoogleVisionService({
    required this.client,
    required this.apiKey,
  });

  @override
  Future<ImageRecognitionResult> recognizeImage(File imageFile) async {
    try {
      // 1. 读取图像文件并进行base64编码
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      // 2. 构建API请求体
      final Map<String, dynamic> requestBody = {
        'requests': [
          {
            'image': {
              'content': base64Image,
            },
            'features': [
              {
                'type': 'LABEL_DETECTION',
                'maxResults': 10,
              },
              {
                'type': 'OBJECT_LOCALIZATION',
                'maxResults': 5,
              }
            ],
          }
        ]
      };

      // 3. 发送HTTP请求
      final response = await client.post(
        Uri.parse('$apiEndpoint?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // 4. 处理响应
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return _parseVisionResponse(jsonResponse);
      } else {
        throw ServerException(
          'API错误: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException {
      throw NetworkException('网络连接失败，请检查网络');
    } on FormatException {
      throw ServerException('服务器返回格式错误');
    } catch (e) {
      throw ServerException('识别过程中发生错误: ${e.toString()}');
    }
  }

  @override
  Future<List<ImageRecognitionResult>> recognizeImages(
      List<File> imageFiles) async {
    // 批量处理，简单实现为串行处理每个图像
    final results = <ImageRecognitionResult>[];
    for (final file in imageFiles) {
      results.add(await recognizeImage(file));
    }
    return results;
  }

  /// 解析Google Vision API的响应
  ImageRecognitionResult _parseVisionResponse(Map<String, dynamic> response) {
    try {
      final responses = response['responses'] as List;
      if (responses.isEmpty) {
        throw ServerException('API返回的响应为空');
      }

      final firstResponse = responses[0] as Map<String, dynamic>;

      // 解析标签检测结果
      final labels = firstResponse['labelAnnotations'] as List? ?? [];
      if (labels.isEmpty) {
        throw ServerException('未能识别出图像中的物体');
      }

      // 获取最高置信度的标签
      final topLabel = labels[0] as Map<String, dynamic>;
      final String objectName = topLabel['description'] ?? 'unknown';
      final double confidence = topLabel['score']?.toDouble() ?? 0.0;

      // 解析物体定位信息（如果有）
      List<double>? boundingBox;
      if (firstResponse.containsKey('localizedObjectAnnotations')) {
        final objects = firstResponse['localizedObjectAnnotations'] as List;
        if (objects.isNotEmpty) {
          final topObject = objects[0] as Map<String, dynamic>;
          final boundingPoly =
              topObject['boundingPoly'] as Map<String, dynamic>?;
          if (boundingPoly != null) {
            final vertices = boundingPoly['normalizedVertices'] as List;
            // 计算边界框 [left, top, width, height]
            double minX = 1.0, minY = 1.0, maxX = 0.0, maxY = 0.0;
            for (final vertex in vertices) {
              final x = vertex['x']?.toDouble() ?? 0.0;
              final y = vertex['y']?.toDouble() ?? 0.0;
              minX = x < minX ? x : minX;
              minY = y < minY ? y : minY;
              maxX = x > maxX ? x : maxX;
              maxY = y > maxY ? y : maxY;
            }
            boundingBox = [minX, minY, maxX - minX, maxY - minY];
          }
        }
      }

      return ImageRecognitionResult(
        objectName: objectName,
        confidence: confidence,
        boundingBox: boundingBox,
        additionalInfo: {'fullResponse': firstResponse},
      );
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('解析API响应时发生错误: ${e.toString()}');
    }
  }
}
