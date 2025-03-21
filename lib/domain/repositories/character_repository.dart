import 'package:dartz/dartz.dart';
import 'package:hanzilens/core/error/failure.dart';
import 'package:hanzilens/domain/entities/character.dart';

/// 汉字存储库接口
///
/// 定义了所有与汉字相关的数据操作。
abstract class CharacterRepository {
  /// 获取汉字列表
  Future<Either<Failure, List<Character>>> getCharacters();

  /// 根据汉字获取详情
  Future<Either<Failure, Character>> getCharacterByHanzi(String hanzi);

  /// 保存汉字
  Future<Either<Failure, void>> saveCharacter(Character character);

  /// 获取常用汉字
  Future<Either<Failure, List<Character>>> getCommonCharacters(int limit);

  /// 搜索汉字
  Future<Either<Failure, List<Character>>> searchCharacters(String query);
}
