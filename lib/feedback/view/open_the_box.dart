import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';

class OpenBox extends StatefulWidget {
  final int uid;

  const OpenBox(this.uid);

  @override
  _OpenBoxState createState() => _OpenBoxState();
}

class _OpenBoxState extends State<OpenBox> {
  String detail = '未获取到数据';

  @override
  void initState() {
    FeedbackService.superAdminOpenBox(
        uid: widget.uid,
        onResult: (re) => setState(() {
              detail = re ?? '未获取到数据';
            }),
        onFailure: (e) {
          ToastProvider.error(e.message);
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("开盒",
              style: TextUtil.base.bold
                  .sp(17)
                  .customColor(Color.fromRGBO(36, 43, 69, 1))),
          elevation: 0,
          brightness: Brightness.light,
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(53, 59, 84, 1), size: 32),
                onTap: () => Navigator.pop(context)),
          ),
          actions: [
            IconButton(
                onPressed: () => {
                      FeedbackService.superAdminOpenBox(
                          uid: widget.uid,
                          onResult: (re) => setState(() {
                                detail = re ?? 'oh';
                              }),
                          onFailure: (e) {
                            ToastProvider.error(e.message);
                          })
                    },
                icon: Icon(
                  Icons.refresh,
                  color: Colors.black,
                )),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: detail))
                    .whenComplete(() => ToastProvider.running('复制成功'));
              },
              child: Text(
                '复制全部',
                style: TextUtil.base.black00,
              ),
            )
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: SingleChildScrollView(
              child: Text(
                detail,
                style: TextUtil.base.black2A.h(1.6).w600.sp(20),
              ),
            )));
  }
}
