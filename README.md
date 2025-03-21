# HanziLens - Flutter汉字学习应用

HanziLens是一款创新的移动应用，帮助用户通过拍照识别物体学习汉字。拍摄照片后，应用会自动识别照片中的物体，并在照片上标注相应的汉字、拼音和英文释义。

## 项目架构

HanziLens采用**Clean Architecture**结合**BLoC模式**的分层架构，确保代码高内聚、低耦合，便于测试和维护。

### 架构层次

1. **表示层** (Presentation Layer)
   - 包含UI组件、Widgets、Screens
   - BLoC组件处理UI相关的业务逻辑
   - 不包含任何业务规则

2. **领域层** (Domain Layer)
   - 包含业务实体、用例和存储库接口
   - 完全独立于框架和技术选择

3. **数据层** (Data Layer)
   - 实现领域层定义的存储库接口
   - 包含数据源(本地、远程)和数据模型
   - 处理数据转换和API通信

## 项目设置

### 环境要求

- Flutter 3.10.0 或更高版本
- Dart 3.0.0 或更高版本
- Android Studio / VS Code
- iOS 13+ / Android 6.0+

### 安装步骤

1. 克隆仓库
```bash
git clone https://github.com/ClearKnight/hanzilens.git
cd hanzilens
```

2. 安装依赖
```bash
flutter pub get
```

3. 生成必要的代码
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

4. 运行应用
```bash
flutter run
```

## 项目结构

```
lib/
├── main.dart                  # 应用入口点
├── app/                       # 应用级配置
│   ├── routes.dart            # 路由定义
│   ├── theme.dart             # 主题配置
│   └── app.dart               # MaterialApp配置
│
├── presentation/              # 表示层
│   ├── screens/               # 屏幕/页面
│   ├── widgets/               # 共享UI组件
│   └── blocs/                 # 业务逻辑组件(BLoCs)
│
├── domain/                    # 领域层
│   ├── entities/              # 业务实体
│   ├── repositories/          # 存储库接口
│   └── usecases/              # 业务用例
│
├── data/                      # 数据层
│   ├── models/                # 数据模型
│   ├── repositories/          # 存储库实现
│   └── datasources/           # 数据源
│
└── core/                      # 核心功能
    ├── utils/                 # 通用工具类
    ├── error/                 # 错误处理
    ├── network/               # 网络处理
    ├── di/                    # 依赖注入
    └── constants/             # 常量定义
```

## 主要特性

- **拍照识别**: 拍摄照片自动识别物体
- **多语言标注**: 在照片上显示汉字、拼音和英文
- **详细解释**: 提供汉字的详细解释、例句和笔画顺序
- **学习记录**: 跟踪学习进度，保存已学习的汉字
- **离线功能**: 基本功能可在离线状态下使用

## 技术栈

- **Flutter**: UI框架
- **BLoC**: 状态管理
- **get_it**: 依赖注入
- **dio**: 网络请求
- **hive/sqflite**: 本地存储
- **camera**: 相机功能
- **tflite_flutter**: 本地ML模型(离线识别)
- **auto_route**: 路由管理

## 贡献指南

参考[CONTRIBUTING.md](CONTRIBUTING.md)文件了解如何为项目做出贡献。

## 许可证

本项目采用MIT许可证 - 查看[LICENSE](LICENSE)文件了解详情。 