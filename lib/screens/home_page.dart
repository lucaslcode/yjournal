import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:yjournal/models.dart';
import 'package:yjournal/actions.dart';
import 'package:yjournal/widgets/monthly_picker.dart';
import 'package:yjournal/widgets/entry_list.dart';
import 'package:yjournal/screens/detail_page.dart';



class HomePage extends StatefulWidget {
  HomePage(this.title);

  final String title;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime viewingMonth = new DateTime.now();
  ScrollController scrollController = new ScrollController();

  SplayTreeMap<DateTime, List<Entry>> entriesMap(List<Entry> entries) {
    SplayTreeMap<DateTime, List<Entry>> entriesMap = new SplayTreeMap((key1, key2) => key1.compareTo(key2));
    if (entries == null || entries.isEmpty) return entriesMap;
    entries.forEach((entry) {
      if (!entriesMap.containsKey(entry.date)) { entriesMap[entry.date] = [entry]; }
      else { entriesMap[entry.date].add(entry); }
    });
    return entriesMap;
  }

  _onDateChange(Store<AppState> store, DateTime newDate) {
    setState(() => store.dispatch(new UpdateSelectedDateAction(newDate)));
    //below is num of date headers before selected date
    int i = entriesMap(store.state.entries).keys.toList().reversed.toList().indexOf(newDate);
    //below is num of entries before the selected date
    int j = -1;
    if (i > -1) j = entriesMap(store.state.entries).values.toList().reversed.toList().sublist(0,i).fold<int>(0, (int value, List<Entry> e) => value + e.length);
    if (j > -1) scrollController.animateTo(i*32.0+j*60.0, duration: new Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  _onViewingMonthChange(DateTime newMonth) {
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
          isLoading: store.state.isLoading,
          entries: entriesMap(store.state.entries),
          selectedDate: store.state.selectedDate,
          filledSelectedDates: store.state.entries.map((e) {
            if (e.date.year == viewingMonth.year &&
            e.date.month == viewingMonth.month) return e.date.day;
            }).toList(),
          onDateChange: (newDate) { _onDateChange(store, newDate); },
          onAddPressed: () async {
            Entry e = await Navigator.of(context).push(
              new MaterialPageRoute(builder: (_) =>
                new DetailPage(title: 'New Entry', id: null, date: new DateTime(store.state.selectedDate.year, store.state.selectedDate.month, store.state.selectedDate.day), text: '')
              )
            );
            if (e != null) store.dispatch(new AddEntryAction(e));
          },
          onDismissed: (direction, id) => store.dispatch(new RemoveEntryAction(id)),
          viewingMonth: viewingMonth,
          onViewingMonthChange: _onViewingMonthChange,
          scrollController: scrollController,
          onEntryPressed: (Entry entry) async {
            _onDateChange(store, entry.date);
            _onViewingMonthChange(entry.date);
            Entry e = await Navigator.of(context).push(
              new MaterialPageRoute(builder: (_) =>
                new DetailPage(title: 'Edit Entry', id: entry.id, date: entry.date, text: entry.text)
              )
            );
            if (e != null) store.dispatch(new EditEntryAction(entry.id, e));
          },
        )
      );
  }
}

class _HomePageView extends StatelessWidget {
  final String title;
  final bool isLoading;
  final SplayTreeMap<DateTime, List<Entry>> entries;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChange;
  final VoidCallback onAddPressed;
  final DismissEntryCallback onDismissed;
  final DateTime viewingMonth;
  final ValueChanged<DateTime> onViewingMonthChange;
  final List<int> filledSelectedDates;
  final ScrollController scrollController;
  final EditEntryCallback onEntryPressed;

  _HomePageView({
    @required this.title,
    @required this.isLoading,
    @required this.entries,
    @required this.selectedDate,
    @required this.filledSelectedDates,
    @required this.onDateChange,
    @required this.onAddPressed,
    @required this.onDismissed,
    @required this.viewingMonth,
    @required this.onViewingMonthChange,
    @required this.scrollController,
    @required this.onEntryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: onAddPressed,
        child: new Icon(Icons.add)
      ),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: isLoading ?
            /// TODO: Fix the alignment of this indicator. A blank MonthlyPicker would also look better here.
        <Widget>[new CircularProgressIndicator(value: null)] :
        <Widget>[
          new MonthlyPicker(key: new Key('__mainpicker__'), currentDate: new DateTime.now(), selectedDate: selectedDate, viewingMonth: viewingMonth, onDateChange: onDateChange, filledDates: filledSelectedDates, onViewingMonthChange: onViewingMonthChange),
          new Expanded(key: new Key('__mainentrylist__'),
              child: new EntryList(
                  entries: entries,
                  selectedDate: selectedDate, onDismissed: onDismissed, scrollController: scrollController, onEntryPressed: onEntryPressed)),
        ],
      ),
    );
  }
}
