import 'package:hanzilens/core/di/injection.dart';

/// API密钥配置
///
/// 用于统一管理和加载API密钥。
class ApiKeys {
  /// Google Cloud Vision API密钥
  static String get googleVisionApiKey => _googleVisionApiKey;
  static String _googleVisionApiKey = '';

  /// 有道词典API应用密钥
  static String get youdaoAppKey => _youdaoAppKey;
  static String _youdaoAppKey = '';

  /// 有道词典API应用密钥
  static String get youdaoAppSecret => _youdaoAppSecret;
  static String _youdaoAppSecret = '';

  /// 检查API密钥是否已配置
  static bool get isConfigured =>
      _googleVisionApiKey.isNotEmpty &&
      _youdaoAppKey.isNotEmpty &&
      _youdaoAppSecret.isNotEmpty;

  /// 配置API密钥
  static void configure({
    required String googleVisionKey,
    required String youdaoKey,
    required String youdaoSecret,
  }) {
    _googleVisionApiKey = googleVisionKey;
    _youdaoAppKey = youdaoKey;
    _youdaoAppSecret = youdaoSecret;

    // 更新依赖注入中的API密钥
    setApiKeys(
      googleVisionKey: googleVisionKey,
      youdaoKey: youdaoKey,
      youdaoSecret: youdaoSecret,
    );
  }

  /// 重置API密钥
  static void reset() {
    _googleVisionApiKey = '';
    _youdaoAppKey = '';
    _youdaoAppSecret = '';
  }
}
