import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

class UpdateTitle extends StatelessWidget {
  const UpdateTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final version = context.read<UpdateManager>().version;

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
         Text(
          "版本更新",
          style: TextUtil.base.w600.sp(17),
        ),
        const SizedBox(height: 3),
        Text(
          Platform.isAndroid
              ? '${EnvConfig.VERSION} -> ${version.version}'
              : '最新版本: ${version.version}',
          style: TextUtil.base.w600.sp(10),
        ),
      ],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        title,
      ],
    );
  }
}
