import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';

typedef _Count = ({String name, int people, int capacity});

class CanteenPanel extends StatefulWidget {
  const CanteenPanel({super.key});

  @override
  State<CanteenPanel> createState() => _CanteenPanelState();
}

class _CanteenPanelState extends State<CanteenPanel> {
  static const _samples = <List<_Count>>[
    [
      (name: '食堂 A', people: 270, capacity: 500),
      (name: '食堂 B', people: 105, capacity: 300),
    ],
    [
      (name: '食堂 C', people: 260, capacity: 600),
      (name: '食堂 D', people: 357, capacity: 800),
    ],
  ];

  int _campus = 0;
  late Future<List<_Count>> _counts;

  @override
  void initState() {
    super.initState();
    _counts = _loadCounts(_campus);
  }

  Future<List<_Count>> _loadCounts(int campus) {
    return Future.delayed(
      const Duration(milliseconds: 350),
          () => _samples[campus],
    );
  }

  void _showCampus(int campus) {
    setState(() {
      _campus = campus;
      _counts = _loadCounts(campus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = WpyTheme.of(context);
    final blue = theme.get(WpyColorKey.linkBlue);
    final textColor = theme.get(WpyColorKey.basicTextColor);

    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '食堂实时人数',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: '刷新人数',
                  onPressed: () => _showCampus(_campus),
                  icon: Icon(Icons.refresh, color: blue),
                ),
              ],
            ),
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: blue,
              unselectedLabelColor: theme.get(WpyColorKey.secondaryTextColor),
              indicatorColor: blue,
              tabs: const [Tab(text: '北洋园'), Tab(text: '卫津路')],
              onTap: (index) {
                if (index != _campus) _showCampus(index);
              },
            ),
            Expanded(
              child: FutureBuilder<List<_Count>>(
                future: _counts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('读取失败，请刷新重试'));
                  }

                  final counts = snapshot.data ?? const <_Count>[];
                  if (counts.isEmpty) {
                    return const Center(child: Text('暂无人数数据'));
                  }

                  return ListView(
                    primary: false,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      Text('示例数据', style: TextStyle(color: textColor)),
                      for (final count in counts) _buildCard(count, theme),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(_Count count, WpyTheme theme) {
    final ratio = count.capacity > 0
        ? (count.people / count.capacity).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final blue = theme.get(WpyColorKey.linkBlue);

    return Card(
      elevation: 0,
      color: theme.get(WpyColorKey.secondaryBackgroundColor),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count.name,
              style: TextStyle(color: theme.get(WpyColorKey.basicTextColor)),
            ),
            const SizedBox(height: 6),
            Text(
              '${count.people} 人在座 · ${count.capacity} 个座位',
              style: TextStyle(color: blue),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: ratio, color: blue),
          ],
        ),
      ),
    );
  }
}