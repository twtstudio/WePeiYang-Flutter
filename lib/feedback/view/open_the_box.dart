// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';

class OpenBox extends StatefulWidget {
  final int uid;

  const OpenBox(this.uid);

  @override
  _OpenBoxState createState() => _OpenBoxState();
}

class _OpenBoxState extends State<OpenBox> {
  List<Widget> srcList = [];
  bool loaded = false;
  var detail;

  @override
  void initState() {
    FeedbackService.superAdminOpenBox(
        uid: widget.uid,
        onResult: (re) {
          detail = re;
          srcList.clear();
          srcList.add(boxItem('uid', widget.uid.toString()));
          re.forEach((key, value) {
            srcList.add(boxItem(key, value));
          });
          setState(() {
            loaded = true;
          });
        },
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
                onPressed: () {
                  setState(() {
                    loaded = false;
                  });
                  FeedbackService.superAdminOpenBox(
                      uid: widget.uid,
                      onResult: (re) {
                        detail = re;
                        srcList.clear();
                        srcList.add(boxItem('uid', widget.uid.toString()));
                        re.forEach((key, value) {
                          srcList.add(boxItem(key, value));
                        });
                        setState(() {
                          loaded = true;
                        });
                      },
                      onFailure: (e) {
                        ToastProvider.error(e.message);
                      });
                },
                icon: Icon(
                  Icons.refresh,
                  color: Colors.black,
                )),
          ],
        ),
        body: loaded
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: ListView(
                  children: srcList,
                ))
            : Center(child: Loading()));
  }

  Widget boxItem(String src, String content) {
    return GestureDetector(
      child: SizedBox(
        width: double.infinity,
        child: Text(src + ': ' + content,
            style: TextUtil.base.black00.w400.sp(20).h(2).ProductSans),
      ),
      onTap: () async {
        if (src == '归属地') {
          String url =
              'https://qq.ip138.com/idsearch/index.asp?userid=${detail['身份证号']}&action=idcard';
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          } else {
            ToastProvider.error('请检查网络状态');
          }
        } else
          Clipboard.setData(ClipboardData(text: content))
              .whenComplete(() => ToastProvider.success('复制 $src 成功'));
      },
    );
  }
}
