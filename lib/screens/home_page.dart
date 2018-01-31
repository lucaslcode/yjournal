import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:yjournal/app_keys.dart';
import 'package:yjournal/models.dart';
import 'package:yjournal/widgets/add_fab.dart';
import 'package:yjournal/widgets/monthly_picker.dart';
import 'package:yjournal/widgets/entry_list.dart';

const int _firstDate = 1980;

class HomePage extends StatefulWidget {
  final String title;

  HomePage({Key key, this.title}) : super(key: key);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController scrollController = new ScrollController();
  ///TODO: Remove this hack, the firstdate const should be somewhere sane and DateTime.now() should come from redux state
  PageController pageController = new PageController(initialPage: MonthlyPicker.monthDelta(new DateTime(1980), new DateTime.now()));

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, Store<AppState>>(
      /// TODO: This converter should convert to a viewmodel, not just return itself.
      converter: (store) => store,
      builder: (context, store) =>
        new _HomePageView(
          title: widget.title,
          scrollController: scrollController,
          pageController: pageController,
        )
      );
  }
}

class _HomePageView extends StatelessWidget {
  final String title;
  final ScrollController scrollController;
  final PageController pageController;

  _HomePageView({
    @required this.title,
    @required this.scrollController,
    @required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      floatingActionButton: new AddFab(key: AppKeys.addFab),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new MonthlyPicker(
              key: AppKeys.monthlyPicker,
              currentDate: new DateTime.now(),
              scrollController: scrollController,
              pageController: pageController,
          ),
          new Expanded(
              child: new EntryList(
                  key: AppKeys.entryList,
                  scrollController: scrollController,
                  pageController: pageController,
              )
          ),
        ],
      ),
    );
  }
}
