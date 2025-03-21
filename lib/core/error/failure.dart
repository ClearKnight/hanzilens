import 'package:equatable/equatable.dart';

/// 错误基类
abstract class Failure extends Equatable {
  final String message;

  const Failure([this.message = '']);

  @override
  List<Object> get props => [message];
}

/// 服务器错误
class ServerFailure extends Failure {
  const ServerFailure([String message = '服务器错误']) : super(message);
}

/// 缓存错误
class CacheFailure extends Failure {
  const CacheFailure([String message = '缓存错误']) : super(message);
}

/// 网络错误
class NetworkFailure extends Failure {
  const NetworkFailure([String message = '网络连接错误']) : super(message);
}

/// 模型处理错误
class ModelFailure extends Failure {
  const ModelFailure([String message = '模型处理错误']) : super(message);
}

/// 验证错误
class ValidationFailure extends Failure {
  const ValidationFailure([String message = '数据验证错误']) : super(message);
}

/// 权限错误
class PermissionFailure extends Failure {
  const PermissionFailure([String message = '权限被拒绝']) : super(message);
}
