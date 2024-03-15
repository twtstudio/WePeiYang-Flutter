import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/user_data.dart';

class LikeButton extends StatefulWidget {

  final DataIndex dataIndex;
  final int likeCount;
  final List<String> likeId;
  LikeButton({
    required this.dataIndex,
    required this.likeCount,
    required this.likeId,
  });
  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  ValueNotifier<bool> isLiked = ValueNotifier(false);
  int _likeCount = 0;

  @override
  void initState() {
    try{
      _likeCount = widget.likeCount;
      isLiked.value = widget.likeId.contains(myUserId);
    }
    catch(e){
      isLiked.value = false;
    }
    isLiked.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  clickLike() {
    if (isLiked.value) {
      _likeCount -= 1;
    } else {
      _likeCount += 1;
    }
    isLiked.value = !isLiked.value;
    like();
  }

  DataIndexLeaf myLeaf(){
    return context
        .read<RatingPageData>()
        .getDataIndexLeaf(widget.dataIndex);
  }

  //将点赞结果同步到云端
  like() async {
    var wantToDo = isLiked.value;
    try{
      await myLeaf()
          .like(widget.dataIndex, isLiked.value ? "true":"false");

      assert(myLeaf().isSucceed("like"));
      (wantToDo) ?
      _print("点赞成功~", Colors.green)
          :_print("取消成功~", Colors.green);

      await myLeaf().retry("get");
      assert(myLeaf().isSucceed("get"));
      setState(() {});
    }
    catch(e1){
      try{
        assert(myLeaf().dataM["like"]!["error"]!=null);
        _print(
            "网络错误:"+
            myLeaf().dataM["like"]!["error"],
            Colors.red
        );
      }
      catch(e2){
        _print("网络错误:"+e2.toString(),Colors.red);
      }
    }
  }

  /************************
   * 用于弹出提示
   * English: Used to pop up prompts
   ************************/
  _print(String message,Color color){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: color,
          content: Text(message),
          duration: Duration(seconds: 1), // 设置显示时间
        )
    );
  }



  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double mm = screenWidth * 0.9 / 60; //获取现实中1毫米的像素长度

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            //靠上
            mainAxisAlignment: MainAxisAlignment.start,
            children:[
              IconButton(
                icon: (isLiked.value ? Icon(Icons.favorite,size: 3*mm,) : Icon(Icons.favorite_border,size: 3*mm)),
                color: (isLiked.value ? Colors.red : Colors.grey),
                onPressed: ()=>{
                  clickLike()
                },
              ),
              Text('$_likeCount',style: TextStyle(fontSize: 3*mm,color: Colors.grey)),
            ],
          ),
        ],
      )
    );
  }
}