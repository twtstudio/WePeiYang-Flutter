import 'package:flutter/material.dart' hide SearchDelegate;
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_list_model.dart';
import 'package:wei_pei_yang_demo/lounge/ui/page/search/search_delegate.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/search_model.dart';

class SearchSuggestions extends StatelessWidget {
  final SearchDelegate delegate;

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
  final SearchDelegate<T> delegate;

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
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                onPressed: null,
                child: Text(
                  '历史记录',
                  // style: Provider.of<TextStyle>(context),
                ),
              ),
              Consumer<SearchHistoryModel>(
                builder: (context, model, child) => Visibility(
                    visible: !model.isBusy && !model.isEmpty,
                    child: model.isIdle
                        ? FlatButton.icon(
                            textColor: Color(0xff62677b),
                            onPressed: model.clearHistory,
                            icon: Icon(Icons.clear),
                            label: Text('清空'))
                        : FlatButton.icon(
                            textColor: Color(0xff62677b),
                            onPressed: model.initData,
                            icon: Icon(Icons.refresh),
                            label: Text('重试'))),
              ),
            ],
          ),
        ),
        SearchSuggestionStateWidget<SearchHistoryModel, String>(
          builder: (context, item) => ActionChip(
            backgroundColor: Colors.white,
            label: Text(
              item,
              style: TextStyle(
                fontSize: 8,
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
