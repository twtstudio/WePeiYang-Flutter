// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_pei_yang_flutter/lounge/util/theme_util.dart';
import 'package:we_pei_yang_flutter/lounge/view/page/search_page.dart';
import 'package:provider/provider.dart';

class HistoryChips extends StatelessWidget {
  const HistoryChips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final length = context.select(
      (SearchPageProvider provider) => provider.historyList.length,
    );

    final items = List.generate(
      length,
      (index) => Builder(
        builder: (context) {
          final text = context.select(
            (SearchPageProvider provider) {
              if (index >= provider.historyList.length) {
                return 'error';
              }
              return provider.historyList[index];
            },
          );

          return ActionChip(
            backgroundColor: Theme.of(context).searchHistoryChipBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11.w),
            ),
            labelPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.w),
            label: Text(text),
            labelStyle: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).searchHistoryChipText,
            ),
            onPressed: () {
              context.read<SearchPageProvider>().search(text);
            },
          );
        },
      ),
    );

    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 14.w,
      runSpacing: 15.w,
      children: items,
    );
  }
}
