import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hanzilens/core/error/failure.dart';
import 'package:hanzilens/core/usecases/usecase.dart';
import 'package:hanzilens/domain/entities/character.dart';
import 'package:hanzilens/domain/repositories/character_repository.dart';

/// 获取所有汉字用例
class GetCharacters implements UseCase<List<Character>, NoParams> {
  final CharacterRepository repository;

  GetCharacters(this.repository);

  @override
  Future<Either<Failure, List<Character>>> call(NoParams params) async {
    return await repository.getCharacters();
  }
}

/// 根据汉字获取详情用例
class GetCharacterByHanzi implements UseCase<Character, GetCharacterParams> {
  final CharacterRepository repository;

  GetCharacterByHanzi(this.repository);

  @override
  Future<Either<Failure, Character>> call(GetCharacterParams params) async {
    return await repository.getCharacterByHanzi(params.hanzi);
  }
}

/// 获取常用汉字用例
class GetCommonCharacters
    implements UseCase<List<Character>, GetCommonCharactersParams> {
  final CharacterRepository repository;

  GetCommonCharacters(this.repository);

  @override
  Future<Either<Failure, List<Character>>> call(
      GetCommonCharactersParams params) async {
    return await repository.getCommonCharacters(params.limit);
  }
}

/// 搜索汉字用例
class SearchCharacters
    implements UseCase<List<Character>, SearchCharactersParams> {
  final CharacterRepository repository;

  SearchCharacters(this.repository);

  @override
  Future<Either<Failure, List<Character>>> call(
      SearchCharactersParams params) async {
    return await repository.searchCharacters(params.query);
  }
}

/// 获取汉字详情参数
class GetCharacterParams extends Equatable {
  final String hanzi;

  const GetCharacterParams({required this.hanzi});

  @override
  List<Object> get props => [hanzi];
}

/// 获取常用汉字参数
class GetCommonCharactersParams extends Equatable {
  final int limit;

  const GetCommonCharactersParams({required this.limit});

  @override
  List<Object> get props => [limit];
}

/// 搜索汉字参数
class SearchCharactersParams extends Equatable {
  final String query;

  const SearchCharactersParams({required this.query});

  @override
  List<Object> get props => [query];
}
