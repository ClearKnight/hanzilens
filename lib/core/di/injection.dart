import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:hanzilens/data/datasources/remote/image_recognition_service.dart';
import 'package:hanzilens/data/datasources/remote/chinese_language_service.dart';
import 'package:hanzilens/data/datasources/remote/google_vision_service.dart';
import 'package:hanzilens/data/repositories/recognition_repository_impl.dart';
import 'package:hanzilens/domain/repositories/recognition_repository.dart';
import 'package:hanzilens/domain/usecases/recognize_image.dart';
import 'package:hanzilens/presentation/blocs/camera/camera_bloc.dart';
import 'package:hanzilens/presentation/blocs/recognition/recognition_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final getIt = GetIt.instance;

// API密钥配置，实际应从安全存储或环境变量获取
String googleVisionApiKey = 'YOUR_GOOGLE_VISION_API_KEY'; // 待替换为真实API密钥
String youdaoAppKey = 'YOUR_YOUDAO_APP_KEY'; // 待替换为真实APP密钥
String youdaoAppSecret = 'YOUR_YOUDAO_APP_SECRET'; // 待替换为真实APP密钥

/// 配置依赖注入
Future<void> configureDependencies() async {
  // 外部依赖
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // 注册HTTP客户端
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // 配置数据库
  await _configureDatabase();

  // 注册数据源
  _registerDataSources();

  // 注册存储库
  _registerRepositories();

  // 注册用例
  _registerUseCases();

  // 注册BLoCs
  _registerBlocs();
}

/// 设置API密钥
void setApiKeys({
  required String googleVisionKey,
  required String youdaoKey,
  required String youdaoSecret,
}) {
  googleVisionApiKey = googleVisionKey;
  youdaoAppKey = youdaoKey;
  youdaoAppSecret = youdaoSecret;

  // 重新注册依赖于API密钥的服务
  _registerRemoteServices();
}

Future<void> _configureDatabase() async {
  // 获取数据库路径
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'hanzilens.db');

  // 打开数据库
  final database = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // 创建识别历史表
      await db.execute(
        '''
        CREATE TABLE IF NOT EXISTS recognitions (
          id TEXT PRIMARY KEY,
          object_name TEXT NOT NULL,
          object_name_pinyin TEXT NOT NULL,
          object_name_english TEXT NOT NULL,
          confidence REAL,
          bounding_box TEXT,
          image_path TEXT,
          timestamp INTEGER
        )
        ''',
      );
    },
  );

  getIt.registerSingleton<Database>(database);
}

void _registerDataSources() {
  // 注册远程服务
  _registerRemoteServices();
}

void _registerRemoteServices() {
  // 图像识别服务
  getIt.registerLazySingleton<ImageRecognitionService>(
    () => GoogleVisionService(
      client: getIt<http.Client>(),
      apiKey: googleVisionApiKey,
    ),
  );

  // 汉字资源库服务
  getIt.registerLazySingleton<ChineseLanguageService>(
    () => YoudaoChineseService(
      client: getIt<http.Client>(),
      appKey: youdaoAppKey,
      appSecret: youdaoAppSecret,
    ),
  );
}

void _registerRepositories() {
  // 识别存储库
  getIt.registerLazySingleton<RecognitionRepository>(
    () => RecognitionRepositoryImpl(
      imageRecognitionService: getIt<ImageRecognitionService>(),
      chineseLanguageService: getIt<ChineseLanguageService>(),
      database: getIt<Database>(),
    ),
  );
}

void _registerUseCases() {
  // 识别图像
  getIt.registerLazySingleton(
      () => RecognizeImage(getIt<RecognitionRepository>()));
}

void _registerBlocs() {
  // 相机BLoC
  getIt.registerFactory(() => CameraBloc());

  // 识别BLoC
  getIt.registerFactory(
    () => RecognitionBloc(
      recognizeImage: getIt<RecognizeImage>(),
    ),
  );
}
