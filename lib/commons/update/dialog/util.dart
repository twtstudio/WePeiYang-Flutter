// @dart = 2.12

enum DialogTag { apk, hotfix, install, progress }

extension DialogTagExt on DialogTag {
  String get text => [
        'updateDialog',
        'hotfixDialog',
        'installDialog',
        'progressDialog',
      ][index];
}
