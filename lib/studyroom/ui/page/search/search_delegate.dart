import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/studyroom/model/search_history.dart';
import 'package:wei_pei_yang_demo/studyroom/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/studyroom/ui/page/search/search_result.dart';

Future<T> showASearch<T>({
  @required BuildContext context,
  @required SearchDelegate<T> delegate,
  String query = '',
}) {
  assert(delegate != null);
  assert(context != null);
  delegate.query = query ?? delegate.query;
  delegate._currentBody = _SearchBody.suggestions;
  return Navigator.of(context).push(_ASearchPageRoute<T>(
    delegate: delegate,
  ));
}

class StudyRoomSearchDelegate extends SearchDelegate<SearchHistory> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    var theme = Theme.of(context);
    return super.appBarTheme(context).copyWith(
        primaryColor: theme.scaffoldBackgroundColor,
        primaryColorBrightness: theme.brightness);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton(
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length > 0) {
      return SearchResult(
        keyWord: query,
      );
    }
    return SizedBox.shrink();
  }

  var _loadData = HiveManager.getSearchHistory();

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: _loadData,
      builder:
          (BuildContext context, AsyncSnapshot<List<SearchHistory>> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('no history'),
          );
        }
        print('query : ' + query);

        List<String> querys = [];

        var q1 = query.split(RegExp(r'[\u4e00-\u9fa5\s]'));
        for (var q in q1) {
          if (q.contains(RegExp(r'[A-Za-z]'))) {
            var area = RegExp(r'[A-Za-z]')
                .allMatches(q)
                .map((e) => e.group(0))
                .toList();
            querys.addAll(area);
            var q2 = q.split(RegExp(r'[A-Za-z]'));
            for (var w in q2) {
              if (w.isNotEmpty) {
                if (w.length > 3) {
                  var i1 = w.substring(0, 2);
                  var i2 = w.substring(2, 5);
                  querys.add(i1);
                  querys.add(i2);
                } else {
                  querys.add(w);
                }
              }
              ;
            }
          } else if (q.isNotEmpty) {
            if (q.length > 3) {
              var i1 = q.substring(0, 2);
              var i2 = q.substring(2, 5);
              querys.add(i1);
              querys.add(i2);
            } else {
              querys.add(q);
            }
          }
        }

        var orderedQuerys = {};

        for (var q in querys) {
          print(
              'q: ' + q + '=' + RegExp(r'^[1-9][0-9]$').hasMatch(q).toString());
          if (RegExp(r'[A-Za-z]').hasMatch(q)) {
            if (orderedQuerys['aName'] == null) {
              orderedQuerys['aName'] = q;
            } else {
              print('教学楼具体区域不明确');
            }
          }
          if (RegExp(r'^[1-9][0-9]{0,1}$').hasMatch(q)) {
            if (orderedQuerys['bName'] == null) {
              orderedQuerys['bName'] = q;
            } else if (orderedQuerys['bName'] != null && q.length == 1) {
              print('教学楼不明确,猜测是教室开头（楼层）');
              orderedQuerys['cName'] = q;
            } else {
              print('教学楼不明确');
            }
          }
          if (RegExp(r'^[1-9][0-9]{2}$').hasMatch(q)) {
            if (orderedQuerys['cName'] == null) {
              orderedQuerys['cName'] = q;
            } else {
              print('具体教室不明确');
            }
          }
        }

        print('querys : ' + querys.toString());
        print('orderedQuerys : ' + orderedQuerys.toString());

        List<SearchHistory> result = [];

        String aId = orderedQuerys['aName'] ?? '';
        var bId = orderedQuerys['bName'] ?? '';
        var cId = orderedQuerys['cName'] ?? '';

        result = snapshot.data
            .where((h) =>
                h.bName.contains(bId) &&
                h.aId.toLowerCase().contains(aId.toLowerCase()) &&
                h.cName.contains(cId))
            .toList();

        print('result : ' + result.toString());

        return ListView(
          children: result
              .map<ListTile>((e) => ListTile(
                    title: Text(
                      getTitle(e),
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(fontSize: 16),
                    ),
                    onTap: () {
                      close(context, e);
                    },
                  ))
              .toList(),
        );
      },
    );
  }
}

abstract class SearchDelegate<T> {
  SearchDelegate({
    this.searchFieldLabel,
    this.searchFieldStyle,
    this.keyboardType,
    this.textInputAction = TextInputAction.search,
  });

  Widget buildSuggestions(BuildContext context);

  Widget buildResults(BuildContext context);

  Widget buildLeading(BuildContext context);

  List<Widget> buildActions(BuildContext context);

  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme.copyWith(
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryColorBrightness: Brightness.light,
      primaryTextTheme: theme.textTheme,
    );
  }

  String get query => _queryTextController.text;

  set query(String value) {
    assert(query != null);
    _queryTextController.text = value;
  }

  void showResults(BuildContext context) {
    _focusNode?.unfocus();
    _currentBody = _SearchBody.results;
  }

  void showSuggestions(BuildContext context) {
    assert(_focusNode != null,
        '_focusNode must be set by route before showSuggestions is called.');
    _focusNode.requestFocus();
    _currentBody = _SearchBody.suggestions;
  }

  void close(BuildContext context, T result) {
    _currentBody = null;
    _focusNode?.unfocus();
    Navigator.of(context)
      ..popUntil((Route<dynamic> route) => route == _route)
      ..pop(result);
  }

  final String searchFieldLabel;

  final TextStyle searchFieldStyle;

  final TextInputType keyboardType;

  final TextInputAction textInputAction;

  Animation<double> get transitionAnimation => _proxyAnimation;

  FocusNode _focusNode;

  final TextEditingController _queryTextController = TextEditingController();

  final ProxyAnimation _proxyAnimation =
      ProxyAnimation(kAlwaysDismissedAnimation);

  final ValueNotifier<_SearchBody> _currentBodyNotifier =
      ValueNotifier<_SearchBody>(null);

  _SearchBody get _currentBody => _currentBodyNotifier.value;

  set _currentBody(_SearchBody value) {
    _currentBodyNotifier.value = value;
  }

  _ASearchPageRoute<T> _route;
}

enum _SearchBody {
  suggestions,
  results,
}

class _ASearchPageRoute<T> extends PageRoute<T> {
  _ASearchPageRoute({
    @required this.delegate,
  }) : assert(delegate != null) {
    assert(
      delegate._route == null,
      'The ${delegate.runtimeType} instance is currently used by another active '
      'search. Please close that search by calling close() on the SearchDelegate '
      'before opening another search with the same delegate instance.',
    );
    delegate._route = this;
  }

  final SearchDelegate<T> delegate;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => false;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  Animation<double> createAnimation() {
    final Animation<double> animation = super.createAnimation();
    delegate._proxyAnimation.parent = animation;
    return animation;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _SearchPage<T>(
      delegate: delegate,
      animation: animation,
    );
  }

  @override
  void didComplete(T result) {
    super.didComplete(result);
    assert(delegate._route == this);
    delegate._route = null;
    delegate._currentBody = null;
  }
}

class _SearchPage<T> extends StatefulWidget {
  const _SearchPage({
    this.delegate,
    this.animation,
  });

  final SearchDelegate<T> delegate;
  final Animation<double> animation;

  @override
  State<StatefulWidget> createState() => _SearchPageState<T>();
}

class _SearchPageState<T> extends State<_SearchPage<T>> {
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.delegate._queryTextController.addListener(_onQueryChanged);
    widget.animation.addStatusListener(_onAnimationStatusChanged);
    widget.delegate._currentBodyNotifier.addListener(_onSearchBodyChanged);
    focusNode.addListener(_onFocusChanged);
    widget.delegate._focusNode = focusNode;
  }

  @override
  void dispose() {
    super.dispose();
    widget.delegate._queryTextController.removeListener(_onQueryChanged);
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    widget.delegate._currentBodyNotifier.removeListener(_onSearchBodyChanged);
    widget.delegate._focusNode = null;
    focusNode.dispose();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    if (widget.delegate._currentBody == _SearchBody.suggestions) {
      focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(_SearchPage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.delegate != oldWidget.delegate) {
      oldWidget.delegate._queryTextController.removeListener(_onQueryChanged);
      widget.delegate._queryTextController.addListener(_onQueryChanged);
      oldWidget.delegate._currentBodyNotifier
          .removeListener(_onSearchBodyChanged);
      widget.delegate._currentBodyNotifier.addListener(_onSearchBodyChanged);
      oldWidget.delegate._focusNode = null;
      widget.delegate._focusNode = focusNode;
    }
  }

  void _onFocusChanged() {
    if (focusNode.hasFocus &&
        widget.delegate._currentBody != _SearchBody.suggestions) {
      widget.delegate.showSuggestions(context);
    }
  }

  void _onQueryChanged() {
    setState(() {
      // rebuild ourselves because query changed.
    });
  }

  void _onSearchBodyChanged() {
    setState(() {
      // rebuild ourselves because search body changed.
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final ThemeData theme = widget.delegate.appBarTheme(context);
    final String searchFieldLabel = widget.delegate.searchFieldLabel ??
        MaterialLocalizations.of(context).searchFieldLabel;
    final TextStyle searchFieldStyle = widget.delegate.searchFieldStyle ??
        theme.inputDecorationTheme.hintStyle;
    Widget body;
    switch (widget.delegate._currentBody) {
      case _SearchBody.suggestions:
        body = KeyedSubtree(
          key: const ValueKey<_SearchBody>(_SearchBody.suggestions),
          child: widget.delegate.buildSuggestions(context),
        );
        break;
      case _SearchBody.results:
        body = KeyedSubtree(
          key: const ValueKey<_SearchBody>(_SearchBody.results),
          child: widget.delegate.buildResults(context),
        );
        break;
    }
    String routeName;
    switch (theme.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        routeName = '';
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        routeName = searchFieldLabel;
    }

    return Semantics(
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: true,
      label: routeName,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.primaryColor,
          iconTheme: theme.primaryIconTheme,
          textTheme: theme.primaryTextTheme,
          brightness: theme.primaryColorBrightness,
          leading: widget.delegate.buildLeading(context),
          title: TextField(
            controller: widget.delegate._queryTextController,
            focusNode: focusNode,
            style: theme.textTheme.headline6,
            textInputAction: widget.delegate.textInputAction,
            keyboardType: widget.delegate.keyboardType,
            onSubmitted: (String _) {
              widget.delegate.showResults(context);
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: searchFieldLabel,
              hintStyle: searchFieldStyle,
            ),
          ),
          actions: widget.delegate.buildActions(context),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: body,
        ),
      ),
    );
  }
}
