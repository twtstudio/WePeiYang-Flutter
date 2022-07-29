import 'package:flutter/cupertino.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';

class ProFileProvider extends ChangeNotifier {
  List<Post> favList = [];

  Future<void> _getMyPosts({Function(List<Post>) onSuccess, Function onFail, int current}) {
    FeedbackService.getMyPosts(
        page: current ,
        page_size: 10,
        onResult: (list) {
            onSuccess?.call(list);
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          onFail?.call();
        });
  }

  Future<void>  _getMyCollects(
      {Function(List<Post>) onSuccess, Function onFail, int current}) {
    FeedbackService.getFavoritePosts(
        page: current ,
        page_size: 10,
        onResult: (list) {
            onSuccess?.call(list);
        },
        onFailure: (e) {
          ToastProvider.error(e.error.toString());
          onFail?.call();
        });
  }
}