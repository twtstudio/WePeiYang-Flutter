import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

class CanteenPage extends StatefulWidget {
  const CanteenPage({super.key});

  @override
  State<CanteenPage> createState() => _CanteenPageState();
}

class _CanteenPageState extends State<CanteenPage> {
  static const _dishes = [
    (name: '番茄炒蛋', canteen: '食堂 A', price: 8),
    (name: '鸡腿饭', canteen: '食堂 B', price: 15),
    (name: '牛肉面', canteen: '食堂 C', price: 14),
  ];

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = WpyTheme.of(context);
    final background = theme.get(WpyColorKey.primaryBackgroundColor);
    final textColor = theme.get(WpyColorKey.basicTextColor);
    final secondaryTextColor = theme.get(WpyColorKey.secondaryTextColor);
    final keyword = _query.trim().toLowerCase();

    final dishes = _dishes.where((dish) {
      return dish.name.toLowerCase().contains(keyword) ||
          dish.canteen.toLowerCase().contains(keyword);
    }).toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textColor,
        centerTitle: true,
        title: const Text('食堂'),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                onChanged: (value) => setState(() => _query = value),
                style: TextStyle(color: textColor),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: '搜索菜品或食堂',
                  hintStyle: TextStyle(color: secondaryTextColor),
                  prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Text('示例菜品', style: TextStyle(color: secondaryTextColor)),
              const SizedBox(height: 8),
              Expanded(
                child: dishes.isEmpty
                    ? Center(
                  child: Text(
                    '没有找到匹配的菜品',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                )
                    : ListView.separated(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: dishes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final dish = dishes[index];
                    return ListTile(
                      tileColor:
                      theme.get(WpyColorKey.secondaryBackgroundColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        dish.name,
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Text(
                        dish.canteen,
                        style: TextStyle(color: secondaryTextColor),
                      ),
                      trailing: Text(
                        '¥${dish.price}',
                        style: TextStyle(color: textColor),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}