// @dart = 2.12

import 'package:we_pei_yang_flutter/commons/util/logger.dart';

enum LoungeErrorType {
  network,
  database,
  other,
}

/// 自习室自定义错误类型
class LoungeError implements Exception {
  LoungeError._(
    this.error, {
    this.stackTrace,
    this.des,
    this.type = LoungeErrorType.other,
  });

  factory LoungeError.network(
    dynamic error, {
    StackTrace? stackTrace,
    String? des,
  }) {
    return LoungeError._(
      error,
      stackTrace: stackTrace,
      des: des,
      type: LoungeErrorType.network,
    );
  }

  factory LoungeError.database(
    dynamic error, {
    StackTrace? stackTrace,
    String? des,
  }) {
    return LoungeError._(
      error,
      stackTrace: stackTrace,
      des: des,
      type: LoungeErrorType.database,
    );
  }

  factory LoungeError.other(
    Object error, {
    StackTrace? stackTrace,
    String? des,
  }) {
    return LoungeError._(
      error,
      stackTrace: stackTrace,
      des: des,
      type: LoungeErrorType.other,
    );
  }

  void report() {
    Logger.reportError(this, stackTrace);
  }

  final LoungeErrorType type;

  bool get isDB => type == LoungeErrorType.database;

  bool get isNet => type == LoungeErrorType.network;

  /// The original error/exception object; It's usually not null when `type`
  /// is DioErrorType.other
  final dynamic error;

  final StackTrace? stackTrace;

  final String? des;

  String get message => (error.toString());

  @override
  String toString() {
    var msg = 'LoungeError [$type]: $message';
    msg += '\ndescription: $des';
    if (error is Error) {
      msg += '\n${(error as Error).stackTrace}';
    }
    if (stackTrace != null) {
      msg += '\nSource stack:\n$stackTrace';
    }
    return msg;
  }
}

extension LoungeErrorExt on Object {
  bool get isNotLoungeError => !(this is LoungeError);
}
