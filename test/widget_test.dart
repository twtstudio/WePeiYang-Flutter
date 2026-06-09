import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/storage_util.dart';

class _TestPathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '/tmp/wpy_test/docs';

  @override
  Future<String?> getApplicationSupportPath() async => '/tmp/wpy_test/support';

  @override
  Future<String?> getDownloadsPath() async => '/tmp/wpy_test/downloads';

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async =>
      ['/tmp/wpy_test/external'];

  @override
  Future<String?> getTemporaryPath() async => '/tmp/wpy_test/tmp';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    PathProviderPlatform.instance = _TestPathProvider();
    SharedPreferences.setMockInitialValues({});
    EnvConfig.init();
    await StorageUtil.init();
    await CommonPreferences.init();
  });

  test('startup dependencies are initialized in order', () {
    expect(StorageUtil.downloadDir.path, '/tmp/wpy_test/docs');
    expect(StorageUtil.filesDir.path, '/tmp/wpy_test/support');
    expect(CommonPreferences.token.value, '');
  });
}
