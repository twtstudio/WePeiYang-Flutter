
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/feedback/view/History_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/collection_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/image_view/image_view_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/image_view/local_image_view_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/new_post_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/official_reply_detail_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/open_the_box.dart';
import 'package:we_pei_yang_flutter/feedback/view/person_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/post_detail_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/profile_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/reply_detail_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/report_question_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/search_page.dart';
import 'package:we_pei_yang_flutter/feedback/view/search_result_page.dart';
import 'package:we_pei_yang_flutter/home/view/home_page.dart';
import 'package:we_pei_yang_flutter/home/view/web_views/festival_page.dart';
import 'package:we_pei_yang_flutter/home/view/web_views/summary_page.dart';
import 'package:we_pei_yang_flutter/message/feedback_message_page.dart';
import 'package:we_pei_yang_flutter/message/feedback_notice_page.dart';

class FeedbackRouter {
  static String home = 'feedback/home';
  static String profile = 'feedback/profile';
  static String detail = 'feedback/detail';
  static String commentDetail = 'feedback/comment_detail';
  static String officialCommentDetail = 'feedback/offical_comment_detail';
  static String newPost = 'feedback/new_post';
  static String officialComment = 'feedback/official_comment';
  static String search = 'feedback/search';
  static String searchResult = 'feedback/search_result';
  static String mailbox = 'feedback/mailbox';
  static String imageView = 'feedback/image_view';
  static String localImageView = 'feedback/local_image_view';
  static String report = 'feedback/report';
  static String reportOther = 'feedback/report_other_reason';
  static String notice = 'feedback/notice';
  static String summary = 'feedback/summary';
  static String haitang = 'feedback/haitang';
  static String openBox = 'feedback/openbox';
  static String collection = 'feedback/collection';
  static String person = 'feedback/person';
  static String history= 'feedback/history';

  static final Map<String, Widget Function(dynamic arguments)> routers = {
    home: (args) => HomePage(args),
    profile: (_) => ProfilePage(),
    detail: (args) => PostDetailPage(args),
    commentDetail: (args) => ReplyDetailPage(args),
    officialCommentDetail: (args) => OfficialReplyDetailPage(args),
    newPost: (args) => NewPostPage(args),
    search: (_) => SearchPage(),
    searchResult: (args) => SearchResultPage(args),
    imageView: (args) => ImageViewPage(args),
    localImageView: (args) => LocalImageViewPage(args),
    mailbox: (_) => FeedbackMessagePage(),
    report: (args) => ReportQuestionPage(args),
    notice: (args) => FeedbackNoticePage(args),
    summary: (_) =>
        Builder(builder: (context) => FeedbackSummaryPage(context: context)),
    haitang: (args) =>
        Builder(builder: (context) => FestivalPage(args, context: context)),
    openBox: (args) => OpenBox(args),
    collection: (_) => CollectionPage(),
    person: (args) => PersonPage(args),
    history:(_)=>HistoryPage(),
  };
}
