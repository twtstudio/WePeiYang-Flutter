import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/tag.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';


class FbTagsProvider {
  List<Tag> tagList = List();

  Future<void> initTags() async {
    await FeedbackService.getTags(
      CommonPreferences().feedbackToken.value,
      onResult: (list) {
        tagList.clear();
        tagList.addAll(list);
      },
      onFailure: (e) {
        ToastProvider.error(e.error.toString());
      },
    );
  }
}