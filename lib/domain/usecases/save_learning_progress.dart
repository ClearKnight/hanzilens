import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hanzilens/core/error/failure.dart';
import 'package:hanzilens/core/usecases/usecase.dart';
import 'package:hanzilens/domain/entities/user_profile.dart';
import 'package:hanzilens/domain/repositories/user_repository.dart';

/// 保存学习进度用例
class SaveLearningProgress
    implements UseCase<void, SaveLearningProgressParams> {
  final UserRepository repository;

  SaveLearningProgress(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveLearningProgressParams params) async {
    if (params.isLearned) {
      return await repository.addLearnedCharacter(params.characterId);
    } else {
      return await repository.removeLearnedCharacter(params.characterId);
    }
  }
}

/// 获取用户配置用例
class GetUserProfile implements UseCase<UserProfile, NoParams> {
  final UserRepository repository;

  GetUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) async {
    return await repository.getUserProfile();
  }
}

/// 更新用户配置用例
class UpdateUserProfile implements UseCase<void, UpdateUserProfileParams> {
  final UserRepository repository;

  UpdateUserProfile(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserProfileParams params) async {
    return await repository.saveUserProfile(params.userProfile);
  }
}

/// 更新学习级别用例
class UpdateLearningLevel implements UseCase<void, UpdateLearningLevelParams> {
  final UserRepository repository;

  UpdateLearningLevel(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateLearningLevelParams params) async {
    return await repository.updateLearningLevel(params.level);
  }
}

/// 获取已学习汉字列表用例
class GetLearnedCharacters implements UseCase<List<String>, NoParams> {
  final UserRepository repository;

  GetLearnedCharacters(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getLearnedCharacters();
  }
}

/// 保存学习进度参数
class SaveLearningProgressParams extends Equatable {
  final String characterId;
  final bool isLearned;

  const SaveLearningProgressParams({
    required this.characterId,
    required this.isLearned,
  });

  @override
  List<Object> get props => [characterId, isLearned];
}

/// 更新用户配置参数
class UpdateUserProfileParams extends Equatable {
  final UserProfile userProfile;

  const UpdateUserProfileParams({required this.userProfile});

  @override
  List<Object> get props => [userProfile];
}

/// 更新学习级别参数
class UpdateLearningLevelParams extends Equatable {
  final String level;

  const UpdateLearningLevelParams({required this.level});

  @override
  List<Object> get props => [level];
}
