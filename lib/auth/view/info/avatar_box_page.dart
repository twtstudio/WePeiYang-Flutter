import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:we_pei_yang_flutter/auth/view/user/user_avatar_image.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/w_button.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/post.dart';

class AvatarBoxPage extends StatefulWidget {
  @override
  _AvatarBoxPageState createState() => _AvatarBoxPageState();
}

class _AvatarBoxPageState extends State<AvatarBoxPage> {
  ValueNotifier<String> _valueNotifier =
      ValueNotifier<String>(CommonPreferences.avatarBoxMyUrl.value);

  @override
  void initState() {
    _valueNotifier.value = CommonPreferences.avatarBoxMyUrl.value;
    super.initState();
  }

  @override
  void dispose() {
    _valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          '更换头像框',
          style: TextUtil.base.black2A.sp(16),
        ),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: GestureDetector(
              child: Icon(Icons.arrow_back,
                  color: Color.fromRGBO(53, 59, 84, 1.0), size: 32),
              onTap: () => Navigator.pop(context)),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              width: width,
              height: height * 0.3,
              child: ValueListenableBuilder<String>(
                  valueListenable: _valueNotifier,
                  builder: (c, i, _) {
                    return Center(
                      child: Hero(
                        tag: 'avatar',
                        child: UserAvatarImage(
                          size: width * 0.4,
                          iconColor: Colors.white,
                        ),
                      ),
                    );
                  }),
            ),
            AvatarListBuilder(_valueNotifier),
          ],
        ),
      ),
    );
  }
}

class AvatarListBuilder extends StatefulWidget {
  final ValueNotifier<String> valueNotifier;

  AvatarListBuilder(this.valueNotifier);

  @override
  _AvatarListBuilderState createState() => _AvatarListBuilderState();
}

class _AvatarListBuilderState extends State<AvatarListBuilder> {
  List<AvatarBox> urlList = [];

  Future<void> loadAvatarBox() async {
    urlList.clear();
    urlList = await FeedbackService.getAllAvatarBox();
    urlList.add(urlList[0]);
    urlList.add(urlList[0]);
    urlList.add(urlList[0]);
    urlList.add(urlList[0]);
    urlList.add(urlList[0]);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return FutureBuilder(
      future: loadAvatarBox(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        switch (asyncSnapshot.connectionState) {
          case ConnectionState.none:
            return Text('none');
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.active:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            if (asyncSnapshot.hasError)
              return Center(child: CircularProgressIndicator());
            else
              return Container(
                width: width * 0.9,
                height: 300.h,
                child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: urlList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      childAspectRatio: 1.3,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            WButton(
                              onPressed: () async {
                                if (CommonPreferences.avatarBoxMyUrl.value ==
                                    "") {
                                  await FeedbackService.setAvatarBox(
                                          urlList[index])
                                      .then((value) {
                                    widget.valueNotifier.value =
                                        CommonPreferences.avatarBoxMyUrl.value;
                                  });
                                } else {
                                  await FeedbackService.updateAvatarBox(
                                          urlList[index])
                                      .then((value) {
                                    widget.valueNotifier.value =
                                        CommonPreferences.avatarBoxMyUrl.value;
                                  });
                                }
                              },
                              child: Container(
                                  width: 100.w,
                                  height: 100.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.r)),
                                  ),
                                  child: Center(
                                    child: WpyPic(
                                      '${urlList[index].addr}',
                                      withCache: true,
                                      withHolder: true,
                                    ),
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5.h),
                              child: Text('${urlList[index].comment}'),
                            ),
                          ],
                        ),
                      );
                    }),
              );
        }
        return Container();
      },
    );
    /*
    return */
  }
}
