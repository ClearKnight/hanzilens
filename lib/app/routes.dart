import 'package:flutter/material.dart';
import 'package:hanzilens/presentation/screens/home/home_screen.dart';
import 'package:hanzilens/presentation/screens/camera/camera_screen.dart';
import 'package:hanzilens/presentation/screens/result/result_screen.dart';

/// 应用路由
class AppRoutes {
  // 路由名称定义
  static const String home = '/';
  static const String camera = '/camera';
  static const String result = '/result';
  static const String characterDetail = '/character-detail';
  static const String settings = '/settings';

  /// 路由生成器
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final name = settings.name;
    final args = settings.arguments;

    if (name == home) {
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    } else if (name == camera) {
      return MaterialPageRoute(builder: (_) => const CameraScreen());
    } else if (name == result) {
      if (args is String) {
        return MaterialPageRoute(builder: (_) => ResultScreen(imagePath: args));
      }
      return _errorRoute('缺少图像路径参数');
    }

    // 未实现的页面
    else if (name == characterDetail || name == settings) {
      return MaterialPageRoute(
        builder: (_) => _buildNotImplementedScreen(name, args),
      );
    } else {
      return _errorRoute('路由不存在');
    }
  }

  /// 构建错误页面
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('错误'),
          ),
          body: Center(
            child: Text(message),
          ),
        );
      },
    );
  }

  /// 构建未实现功能页面
  static Widget _buildNotImplementedScreen(String? routeName, dynamic args) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('功能开发中'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            const Text(
              '该功能正在开发中',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '路由: ${routeName ?? "未知"}',
              style: const TextStyle(color: Colors.grey),
            ),
            if (args != null) ...[
              const SizedBox(height: 8),
              Text(
                '参数: $args',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 24),
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('返回'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 应用路由工具类
class AppRouter {
  // 全局导航键
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// 获取当前导航器
  static NavigatorState get navigator => navigatorKey.currentState!;

  /// 导航到指定页面
  static Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigator.pushNamed(routeName, arguments: arguments);
  }

  /// 替换当前页面
  static Future<dynamic> navigateAndReplace(String routeName,
      {dynamic arguments}) {
    return navigator.pushReplacementNamed(routeName, arguments: arguments);
  }

  /// 返回上一页
  static void goBack<T>([T? result]) {
    navigator.pop<T>(result);
  }

  /// 回到指定页面
  static void popUntil(String routeName) {
    navigator.popUntil(ModalRoute.withName(routeName));
  }
}
