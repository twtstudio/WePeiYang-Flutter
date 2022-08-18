// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/lounge/provider/config_provider.dart';
import 'package:we_pei_yang_flutter/lounge/util/image_util.dart';

class CampusTextButton extends StatelessWidget {
  const CampusTextButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final directionImage = SvgPicture.asset(
      Images.direction,
      width: 10.w,
    );

    return SizedBox(
      width: 90.w,
      child: Builder(
        builder: (context) {
          return TextButton.icon(
            onPressed: () => context.read<LoungeConfig>().changeCampus(),
            icon: Text(
              context.watch<LoungeConfig>().campus.name,
              style: TextUtil.base.PingFangSC.black2A.bold.sp(14),
            ),
            label: directionImage,
          );
        },
      ),
    );
  }
}
