import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/util/font_manager.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';
import 'package:wei_pei_yang_demo/lounge/service/images.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_model.dart';
import 'package:wei_pei_yang_demo/lounge/ui/page/search/search_delegate.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/search_model.dart';

class SearchSuggestions extends StatelessWidget {
  final MySearchDelegate delegate;

  SearchSuggestions({@required this.delegate});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.maxWidth,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: SearchHistoriesWidget(delegate: delegate),
            ),
          ),
        );
      },
    );
  }
}

class SearchHistoriesWidget<T> extends StatefulWidget {
  final MySearchDelegate<T> delegate;

  SearchHistoriesWidget({@required this.delegate, key}) : super(key: key);

  @override
  _SearchHistoriesWidgetState createState() => _SearchHistoriesWidgetState();
}

class _SearchHistoriesWidgetState extends State<SearchHistoriesWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      Provider.of<SearchHistoryModel>(context, listen: false).initData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Consumer<SearchHistoryModel>(
          builder: (context, model, child) => Visibility(
            visible: !model.isBusy && !model.isEmpty,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                  onPressed: null,
                  child: Text(
                    S.current.searchHistory,
                    style: FontManager.YaQiHei.copyWith(
                        color: Color(0xff62677c),
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
                InkWell(
                  onTap: () async => await model.clearHistory(),
                  child: Container(
                    width: 40,
                    height: 30,
                    alignment: Alignment.center,
                    child: Image(
                      image: AssetImage(Images.crash),
                      width: 17,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SearchSuggestionStateWidget<SearchHistoryModel, String>(
          builder: (context, item) => ActionChip(
            elevation: 0.5,
            backgroundColor: Colors.white,
            label: Text(
              item,
              style: FontManager.YaHeiRegular.copyWith(
                fontSize: 12,
                color: Color(0xff62677b),
              ),
            ),
            onPressed: () {
              widget.delegate.query = item;
              widget.delegate.showResults(context);
            },
          ),
        ),
      ],
    );
  }
}

class SearchSuggestionStateWidget<T extends ViewStateListModel, E>
    extends StatelessWidget {
  final Widget Function(BuildContext context, E data) builder;

  SearchSuggestionStateWidget({@required this.builder});

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (context, model, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: model.isIdle
            ? Wrap(
                alignment: WrapAlignment.start,
                spacing: 10,
                children: List.generate(model.list.length, (index) {
                  E item = model.list[index];
                  return builder(context, item);
                }),
              )
            : Container(),
      ),
    );
  }
}
