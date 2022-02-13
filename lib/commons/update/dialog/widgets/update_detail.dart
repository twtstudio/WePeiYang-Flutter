// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';

class UpdateDetail extends StatelessWidget {
  final Version version;
  const UpdateDetail(this.version,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Text(
      version.content,
      style: const TextStyle(
        fontSize: 10,
        height: 2,
      ),
    );
  }
}
