import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';

final userDio = UserNotificationDio();

class UserNotificationDio extends DioAbstract {
  @override
  Map<String, String>? headers = {
    'DOMAIN': AuthDio.DOMAIN,
    'ticket': AuthDio.ticket,
    'token': CommonPreferences.token.value
  };
}

Future<UserMessages> getUserMails(int page) async {
  var response =
      await userDio.get('https://api.twt.edu.cn/api/notification/history/user');
  var messages = UserMessages.fromJson(response.data);
  return messages;
}

class UserMessages {
  int code;
  String message;
  List<UserMail> mails;

  UserMessages.fromJson(Map<dynamic, dynamic> json)
      : this.code = json['error_code'] ?? 0,
        this.message = json['message'] ?? '',
        this.mails = [
          ...((json['result'] ?? <UserMail>[]) as List)
              .map((e) => UserMail.fromJson(e))
              .toList()
        ];
}

class UserMail {
  String title;
  String content;
  String time;
  String url;
  int id;

  UserMail.fromJson(Map<dynamic, dynamic> json)
      : this.title = json['title'] ?? '',
        this.content = json['content'] ?? '',
        this.time = json['createdAt'] ?? '',
        this.url = json['url'] ?? '',
        this.id = json['id'] ?? 0;

  @override
  String toString() {
    return """
    title: $title
    content: $content
    time: $time
    url: $url    
    """;
  }
}
