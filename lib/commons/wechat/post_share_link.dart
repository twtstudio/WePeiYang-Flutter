/// Shared contract between the landing page and the Android post router.
class PostShareLink {
  static const landingPage = String.fromEnvironment(
    'POST_SHARE_LANDING_PAGE',
    defaultValue: 'https://mobile.twt.edu.cn/wpy/index.html',
  );

  static String webUrl(int postId) {
    if (postId <= 0) throw ArgumentError.value(postId, 'postId');
    final uri = Uri.parse(landingPage);
    if (uri.scheme != 'https' || uri.host.isEmpty) {
      throw StateError('POST_SHARE_LANDING_PAGE must be an HTTPS URL');
    }
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      'id': '$postId',
    }).toString();
  }

  static String appUrl(int postId) => 'wpy://wpy.app/post?id=$postId';

  static int? postIdFromAppUrl(String? value) {
    final uri = value == null ? null : Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'wpy' ||
        uri.host != 'wpy.app' ||
        uri.path != '/post') return null;
    final id = int.tryParse(uri.queryParameters['id'] ?? '');
    return id != null && id > 0 && id <= 2147483647 ? id : null;
  }
}
