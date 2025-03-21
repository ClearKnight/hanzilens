import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzilens/app/app.dart';
import 'package:hanzilens/core/config/api_keys.dart';
import 'package:hanzilens/core/di/injection.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 设置应用方向为竖屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 初始化本地数据库
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);

  // 注册Hive适配器
  // Hive.registerAdapter(CharacterModelAdapter());

  // 初始化依赖注入
  await configureDependencies();

  // 配置模拟API密钥（仅用于MVP测试）
  _configureMockApiKeys();

  // 自定义BLoC观察者，用于日志和错误处理
  Bloc.observer = AppBlocObserver();

  // 运行应用
  runApp(const HanziLensApp());
}

/// 配置模拟API密钥
/// 注意：这只是用于MVP测试，实际应用中应使用真实API密钥
void _configureMockApiKeys() {
  debugPrint('⚠️ 使用模拟API密钥，仅用于MVP测试');

  // 在实际应用中，这些值应从安全存储或环境变量获取
  ApiKeys.configure(
    googleVisionKey: 'mock_google_vision_key_for_testing',
    youdaoKey: 'mock_youdao_app_key_for_testing',
    youdaoSecret: 'mock_youdao_app_secret_for_testing',
  );
}

// BLoC观察者，用于监控应用中的BLoC事件和状态变化
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    debugPrint('onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    debugPrint('onClose -- ${bloc.runtimeType}');
  }
}
