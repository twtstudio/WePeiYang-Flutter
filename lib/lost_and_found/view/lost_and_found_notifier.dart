import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:image_size_getter_http_input/image_size_getter_http_input.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/extension/extensions.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/themes/color_util.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/type_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/wpy_pic.dart';
import 'package:we_pei_yang_flutter/lost_and_found/lost_and_found_router.dart';
import 'package:we_pei_yang_flutter/lost_and_found/network/lost_and_found_post.dart';
import 'package:we_pei_yang_flutter/lost_and_found/network/lost_and_found_service.dart';

class LostAndFoundModel with ChangeNotifier {
  Map<String, List<LostAndFoundPost>> postList = {'失物招领': [], '寻物启事': []};

  Map<String, LostAndFoundSubPageStatus> lostAndFoundSubPageStatus = {
    '失物招领': LostAndFoundSubPageStatus.unload,
    '寻物启事': LostAndFoundSubPageStatus.unload
  };

  Map<String, RefreshController> refreshController = {
    '失物招领' : RefreshController(),
    '寻物启事' : RefreshController(),
  };

  Map<String, String> currentCategory = {
    '失物招领' : '全部',
    '寻物启事' : '全部',
  };

  clearByType(type){
    postList[type]?.clear();
    lostAndFoundSubPageStatus[type] = LostAndFoundSubPageStatus.unload;
  }

  Map<String, bool> searchAndTagVisibility = {
    '失物招领' : true,
    '寻物启事' : true,
  };

  Map<String, Size> _imageSizeCache = {};


  Future<void> getNext({
    required String type,
    required OnSuccess success,
    required OnFailure failure,
    required String category,
    String? keyword,
    int? num }) async{
    await LostAndFoundService.getLostAndFoundPosts(
      type: type,
      keyword: keyword,
      category: category,
      num: num ?? 10,
      onSuccess: (list) async {
        if (list.isEmpty) {
          ToastProvider.cancelAll();
          ToastProvider.running('没有更多内容了');
        } else {
          for (LostAndFoundPost item in list) {
            if(item.coverPhotoPath != null){
                if(_imageSizeCache[item.coverPhotoPath] != null)
                  item.coverPhotoSize = _imageSizeCache[item.coverPhotoPath];
                else{
                  final httpInput =
                    await HttpInput.createHttpInput(item.coverPhotoPath!);
                item.coverPhotoSize =
                    await ImageSizeGetter.getSizeAsync(httpInput);
                cacheImageSize(item.coverPhotoPath!, item.coverPhotoSize);
              }
              }
            }
          }
          postList[type]?.addAll(list);

          success();
          notifyListeners();
        },
        onFailure: (e){
          failure(e);
        },
        history: postList[type]!.isEmpty? '0' :  postList[type]!.map((e) => e.id).toList().join(','),
    );
  }

  void resetCategory({
    required String type,
    required String category}){
    currentCategory[type] = category;
    notifyListeners();
  }

  void setSearchAndTagVisibility(bool isVisible, String type){
    searchAndTagVisibility[type] = isVisible;
    notifyListeners();
  }

  void getClipboardWeKoContents(BuildContext context) async {
    ClipboardData? clipboardData =
    await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null &&
        clipboardData.text != null &&
        clipboardData.text!.trim() != '') {
      String text = clipboardData.text!.trim();
      final id = text.find(r"wpy://school_project/(\d*)");
      if (id.isNotEmpty) {
        LostAndFoundService.getLostAndFoundPostDetail(
            id: int.parse(id),
            onResult: (post) {
              showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return LAFWeKoDialog(
                    post: post,
                    onConfirm: () => Navigator.pop(context, true),
                    onCancel: () => Navigator.pop(context, true),
                  );
                },
                ).then((confirm) {
                  Tuple2 tuple = Tuple2(int.parse(id), post.type == '失物招领' ? true : false);
                  if (confirm != null && confirm) {
                    Navigator.pushNamed(
                      context, LostAndFoundRouter.lostAndFoundDetailPage,
                      arguments: tuple);
                    CommonPreferences.feedbackLastLostAndFoundWeCo.value = id;
                  } else {
                    CommonPreferences.feedbackLastLostAndFoundWeCo.value = id;
                  }
                });
              },
              onFailure: (e) {
                ToastProvider.error(e.error.toString());
              });
      }
    }
  }

  void cacheImageSize(String photoPath, Size? size) {
    if (size == null) return;
    if (_imageSizeCache.length >= 50) _imageSizeCache.clear();
    _imageSizeCache[photoPath] = size;
  }
}

enum LostAndFoundSubPageStatus{
  loading,
  unload,
  ready,
  error
}

class LAFWeKoDialog extends StatelessWidget {
  final LostAndFoundPost post;
  final void Function() onConfirm;
  final void Function() onCancel;

  LAFWeKoDialog(
      {Key? key,
        required this.post,
        required this.onConfirm,
        required this.onCancel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin:  EdgeInsets.symmetric(horizontal: 30.w),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: ColorUtil.backgroundColor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.w),
                child: Text('有人给你分享了微口令!',
                    style: TextUtil.base.black2A.regular.sp(16).NotoSansSC),
              ),
              Padding(
                padding: EdgeInsets.all(20.r),
                child: Text(post.title,
                    style: TextUtil.base.black2A.bold.sp(17).NotoSansSC),
              ),
              if (post.coverPhotoPath != null)
                WpyPic(
                  post.coverPhotoPath!,
                  height: 150.h,
                  width: 150.w,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
                child: Text(
                  post.text,
                  style: TextUtil.base.grey6C.regular.sp(14).NotoSansSC,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton(
                onPressed: onConfirm,
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(3),
                  overlayColor:
                  MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.pressed))
                      return ColorUtil.blue79;
                    return ColorUtil.backgroundColor;
                  }),
                  backgroundColor:
                  MaterialStateProperty.all(ColorUtil.backgroundColor),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r))),
                ),
                child: Container(
                  margin: EdgeInsets.all(7.r),
                  child: Text(
                    '查看详情',
                    style: TextUtil.base.black2A.regular.sp(16).NotoSansSC,
                  ),
                ),
              ),
              SizedBox(height: 15.h),
            ],
          ),
        ),
      ],
    );
  }
}



