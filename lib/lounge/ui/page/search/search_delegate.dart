import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/util/font_manager.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';
import 'package:wei_pei_yang_demo/lounge/model/search_entry.dart';
import 'package:wei_pei_yang_demo/lounge/service/images.dart';
import 'package:wei_pei_yang_demo/lounge/ui/page/search/search_result.dart';
import 'package:wei_pei_yang_demo/lounge/ui/page/search/search_suggestion.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/search_model.dart';

Future<T> customShowSearch<T>({
  @required BuildContext context,
  @required MySearchDelegate<T> delegate,
  String query = '',
}) {
  assert(delegate != null);
  assert(context != null);
  delegate.query = query ?? delegate.query;
  delegate._currentBody = _SearchBody.suggestions;
  return Navigator.of(context).push(_MySearchPageRoute<T>(
    delegate: delegate,
  ));
}

class SRSearchDelegate extends MySearchDelegate<HistoryEntry> {
  SearchHistoryModel _searchHistoryModel = SearchHistoryModel();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(
          Icons.clear,
          color: Color(0x8862677c),
        ),
        onPressed: () {
          _focusNode.requestFocus();
          _queryTextController.clear();
        },
        padding: EdgeInsets.all(0),
      ),
      TextButton(
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: MaterialStateProperty.all(Size(0, 0)),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
        ),
        onPressed: () {
          query.trim().isNotEmpty ? showResults(context) : close(context, null);
        },
        child: Text(
          query.trim().isNotEmpty ? S.current.search : S.current.cancel,
          style: FontManager.YaQiHei.copyWith(
            color: Color(0xff62677c),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return Image(
      image: AssetImage(Images.search),
      width: 20,
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().length > 0) {
      return SearchResult(
        query: query,
        searchHistoryModel: _searchHistoryModel,
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        close(context, null);
      });
      return SizedBox.shrink();
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SearchHistoryModel>.value(
            value: _searchHistoryModel)
      ],
      child: SearchSuggestions(delegate: this),
    );
  }
}

abstract class MySearchDelegate<T> {
  MySearchDelegate({
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

  _MySearchPageRoute<T> _route;
}

enum _SearchBody {
  suggestions,
  results,
}

class _MySearchPageRoute<T> extends PageRoute<T> {
  _MySearchPageRoute({
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

  final MySearchDelegate<T> delegate;

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
    return _MySearchPage<T>(
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

class _MySearchPage<T> extends StatefulWidget {
  const _MySearchPage({
    this.delegate,
    this.animation,
  });

  final MySearchDelegate<T> delegate;
  final Animation<double> animation;

  @override
  State<StatefulWidget> createState() => _MySearchPageState<T>();
}

class _MySearchPageState<T> extends State<_MySearchPage<T>> {
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
  void didUpdateWidget(_MySearchPage<T> oldWidget) {
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
    // final TextStyle searchFieldStyle = widget.delegate.searchFieldStyle ??
    //     theme.inputDecorationTheme.hintStyle;
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            color: Colors.transparent,
            child: SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  CustomSingleChildLayout(
                    delegate: _ToolbarContainerLayout(40),
                    child: NavigationToolbar(
                      centerMiddle: false,
                      middleSpacing: 30,
                      leading: widget.delegate.buildLeading(context),
                      middle: TextField(
                        controller: widget.delegate._queryTextController,
                        focusNode: focusNode,
                        style: TextStyle(
                          color: Color(0xff363c54),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        textInputAction: widget.delegate.textInputAction,
                        keyboardType: widget.delegate.keyboardType,
                        onSubmitted: (String _) {
                          widget.delegate.showResults(context);
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          // hintText: '请输入',
                          // hintStyle: TextStyle(
                          //   color: Color(0x77363c54),
                          //   fontSize: 14,
                          //   fontWeight: FontWeight.normal,
                          // ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: widget.delegate.buildActions(context),
                      ),
                    ),
                  ),
                  Container(
                    height: 0.6,
                    color: Color(0xff303c66),
                  )
                ]),
              ),
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus.unfocus();
            }
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: body,
          ),
        ),
      ),
    );
  }
}

class _ToolbarContainerLayout extends SingleChildLayoutDelegate {
  const _ToolbarContainerLayout(this.toolbarHeight);

  final double toolbarHeight;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.tighten(height: toolbarHeight);
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, toolbarHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height);
  }

  @override
  bool shouldRelayout(_ToolbarContainerLayout oldDelegate) =>
      toolbarHeight != oldDelegate.toolbarHeight;
}
