import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/font/font_loader.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

import '../widgets/w_button.dart';

class FontTestPage extends StatelessWidget {
  const FontTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      appBar: AppBar(
        title: const Text('字体测试'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Center(
            child: WButton(
              onPressed: () => WbyFontLoader.initFonts(),
              child: const Text('下载字体'),
            ),
          ),
          const Divider(),
          ..._fontTests,
        ],
      ),
    );
  }

  static const _type1 = 'PingFangSC';
  static const _type2 = 'NotoSansSC';

  static const _fontTests = [
    _FontRow(family: _type1, weight: FontWeight.w100, label: 'W100'),
    _FontRow(family: _type1, weight: FontWeight.w200, label: 'W200'),
    _FontRow(family: _type1, weight: FontWeight.w300, label: 'W300'),
    _FontRow(family: _type1, weight: FontWeight.w400, label: 'W400'),
    _FontRow(family: _type1, weight: FontWeight.w500, label: 'W500'),
    _FontRow(family: _type1, weight: FontWeight.w600, label: 'W600'),
    _FontRow(family: _type1, weight: FontWeight.w700, label: 'W700'),
    _FontRow(family: _type1, weight: FontWeight.w800, label: 'W800'),
    _FontRow(family: _type1, weight: FontWeight.w900, label: 'W900'),
    _FontRow(family: _type2, weight: FontWeight.w500, style: FontStyle.normal, label: 'w500 N'),
    _FontRow(family: _type2, weight: FontWeight.w500, style: FontStyle.italic, label: 'w500 I'),
    _FontRow(family: _type2, weight: FontWeight.w900, style: FontStyle.normal, label: 'w900 N'),
    _FontRow(family: _type2, weight: FontWeight.w900, style: FontStyle.italic, label: 'w900 I'),
  ];
}

class _FontRow extends StatelessWidget {
  final String family;
  final FontWeight weight;
  final FontStyle? style;
  final String label;

  const _FontRow({required this.family, required this.weight, this.style, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('个人信息更改 $label', style: TextStyle(fontFamily: family, fontWeight: weight, fontStyle: style)),
      subtitle: Text('ABCDEFGabcdefg', style: TextStyle(fontFamily: family, fontWeight: weight, fontStyle: style)),
    );
  }
}
