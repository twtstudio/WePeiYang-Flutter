import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:we_pei_yang_flutter/commons/util/text_util.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';

/// 统一Button样式
class WpyPic extends StatefulWidget {
  WpyPic(this.res,
      {Key key, this.withHolder, this.width, this.height, this.fit})
      : super(key: key);

  final String res;
  final double width;
  final double height;
  BoxFit fit = BoxFit.contain;
  bool withHolder = false;

  @override
  _WpyPicState createState() => _WpyPicState();
}

class _WpyPicState extends State<WpyPic> {
  @override
  Widget build(BuildContext context) {
    return widget.res.startsWith('assets')
        ? widget.res.endsWith('.svg')
            ? SvgPicture.asset(
                widget.res,
                width: widget.width,
                height: widget.height,
                fit: widget.fit,
              )
            : Image.asset(
                widget.res,
                width: widget.width,
                height: widget.height,
                fit: widget.fit,
              )
        : widget.res.endsWith('.svg')
            ? SvgPicture.network(widget.res,
                width: widget.width,
                height: widget.height,
                fit: widget.fit,
                placeholderBuilder:
                    widget.withHolder ? (BuildContext ctx) => Loading() : null)
            : Image.network(
                widget.res,
                width: widget.width,
                height: widget.height,
                fit: widget.fit,
                loadingBuilder: widget.withHolder
                    ? (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 40,
                          width: double.infinity,
                          padding: EdgeInsets.all(4),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes
                                  : null,
                            ),
                          ),
                        );
                      }
                    : null,
                errorBuilder: widget.withHolder
                    ? (BuildContext context, Object exception,
                        StackTrace stackTrace) {
                        return Text(
                          '💔[图片加载失败]',
                          style: TextUtil.base.grey6C.w400.sp(12),
                        );
                      }
                    : null,
              );
  }
}
