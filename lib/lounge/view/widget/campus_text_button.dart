// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/config_provider.dart';
import 'package:we_pei_yang_flutter/lounge/util/image_util.dart';
import 'package:we_pei_yang_flutter/lounge/util/theme_util.dart';

class CampusTextButton extends StatelessWidget {
  const CampusTextButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final directionImage = Image.asset(
      Images.direction,
      width: 15.w,
    );

    final textButton = Builder(
      builder: (context) {
        return TextButton(
          onPressed: () => context.read<LoungeConfig>().changeCampus(),
          child: Text(
            context.watch<LoungeConfig>().campus.name,
            style: TextStyle(
              color: Theme.of(context).campusButtonText,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );

    // TODO: ???
    final dateTime = Builder(
      builder: (context) {
        final dateTime = DateFormat('2019-MM-dd').format(context.select(
          (LoungeConfig provider) => provider.dateTime,
        ));
        return Text(
          dateTime,
          style: TextStyle(
            fontSize: 13.sp,
            color: Theme.of(context).dataUpdateTime,
          ),
        );
      },
    );

    return Row(
      children: [
        directionImage,
        textButton,
        const Spacer(),
        dateTime,
      ],
    );
  }
}
