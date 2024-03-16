import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/user_data.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/ui/power_print.dart';

class LikeButton extends StatefulWidget {

  final DataIndex dataIndex;
  LikeButton({
    required this.dataIndex,
  });
  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  ValueNotifier<bool> isLiked = ValueNotifier(false);
  int likeCount = 0;
  String likeId = " ";

  loadUI() async {
    try{
      likeCount =
          context
          .read<RatingPageData>()
          .getDataIndexLeaf(widget.dataIndex)
          .dataM["get"]!["likeCount"];
      likeId =
      context
          .read<RatingPageData>()
          .getDataIndexLeaf(widget.dataIndex)
          .dataM['get']!["likeId"];
      isLiked.value = likeId.contains(myUserId);
      setState(() {
      });
    }
    catch(e){
      print(e);
      //等待400ms后再次尝试
      Future.delayed(Duration(milliseconds: 400), () {
        loadUI();
      });
    }
  }

  @override
  void initState() {
    isLiked.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  //销毁后,重置数据
  @override
  void dispose() {
    super.dispose();
  }

  clickLike() {
    isLiked.value = !isLiked.value;
    setState(() {});
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
      if(wantToDo){
        _print("点赞成功~", Colors.green);
        myLeaf()
            .dataM["get"]!["likeCount"]++;
        myLeaf()
            .dataM["get"]!["likeId"] = myLeaf().dataM["get"]!["likeId"]+myUserId;
      }
      else{
        _print("取消成功~", Colors.green);
        myLeaf()
            .dataM["get"]!["likeCount"]--;
        myLeaf()
            .dataM["get"]!["likeId"] = myLeaf().dataM["get"]!["likeId"].replaceAll(myUserId, "");
      }
      loadUI();
    }
    catch(e1){
      try{
        assert(myLeaf().dataM["like"]!["error"]!=null);
        _print(myLeaf().dataM['like']!["error"],Colors.red);
      }
      catch(e2){
        _print("网络错误:"+e1.toString(),Colors.red);
      }
    }
  }

  /************************
   * 用于弹出提示
   * English: Used to pop up prompts
   ************************/
  _print(String message,Color color){
    context
        .read<RatingPageData>()
        .powerPrint.print(context, message, color);
  }

  int c=0;
  @override
  Widget build(BuildContext context) {
    loadUI();
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

              InkWell(
                onTap: () {
                  clickLike();
                },
                child: Icon(
                  isLiked.value ? Icons.favorite : Icons.favorite_border,
                  color: isLiked.value ? Colors.red : Colors.grey,
                  size: 3*mm,
                ),
              ),
              Text(' ${likeCount.toString()}',style: TextStyle(fontSize: 3*mm,color: Colors.grey)),
            ],
          ),
        ],
      )
    );
  }
}