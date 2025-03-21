# HanziLens 贡献指南

感谢您对HanziLens项目的兴趣！我们欢迎所有形式的贡献，无论是修复bug、改进文档还是添加新功能。本文档将指导您如何为项目做出贡献。

## 开发环境设置

1. 确保您已安装以下工具：
   - Flutter SDK (3.10.0+)
   - Dart SDK (3.0.0+)
   - Android Studio或VS Code
   - Git

2. 克隆仓库并设置开发环境：
   ```bash
   git clone https://github.com/ClearKnight/hanzilens.git
   cd hanzilens
   flutter pub get
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

## 工作流程

我们采用GitHub Flow工作流程：

1. **创建分支**：从`develop`分支创建新分支
   ```bash
   git checkout develop
   git pull
   git checkout -b feature/your-feature-name
   ```

2. **提交更改**：进行更改并提交
   ```bash
   git add .
   git commit -m "feat: 描述您的更改"
   ```

3. **推送分支**：推送到GitHub
   ```bash
   git push -u origin feature/your-feature-name
   ```

4. **创建Pull Request**：在GitHub上创建Pull Request，目标分支为`develop`

## 提交消息规范

我们使用[Conventional Commits](https://www.conventionalcommits.org/)规范，格式如下：

```
<类型>[可选作用域]: <描述>

[可选正文]

[可选脚注]
```

### 类型

- **feat**: 新功能
- **fix**: 修复问题
- **docs**: 文档更改
- **style**: 代码风格调整
- **refactor**: 代码重构
- **perf**: 性能优化
- **test**: 测试相关
- **chore**: 构建过程或辅助工具的变动

### 示例

```
feat(camera): 添加相机滤镜功能

- 新增3种实时滤镜效果
- 优化相机界面布局

Closes #123
```

## 代码规范

- 遵循[Effective Dart](https://dart.dev/guides/language/effective-dart)指南
- 使用[Flutter代码格式化工具](https://flutter.dev/docs/development/tools/formatting)
- 添加适当的文档注释
- 为新功能添加测试

## 测试

提交前请确保所有测试通过：

```bash
flutter test
```

## 文档

更改API或添加新功能时，请更新相应的文档：

- 为公共API添加文档注释
- 更新README.md（如有必要）
- 添加或更新wiki页面（如有必要）

## Pull Request检查清单

提交Pull Request前，请确保：

- [ ] 代码已经过测试
- [ ] 代码遵循项目的代码规范
- [ ] 提交消息遵循约定式提交规范
- [ ] 已更新相关文档
- [ ] 已添加合适的测试用例

## 行为准则

请尊重所有项目参与者。任何形式的骚扰或不尊重行为都不会被容忍。

## 许可证

通过贡献代码，您同意您的贡献将在项目使用的[MIT许可证](LICENSE)下发布。 