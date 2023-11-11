import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';

class UpdateDetail extends StatelessWidget {
  const UpdateDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final version = context.read<UpdateManager>().version;

    return Text(
      version.content,
      style: TextUtil.base.sp(10).h(2),
    );
  }
}
