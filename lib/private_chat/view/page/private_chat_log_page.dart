import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/themes/template/wpy_theme_data.dart';
import 'package:we_pei_yang_flutter/commons/themes/wpy_theme.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/private_chat/model/private_chat_provider.dart';
import 'package:we_pei_yang_flutter/private_chat/network/private_chat_service.dart';

/// 私聊调试日志页面 — 显示 HTTP 和 WebSocket 通信日志
class PrivateChatLogPage extends StatefulWidget {
  const PrivateChatLogPage({super.key});

  @override
  State<PrivateChatLogPage> createState() => _PrivateChatLogPageState();
}

class _PrivateChatLogPageState extends State<PrivateChatLogPage> {
  final _scrollController = ScrollController();
  String _filter = '';
  bool _autoScroll = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients && _autoScroll) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
      appBar: AppBar(
        title: Text('调试日志',
            style: TextUtil.base.bold.sp(17).label(context)),
        backgroundColor:
            WpyTheme.of(context).get(WpyColorKey.primaryBackgroundColor),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.copy_all, size: 22.sp),
            onPressed: () {
              final logs = PrivateChatLogger.logs.join('\n');
              Clipboard.setData(ClipboardData(text: logs));
              ToastProvider.success('日志已复制到剪贴板');
            },
            tooltip: '复制全部日志',
          ),
          IconButton(
            icon: Icon(Icons.delete_sweep_outlined, size: 22.sp),
            onPressed: () {
              PrivateChatLogger.clear();
              setState(() {});
              ToastProvider.success('日志已清空');
            },
            tooltip: '清空日志',
          ),
        ],
      ),
      body: Column(
        children: [
          // 状态栏
          _buildStatusBar(context),
          // 过滤器
          _buildFilterBar(context),
          // 日志列表
          Expanded(child: _buildLogList(context)),
        ],
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    final provider = context.watch<PrivateChatProvider>();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: WpyTheme.of(context)
            .get(WpyColorKey.secondaryBackgroundColor),
        border: Border(
          bottom: BorderSide(
            color: WpyTheme.of(context)
                .get(WpyColorKey.lightBorderColor)
                .withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          _statusChip(
            'WebSocket',
            provider.isConnected,
            provider.isConnected ? '已连接' : '未连接',
          ),
          SizedBox(width: 12.w),
          _statusChip(
            'UserID',
            provider.myUserId != null,
            provider.myUserId?.toString() ?? '未设置',
          ),
          const Spacer(),
          Text(
            '${PrivateChatLogger.logs.length} 条日志',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, bool active, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF4CAF50).withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: active
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? const Color(0xFF4CAF50) : Colors.red,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: active ? const Color(0xFF2E7D32) : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 34.h,
              child: TextField(
                onChanged: (val) => setState(() => _filter = val),
                decoration: InputDecoration(
                  hintText: '过滤日志...',
                  hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, size: 18.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: TextStyle(fontSize: 13.sp),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // 自动滚动
          GestureDetector(
            onTap: () => setState(() => _autoScroll = !_autoScroll),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _autoScroll
                    ? WpyTheme.of(context)
                        .get(WpyColorKey.primaryActionColor)
                        .withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _autoScroll
                        ? Icons.vertical_align_bottom
                        : Icons.vertical_align_center,
                    size: 16.sp,
                    color: _autoScroll
                        ? WpyTheme.of(context)
                            .get(WpyColorKey.primaryActionColor)
                        : Colors.grey,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '自动滚动',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: _autoScroll
                          ? WpyTheme.of(context)
                              .get(WpyColorKey.primaryActionColor)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 6.w),
          // 刷新
          GestureDetector(
            onTap: () {
              setState(() {});
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _scrollToBottom());
            },
            child: Icon(Icons.refresh, size: 22.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList(BuildContext context) {
    final logs = _filter.isEmpty
        ? PrivateChatLogger.logs
        : PrivateChatLogger.logs
            .where((l) => l.toLowerCase().contains(_filter.toLowerCase()))
            .toList();

    if (logs.isEmpty) {
      return Center(
        child: Text('暂无日志',
            style: TextUtil.base.regular.sp(14).secondary(context)),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return ListView.builder(
      controller: _scrollController,
      itemCount: logs.length,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      itemBuilder: (context, index) {
        final log = logs[index];
        return _buildLogEntry(context, log);
      },
    );
  }

  Widget _buildLogEntry(BuildContext context, String log) {
    // 解析日志颜色
    Color color = Colors.grey[700]!;
    if (log.contains('[HTTP]')) {
      if (log.contains('→')) {
        color = const Color(0xFF1565C0); // 请求蓝
      } else if (log.contains('←')) {
        color = const Color(0xFF2E7D32); // 响应绿
      } else if (log.contains('✖')) {
        color = Colors.red; // 错误红
      }
    } else if (log.contains('[WS]')) {
      color = const Color(0xFF6A1B9A); // WebSocket 紫
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: log));
          ToastProvider.success('已复制');
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: log.contains('✖') || log.contains('ERROR')
                ? Colors.red.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(2.r),
          ),
          child: Text(
            log,
            style: TextStyle(
              fontSize: 11.sp,
              fontFamily: 'monospace',
              color: color,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}
