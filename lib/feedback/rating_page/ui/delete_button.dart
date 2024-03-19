import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modle/rating/rating_page_data.dart';


/************************
 * 删除按钮
 * English: Delete button
 ************************/
class DeleteButton extends StatelessWidget {
  final DataIndex dataIndex;

  DeleteButton({required this.dataIndex});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double mm = screenWidth * 0.9 / 60;

    DataIndexLeaf MyLeaf(DataIndex dataIndex){
      return context.read<RatingPageData>().getDataIndexLeaf(dataIndex);
    }

    _print(String message, Color color){
      context.read<RatingPageData>().powerPrint.print(context, message, color);
    }

    deleteData() async{
      try {
        await MyLeaf(dataIndex).delete(dataIndex);
        _print('删除成功', Colors.green);
      } catch (e) {
        try{
          assert(MyLeaf(dataIndex).dataM["delete"]!["error"] != null);
          _print('删除失败:'+MyLeaf(dataIndex).dataM["delete"]!["error"]??"", Colors.red);
        }
        catch(e){
          _print('删除失败', Colors.red);
        }
      }
    }

    Widget ic = Icon(
      Icons.delete,
      color: Colors.black.withOpacity(0.4),
      size: 4 * mm,
    );
    return InkWell(
      onTap: () {
        deleteData();
      },
      child: ic,
    );
  }
}

