import 'package:dartz/dartz.dart';
import 'package:hanzilens/core/error/failure.dart';
import 'package:hanzilens/domain/entities/user_profile.dart';

/// 用户存储库接口
///
/// 定义了所有与用户相关的数据操作。
abstract class UserRepository {
  /// 获取用户配置
  Future<Either<Failure, UserProfile>> getUserProfile();

  /// 保存用户配置
  Future<Either<Failure, void>> saveUserProfile(UserProfile userProfile);

  /// 添加已学习的汉字
  Future<Either<Failure, void>> addLearnedCharacter(String characterId);

  /// 移除已学习的汉字
  Future<Either<Failure, void>> removeLearnedCharacter(String characterId);

  /// 获取已学习的汉字列表
  Future<Either<Failure, List<String>>> getLearnedCharacters();

  /// 更新学习级别
  Future<Either<Failure, void>> updateLearningLevel(String level);
}
