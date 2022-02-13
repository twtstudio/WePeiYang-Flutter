// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/update/update_util.dart';
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
        FutureBuilder(
          future: UpdateUtil.getVersion(),
          builder: (_, snapshot) {
            String versionChange;
            if (snapshot.hasData) {
              versionChange = '${snapshot.data} -> ${version.version}';
            } else {
              versionChange = '将更新到${version.version}';
            }
            return Text(
              versionChange,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            );
          },
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
