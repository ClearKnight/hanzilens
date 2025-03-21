import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hanzilens/core/error/failure.dart';

/// 用例基类
///
/// 定义了用例的通用接口。每个用例都应该实现这个接口。
/// [Type] 是用例返回的数据类型。
/// [Params] 是用例需要的参数类型。
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// 无参数类
///
/// 当用例不需要任何参数时使用。
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
