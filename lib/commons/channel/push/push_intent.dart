// @dart = 2.12

import 'package:flutter/foundation.dart';

enum IntentType { feedback, mailbox }

extension IntentTypeExt on IntentType {
  String get text => ["feedback", "mailbox"][index];
}

abstract class PushIntent {
  @protected
  IntentType get type;

  @protected
  Map<String, dynamic> toMap();
}

class FeedbackIntent extends PushIntent {
  FeedbackIntent(this.questionId);

  @override
  IntentType get type => IntentType.feedback;

  final int questionId;

  Map<String, dynamic> toMap() {
    return {
      'type': type.text,
      'question_id': questionId,
    };
  }
}

class MailboxIntent extends PushIntent {
  MailboxIntent(this.url, this.title, this.content, this.createdAt);

  @override
  IntentType get type => IntentType.mailbox;

  final String url;
  final String title;
  final String content;
  final String createdAt;

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': type.text,
      'url': url,
      'title': title,
      'content': content,
      'createdAt': createdAt,
    };
  }
}

class FeedbackSummaryIntent extends PushIntent {
  @override
  IntentType get type => IntentType.feedback;

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': type.text,
      'page': 'summary',
    };
  }
}
