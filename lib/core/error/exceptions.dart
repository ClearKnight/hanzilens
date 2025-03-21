/// 服务器异常
class ServerException implements Exception {
  final String message;
  ServerException([this.message = '服务器错误']);
}

/// 缓存异常
class CacheException implements Exception {
  final String message;
  CacheException([this.message = '缓存错误']);
}

/// 网络异常
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = '网络错误']);
}

/// 权限异常
class PermissionException implements Exception {
  final String message;
  PermissionException([this.message = '权限被拒绝']);
}

/// 认证异常
class AuthException implements Exception {
  final String message;
  AuthException([this.message = '认证失败']);
}

/// 模型异常
class ModelException implements Exception {
  final String message;
  ModelException([this.message = '模型处理异常']);
}
