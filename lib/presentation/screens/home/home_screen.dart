import 'package:flutter/material.dart';
import 'package:hanzilens/app/routes.dart';

/// 首页屏幕
///
/// 应用的主入口页面，显示主要功能入口。
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('汉字学习'),
        // 移除设置按钮，因为设置页面尚未实现
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.settings),
        //     onPressed: () {
        //       Navigator.of(context).pushNamed(AppRoutes.settings);
        //     },
        //   ),
        // ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 欢迎消息
              const Text(
                '欢迎使用HanziLens',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // MVP说明
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MVP版本',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '当前为最小可行产品版本，仅支持拍照识别功能。其他功能将在后续版本中添加。',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              // 功能卡片
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    // 拍照识别 - 已实现
                    _buildFeatureCard(
                      context,
                      icon: Icons.camera_alt,
                      title: '拍照识别',
                      description: '拍照识别物体并学习汉字',
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.camera),
                      isEnabled: true,
                    ),
                    // 学习记录 - 未实现
                    _buildFeatureCard(
                      context,
                      icon: Icons.history,
                      title: '学习记录',
                      description: '查看已学习的汉字',
                      onTap: () {
                        _showFeatureNotAvailable(context);
                      },
                      isEnabled: false,
                    ),
                    // 汉字搜索 - 未实现
                    _buildFeatureCard(
                      context,
                      icon: Icons.search,
                      title: '汉字搜索',
                      description: '搜索汉字和释义',
                      onTap: () {
                        _showFeatureNotAvailable(context);
                      },
                      isEnabled: false,
                    ),
                    // 学习进度 - 未实现
                    _buildFeatureCard(
                      context,
                      icon: Icons.school,
                      title: '学习进度',
                      description: '查看学习统计信息',
                      onTap: () {
                        _showFeatureNotAvailable(context);
                      },
                      isEnabled: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.camera),
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  /// 显示功能不可用提示
  void _showFeatureNotAvailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('此功能在MVP版本中尚未实现'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 构建功能卡片
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: isEnabled
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? Colors.black : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isEnabled ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ),
              if (!isEnabled)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '即将推出',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
