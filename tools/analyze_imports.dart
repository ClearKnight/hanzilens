import 'dart:io';

/// 项目导入分析工具
///
/// 分析整个项目中的导入关系，帮助找出未被使用的文件
void main() async {
  print('开始分析项目导入关系...\n');

  // 分析lib目录下的所有Dart文件
  final directory = Directory('lib');
  final allFiles = await _getAllDartFiles(directory);

  print('找到 ${allFiles.length} 个Dart文件\n');

  // 构建文件导入关系图
  final importGraph = await _buildImportGraph(allFiles);

  print('\n导入关系图构建完成！\n');

  // 分析项目入口点
  final entryPoints = [
    'lib/main.dart',
  ];

  print('项目入口点: ${entryPoints.join(', ')}\n');

  // 查找所有从入口点可访问的文件
  final reachableFiles = _findReachableFiles(importGraph, entryPoints);

  print('从入口点可访问的文件数: ${reachableFiles.length}\n');

  // 找出未使用的文件
  final unusedFiles =
      allFiles.where((file) => !reachableFiles.contains(file)).toList();

  // 打印分析结果
  if (unusedFiles.isEmpty) {
    print('恭喜！未发现未使用的文件。所有文件都被项目正确引用。');
  } else {
    print('发现 ${unusedFiles.length} 个未被使用的文件:\n');

    for (final file in unusedFiles) {
      print('  - $file');
    }

    print('\n这些文件可能不会被编译到最终应用中。');
    print('建议检查这些文件，确认它们是否应该被其他文件导入，或者可以安全删除。');
  }

  // 打印被多次导入的文件
  final frequentlyImported = _findFrequentlyImportedFiles(importGraph);
  print('\n被导入次数最多的文件 (Top 10):');
  for (final entry in frequentlyImported.take(10)) {
    print('  - ${entry.key}: ${entry.value} 次导入');
  }
}

/// 获取目录及其子目录中的所有.dart文件
Future<List<String>> _getAllDartFiles(Directory directory) async {
  final files = <String>[];

  await for (final entity in directory.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      files.add(entity.path.replaceAll('\\', '/'));
    }
  }

  return files;
}

/// 构建导入关系图
Future<Map<String, Set<String>>> _buildImportGraph(
    List<String> allFiles) async {
  final importGraph = <String, Set<String>>{};

  for (final file in allFiles) {
    importGraph[file] = <String>{};

    final fileContent = await File(file).readAsString();
    final lines = fileContent.split('\n');

    print('分析文件: $file');

    for (final line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.startsWith('import ')) {
        String importPath = trimmedLine.substring(7).trim();

        // 移除引号、分号等字符
        importPath = importPath
            .replaceAll("'", "")
            .replaceAll(";", "")
            .replaceAll('"', '');

        // 仅处理本地项目导入
        if (importPath.startsWith('package:hanzilens/')) {
          final localPath =
              'lib/${importPath.substring('package:hanzilens/'.length)}';
          importGraph[file]!.add(localPath);
          print('  导入: $localPath');
        }
      }
    }
  }

  return importGraph;
}

/// 发现从入口点可到达的所有文件
Set<String> _findReachableFiles(
    Map<String, Set<String>> importGraph, List<String> entryPoints) {
  final reachable = <String>{};
  final queue = [...entryPoints];

  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);

    if (reachable.contains(current)) continue;

    reachable.add(current);

    // 向队列中添加当前文件导入的所有文件
    final imports = importGraph[current] ?? <String>{};
    for (final import in imports) {
      if (!reachable.contains(import)) {
        queue.add(import);
      }
    }
  }

  return reachable;
}

/// 查找被导入次数最多的文件
List<MapEntry<String, int>> _findFrequentlyImportedFiles(
    Map<String, Set<String>> importGraph) {
  final importCounts = <String, int>{};

  for (final imports in importGraph.values) {
    for (final import in imports) {
      importCounts[import] = (importCounts[import] ?? 0) + 1;
    }
  }

  final sortedEntries = importCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sortedEntries;
}
