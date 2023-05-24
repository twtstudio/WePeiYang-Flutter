import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/update/update_manager.dart';

class UpdateDetail extends StatelessWidget {
  const UpdateDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final version = context.read<UpdateManager>().version;

    return Text(
      version.content,
      style: const TextStyle(
        fontSize: 10,
        height: 2,
      ),
    );
  }
}
