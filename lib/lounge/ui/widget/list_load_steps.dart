import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_list_model.dart';
import 'package:wei_pei_yang_demo/lounge/ui/widget/loading.dart';

class ListLoadSteps<T extends ViewStateListModel> extends StatelessWidget {
  final T model;
  final Widget busyV;
  final Widget errorV;
  final Widget emptyV;
  final Widget successV;
  final Widget defaultV;
  final double errorHeight;

  const ListLoadSteps(
      {Key key,
      @required this.model,
      this.busyV,
      this.errorV,
      this.emptyV,
      this.successV,
      this.defaultV,
      this.errorHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (model.isBusy) {
      body = KeyedSubtree(
          key: const ValueKey<ViewState>(ViewState.busy),
          child: busyV ??
              Container(
                height: errorHeight ?? 200.0,
                child: Center(
                  child: Loading(),
                ),
              ));
    } else if (model.isError && model.list.isEmpty) {
      body = KeyedSubtree(
        key: const ValueKey<ViewState>(ViewState.error),
        child: errorV ?? Container(),
      );
    } else if (model.isEmpty) {
      body = KeyedSubtree(
        key: const ValueKey<ViewState>(ViewState.empty),
        child: emptyV ?? Container(),
      );
    } else if (model.isIdle && model.list.isNotEmpty) {
      body = KeyedSubtree(
        key: const ValueKey<ViewState>(ViewState.idle),
        child: successV ?? Container(),
      );
    } else {
      body = defaultV ?? Container();
    }
    return AnimatedSwitcher(
      layoutBuilder: (Widget currentChild, List<Widget> previousChildren){
        return Stack(
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
          alignment: Alignment.topCenter,
        );
      },
      duration: const Duration(milliseconds: 300),
      child: body,
    );
  }
}
