# HanziLens 项目 Git 工作流程指南

本文档定义了 HanziLens 项目的 Git 工作流程和最佳实践，以确保开发过程的一致性和代码质量。

## 分支策略

我们采用基于 Git Flow 的分支模型，主要包含以下分支类型：

### 核心分支

- **master**: 生产环境代码，保持稳定，随时可发布
- **develop**: 开发环境主分支，包含最新开发完成的功能

### 支持分支

- **feature/xxx**: 新功能开发分支，从 develop 分支创建
- **bugfix/xxx**: 问题修复分支，从 develop 分支创建
- **release/x.x.x**: 版本发布准备分支，从 develop 分支创建
- **hotfix/xxx**: 生产环境紧急修复分支，从 master 分支创建

## 工作流程步骤

### 1. 功能开发流程

```
# 更新本地 develop 分支
git checkout develop
git pull origin develop

# 创建功能分支
git checkout -b feature/功能名称

# 开发过程中定期提交
git add .
git commit -m "feat: 功能描述"

# 如果 develop 有更新，定期合并到功能分支
git checkout develop
git pull origin develop
git checkout feature/功能名称
git merge develop

# 功能完成后，推送到远程
git push -u origin feature/功能名称
```

然后在 GitHub 上创建 Pull Request，将功能分支合并到 develop 分支。

### 2. Bug 修复流程

```
# 创建修复分支
git checkout develop
git pull origin develop
git checkout -b bugfix/问题描述

# 修复问题并提交
git add .
git commit -m "fix: 问题描述"

# 推送到远程
git push -u origin bugfix/问题描述
```

然后在 GitHub 上创建 Pull Request，将修复分支合并到 develop 分支。

### 3. 版本发布流程

```
# 创建发布分支
git checkout develop
git pull origin develop
git checkout -b release/x.x.x

# 最终调整和修复
git commit -m "chore: 准备 x.x.x 版本发布"

# 发布完成后，合并到 master 和 develop
git checkout master
git merge release/x.x.x
git tag -a vx.x.x -m "版本 x.x.x"
git push origin master --tags

git checkout develop
git merge release/x.x.x
git push origin develop

# 删除发布分支
git branch -d release/x.x.x
git push origin --delete release/x.x.x
```

## 提交信息规范

我们采用 [Conventional Commits](https://www.conventionalcommits.org/) 规范，格式如下：

```
<类型>[可选作用域]: <描述>

[可选正文]

[可选脚注]
```

### 类型

- **feat**: 新功能
- **fix**: 修复问题
- **docs**: 文档更改
- **style**: 代码风格调整（不影响代码功能）
- **refactor**: 代码重构（既不是新功能也不是修复问题）
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

## 工作流程最佳实践

1. **定期拉取更新**：每天开始工作前拉取最新代码
   ```
   git pull origin develop
   ```

2. **小步提交**：频繁提交小的代码变更，而非一次提交大量代码
   ```
   git commit -m "feat: 添加按钮组件"
   git commit -m "style: 优化按钮样式"
   ```

3. **描述性分支名称**：使用描述性名称以便于理解
   ```
   feature/photo-label-interaction
   bugfix/camera-crash-ios
   ```

4. **保持分支最新**：定期将 develop 分支合并到功能分支，避免大型合并冲突
   ```
   git checkout develop
   git pull
   git checkout feature/xxx
   git merge develop
   ```

5. **使用 Pull Request**：所有代码合并通过 Pull Request 进行，便于代码审查

6. **使用问题跟踪**：在 GitHub Issues 中跟踪功能和问题，在提交中引用问题编号

7. **保持干净的历史**：在推送前整理本地提交
   ```
   git rebase -i develop
   ```

## 工具建议

- **GitHub Desktop**：如果您不熟悉命令行，可以使用 GitHub Desktop
- **VSCode Git 插件**：VSCode 的 Git 集成功能强大
- **Git 别名**：设置常用命令的别名，提高效率

## Git 配置检查

定期检查您的 Git 配置，确保用户名和邮箱设置正确：

```
git config --global user.name
git config --global user.email
```

## 问题解决

如遇到 Git 相关问题，请参考：
- GitHub 官方文档: https://docs.github.com/cn
- Git 官方文档: https://git-scm.com/book/zh/v2 