import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/feedback/rating_page/modle/rating/rating_page_data.dart';

class RatingPage extends StatelessWidget {
  const RatingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return ValueListenableBuilder<Widget>(
      valueListenable: context.read<RatingPageData>().nowPageWidget,
      builder: (BuildContext context, Widget nowPageWidget, Widget? child) {
        return nowPageWidget;
      },
    );
  }
}
