import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hanzilens/core/error/exceptions.dart';

/// 汉字资源库服务接口
///
/// 定义了所有与汉字信息检索相关的远程API操作。
abstract class ChineseLanguageService {
  /// 根据英文物体名称获取对应的汉字信息
  ///
  /// 参数：
  /// - [englishWord]: 英文单词，如"cat"
  ///
  /// 返回：
  /// 包含汉字、拼音、释义等信息的ChineseWordInfo对象
  Future<ChineseWordInfo> getChineseWordInfo(String englishWord);

  /// 批量获取汉字信息
  ///
  /// 参数：
  /// - [englishWords]: 英文单词列表
  ///
  /// 返回：
  /// 汉字信息列表
  Future<List<ChineseWordInfo>> getMultipleChineseWordInfo(
      List<String> englishWords);
}

/// 汉字信息类
///
/// 表示一个汉字或词语的完整信息。
class ChineseWordInfo {
  /// 汉字或词语
  final String chinese;

  /// 拼音，带声调
  final String pinyin;

  /// 英文释义
  final String englishTranslation;

  /// 简要描述或词义说明
  final String? description;

  /// 使用例句
  final List<String>? examples;

  /// 笔画数量（对单字有效）
  final int? strokes;

  /// 部首（对单字有效）
  final String? radical;

  const ChineseWordInfo({
    required this.chinese,
    required this.pinyin,
    required this.englishTranslation,
    this.description,
    this.examples,
    this.strokes,
    this.radical,
  });
}

/// 有道词典API服务实现
///
/// 使用有道词典API获取汉字信息。
class YoudaoChineseService implements ChineseLanguageService {
  final http.Client client;
  final String appKey;
  final String appSecret;
  final String apiEndpoint = 'https://openapi.youdao.com/api';

  // 内存缓存，避免重复API调用
  final Map<String, ChineseWordInfo> _cache = {};

  YoudaoChineseService({
    required this.client,
    required this.appKey,
    required this.appSecret,
  });

  @override
  Future<ChineseWordInfo> getChineseWordInfo(String englishWord) async {
    // 1. 检查缓存
    if (_cache.containsKey(englishWord)) {
      return _cache[englishWord]!;
    }

    try {
      // 2. 准备参数
      final salt = DateTime.now().millisecondsSinceEpoch.toString();
      final curtime =
          (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();
      final sign = _generateSign(englishWord, salt, curtime);

      // 3. 构建请求参数
      final queryParams = {
        'q': englishWord,
        'from': 'en',
        'to': 'zh-CHS',
        'appKey': appKey,
        'salt': salt,
        'sign': sign,
        'signType': 'v3',
        'curtime': curtime,
      };

      // 4. 发送HTTP请求
      final response = await client.post(
        Uri.parse(apiEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: queryParams,
      );

      // 5. 处理响应
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['errorCode'] == '0') {
          final result = _parseYoudaoResponse(jsonResponse, englishWord);
          // 6. 存入缓存
          _cache[englishWord] = result;
          return result;
        } else {
          throw ServerException(
            '有道API错误: ${jsonResponse['errorCode']} - ${_getErrorMessage(jsonResponse['errorCode'])}',
          );
        }
      } else {
        throw ServerException(
          'API错误: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('获取汉字信息时发生错误: ${e.toString()}');
    }
  }

  @override
  Future<List<ChineseWordInfo>> getMultipleChineseWordInfo(
      List<String> englishWords) async {
    final results = <ChineseWordInfo>[];
    for (final word in englishWords) {
      results.add(await getChineseWordInfo(word));
    }
    return results;
  }

  /// 生成有道API签名
  String _generateSign(String query, String salt, String curtime) {
    final String signStr =
        appKey + _truncate(query) + salt + curtime + appSecret;
    return _sha256(signStr);
  }

  /// 裁剪查询字符串，用于生成签名
  String _truncate(String q) {
    if (q.length <= 20) return q;
    return q.substring(0, 10) +
        q.length.toString() +
        q.substring(q.length - 10);
  }

  /// 计算SHA-256哈希值，实际项目中需要实现
  String _sha256(String input) {
    // 在实际项目中，应使用密码学库实现SHA-256哈希
    // 这里仅作为占位符
    return input.hashCode.toRadixString(16);
  }

  /// 解析有道API响应
  ChineseWordInfo _parseYoudaoResponse(
      Map<String, dynamic> response, String englishWord) {
    try {
      // 获取基本翻译
      final translations = response['translation'] as List;
      final chinese =
          translations.isNotEmpty ? translations[0] as String : '未知';

      // 获取更详细的信息（如果有）
      String pinyin = '';
      String detailedTranslation = englishWord;
      List<String> examples = [];

      // 提取拼音
      if (response.containsKey('basic') && response['basic'] != null) {
        final basic = response['basic'] as Map<String, dynamic>;
        if (basic.containsKey('phonetic')) {
          pinyin = basic['phonetic'] as String;
        }

        // 提取详细释义
        if (basic.containsKey('explains') && basic['explains'] is List) {
          final explains = basic['explains'] as List;
          if (explains.isNotEmpty) {
            detailedTranslation = explains.join('; ');
          }
        }
      }

      // 提取例句
      if (response.containsKey('web') && response['web'] is List) {
        final webResults = response['web'] as List;
        for (final web in webResults) {
          if (web is Map<String, dynamic> &&
              web.containsKey('value') &&
              web['value'] is List) {
            final values = web['value'] as List;
            if (values.isNotEmpty) {
              examples.add(values.join(', '));
            }
          }
        }
      }

      return ChineseWordInfo(
        chinese: chinese,
        pinyin: pinyin.isNotEmpty ? pinyin : _generateDefaultPinyin(chinese),
        englishTranslation: detailedTranslation,
        examples: examples.isNotEmpty ? examples : null,
      );
    } catch (e) {
      throw ServerException('解析有道API响应时发生错误: ${e.toString()}');
    }
  }

  /// 为缺失拼音的汉字生成默认拼音（实际项目应使用更完善的方法）
  String _generateDefaultPinyin(String chinese) {
    return ''; // 在实际项目中实现更准确的拼音生成
  }

  /// 获取有道API错误码对应的错误信息
  String _getErrorMessage(String errorCode) {
    final errorMessages = {
      '101': '缺少必填参数',
      '102': '不支持的语言类型',
      '103': '翻译文本过长',
      '104': '不支持的API类型',
      '105': '不支持的签名类型',
      '106': '无效的应用ID',
      '107': '无效的签名',
      '108': '无效的应用密钥',
      '109': '无效的批量查询',
      '110': '无效的用户IP',
      '111': '服务已关闭',
      '112': '无效的用户ID',
      '113': '无效的用户类型',
      '114': '无效的访问IP',
      '116': '账户余额不足',
      '201': '解密失败',
      '202': '签名校验失败',
      '203': '访问IP地址不在可访问IP列表',
      '205': '请求频率过高',
      '206': '无词典结果',
      '207': '超过访问上限',
      '401': '账户已经欠费',
      '411': '访问频率受限',
    };

    return errorMessages[errorCode] ?? '未知错误';
  }
}
