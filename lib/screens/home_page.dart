import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:yjournal/models.dart';
import 'package:yjournal/widgets/add_fab.dart';
import 'package:yjournal/widgets/monthly_picker.dart';
import 'package:yjournal/widgets/entry_list.dart';



class HomePage extends StatefulWidget {
  HomePage(this.title);

  final String title;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime viewingMonth = new DateTime.now();
  ScrollController scrollController = new ScrollController();

  onViewingMonthChange(DateTime newMonth) {
    setState(() => viewingMonth = newMonth);
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, Store<AppState>>(
      /// TODO: This converter should convert to a viewmodel, not just return itself.
      converter: (store) => store,
      builder: (context, store) =>
        new _HomePageView(
          title: widget.title,
          viewingMonth: viewingMonth,
          onViewingMonthChange: onViewingMonthChange,
          scrollController: scrollController,
        )
      );
  }
}

class _HomePageView extends StatelessWidget {
  final String title;
  final DateTime viewingMonth;
  final ValueChanged<DateTime> onViewingMonthChange;
  final ScrollController scrollController;

  _HomePageView({
    @required this.title,
    @required this.viewingMonth,
    @required this.onViewingMonthChange,
    @required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      floatingActionButton: new AddFab(),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new MonthlyPicker(
              key: new Key('__mainpicker__'),
              currentDate: new DateTime.now(),
              viewingMonth: viewingMonth,
              onViewingMonthChange: onViewingMonthChange,
              scrollController: scrollController
          ),
          new Expanded(
              key: new Key('__mainentrylist__'),
              child: new EntryList(
                  scrollController: scrollController,
                  onViewingMonthChange: onViewingMonthChange
              )
          ),
        ],
      ),
    );
  }
}
