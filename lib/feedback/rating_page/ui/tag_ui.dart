import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';

class TagUI extends StatelessWidget {

  final DataIndexTree dataIndexTree;
  TagUI({required this.dataIndexTree});

  @override
  Widget build(BuildContext context) {

    List<Widget> tagWidget = [];

    //如果当前的tag在tagList之外,就设定为tagList的首项
    if(!dataIndexTree.tagListChinese.contains(context.read<RatingPageData>().nowSortType.value)){
      context.read<RatingPageData>().nowSortType.value = dataIndexTree.tagListChinese[0];
    }

    tagWidget.add(Container(width: 16,));

    for(var tag in dataIndexTree.tagListChinese){

      Widget a = ValueListenableBuilder<String>(
        valueListenable: context.read<RatingPageData>().nowSortType,
        builder: (context, value, child) {
          return Text(
            "$tag ",
            style: TextStyle(
              fontFamily: "NotoSansSC",
              color: value == tag ? Colors.grey : Colors.grey.withOpacity(0.6),
              fontWeight: FontWeight.bold, // 设置字体为粗体
              fontSize: 18,
            ),
          );
        },
      );

      a = InkWell(
        onTap: () {
          context.read<RatingPageData>().nowSortType.value = tag;
        },
        child: a,
      );

      tagWidget.add(a);
    }

    tagWidget.add(Column(
      children: [

      ],
    ));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // 靠左边的组件
        Row(
          children: tagWidget,
        ),

        // 靠右边的组件
        Row(
          children: <Widget>[

            InkWell(
              onTap: () {
                dataIndexTree.reset();
              },
              child: Icon(
                Icons.downloading,
                color: Colors.grey,
              ),
            ),

            Container(width: 24,),
          ],
        ),
      ],
    );
  }
}