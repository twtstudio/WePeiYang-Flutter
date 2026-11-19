import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

class CanteenPage extends StatelessWidget {
  const CanteenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = WpyTheme.of(context);
    final background = theme.get(WpyColorKey.primaryBackgroundColor);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: theme.get(WpyColorKey.basicTextColor),
        centerTitle: true,
        title: const Text('食堂'),
      ),
    );
  }
}