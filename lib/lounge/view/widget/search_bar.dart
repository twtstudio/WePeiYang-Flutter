// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/lounge/util/image_util.dart';
import 'package:we_pei_yang_flutter/lounge/lounge_router.dart';
import 'package:we_pei_yang_flutter/lounge/util/theme_util.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 25.w, 0, 40.w),
      child: Container(
        height: 38.w,
        width: 317.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19.w),
          shape: BoxShape.rectangle,
          color: Theme.of(context).mainPageSearchBarBackground,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(19.w),
          onTap: () async {
            Navigator.pushNamed(context, LoungeRouter.search);
            // var result = await customShowSearch<HistoryEntry?>(
            //     context: context, delegate: SRSearchDelegate());
            // // Scaffold.of(context).showSnackBar(SnackBar(content: Text(result.cId)));
            // if (result != null) {
            //   final classroom = Classroom(
            //     name: result.cName,
            //     aId: result.aId,
            //     bName: result.bName,
            //     id: result.cId,
            //     capacity: 0,
            //     bId: result.bId,
            //     status: '',
            //   );

            //   String title = DataFactory.getRoomTitle(classroom);
            //   Navigator.of(context).pushNamed(
            //     LoungeRouter.plan,
            //     arguments: [classroom,title],
            //   );
            // }
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(22.w, 11.w, 0, 11.w),
            child: Row(
              children: [
                Image.asset(
                  Images.search,
                  height: 16.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
