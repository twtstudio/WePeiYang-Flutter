import 'package:flutter/material.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:image_size_getter_http_input/image_size_getter_http_input.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/feedback/network/feedback_service.dart';
import 'package:we_pei_yang_flutter/feedback/network/lost_and_found_post.dart';

class LostAndFoundModel with ChangeNotifier{
  Map<String, List<LostAndFoundPost>> postList = {
    '失物招领' : [],
    '寻物启事' : []
  };

  Map<String, LostAndFoundSubPageStatus> lostAndFoundSubPageStatus = {
    '失物招领' : LostAndFoundSubPageStatus.unload,
    '寻物启事' : LostAndFoundSubPageStatus.unload
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
    await FeedbackService.getLostAndFoundPosts(
        type: type,
        keyword: keyword,
        category: category,
        num: num ?? 10,
        onSuccess: (list) async{
          if(list.isEmpty){
            ToastProvider.cancelAll();
            ToastProvider.running('没有更多内容了');
          }else{
            for(LostAndFoundPost item in list){
              if(item.coverPhotoPath != null){
                if(_imageSizeCache[item.coverPhotoPath] != null)
                  item.coverPhotoSize = _imageSizeCache[item.coverPhotoPath];
                else{
                  final httpInput = await HttpInput.createHttpInput(item.coverPhotoPath!);
                  item.coverPhotoSize = await ImageSizeGetter.getSizeAsync(httpInput);
                  _cacheImageSize(item.coverPhotoPath!, item.coverPhotoSize);
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

  void _cacheImageSize(String photoPath, Size? size){
    if(size == null) return;
    if(_imageSizeCache.length >= 50) _imageSizeCache.clear();
    _imageSizeCache[photoPath] = size;
  }
}

enum LostAndFoundSubPageStatus{
  loading,
  unload,
  ready,
  error
}


