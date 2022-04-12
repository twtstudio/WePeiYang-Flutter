// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';

class UpdateTitle extends StatelessWidget {
  final Version version;

  const UpdateTitle(this.version, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "版本更新",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 3),
        Text(
          '${EnvConfig.VERSION} -> ${version.version}',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
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
