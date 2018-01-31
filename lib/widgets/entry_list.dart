import 'dart:collection';
import 'dart:math';
import 'package:redux/redux.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:yjournal/app_keys.dart';
import 'package:yjournal/models.dart';
import 'package:yjournal/selectors.dart';
import 'package:yjournal/actions.dart';
import 'package:yjournal/screens/detail_page.dart';
import 'package:yjournal/widgets/monthly_picker.dart';

class EntryList extends StatelessWidget {
  final ScrollController scrollController;
  final PageController pageController;

  EntryList({
    Key key,
    @required this.pageController,
    @required this.scrollController
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new StoreConnector(
      converter: _ViewModel.fromStore,
      builder: (context, vm) {
        return new _View(
          scrollController: scrollController,
          isLoading: vm.isLoading,
          selectedDate: vm.selectedDate,
          entries: vm.entries,
          onDismissed: vm.onDismissed,
          onEntryPressed: (Entry entry) async {
            Entry e = await Navigator.of(context).push(
                new MaterialPageRoute(builder: (_) =>
                new DetailPage(title: 'Edit Entry',
                    id: entry.id,
                    date: entry.date,
                    text: entry.text)
                )
            );
            if (e != null) {
              pageController.jumpToPage(MonthlyPicker.dateTimeToIndex(e.date));
            }
            vm.onEntryPressed(e);
          },
        );
      },
    );
  }
}

class _ViewModel {
  final bool isLoading;
  final SplayTreeMap<DateTime, List<Entry>> entries;
  final DateTime selectedDate;
  final DismissEntryCallback onDismissed;
  final EditEntryCallback onEntryPressed;

  _ViewModel({
    @required this.isLoading,
    @required this.entries,
    @required this.selectedDate,
    @required this.onDismissed,
    @required this.onEntryPressed,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return new _ViewModel(
      isLoading: isLoadingSelector(store.state),
      entries: dateMappedEntriesSelector(store.state),
      selectedDate: selectedDateSelector(store.state),
      onDismissed: (direction, id) => store.dispatch(new RemoveEntryAction(id)),
      onEntryPressed: (Entry entry) {
        if (entry != null) {
          store.dispatch(new UpdateSelectedDateAction(entry.date));
          store.dispatch(new EditEntryAction(entry.id, entry));
        }
      },
    );
  }
}

class _View extends StatelessWidget {
  final SplayTreeMap<DateTime, List<Entry>> entries;
  final bool isLoading;
  final DateTime selectedDate;
  final DismissEntryCallback onDismissed;
  final ScrollController scrollController;
  final EditEntryCallback onEntryPressed;

  _View({
    Key key,
    @required this.entries,
    @required this.isLoading,
    @required this.selectedDate,
    @required this.onDismissed,
    @required this.scrollController,
    @required this.onEntryPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    if (isLoading) return new Center(child: new CircularProgressIndicator(value: null));

    if (entries.isEmpty) return new Column(children: <Widget>[
      new ListTile(title: const Text('No entries... yet'), dense: true)
    ]);

    return new ListView.builder(
      shrinkWrap: true,
      controller: scrollController,
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {

        List<Widget> list = [];
        DateTime date = entries.keys.toList().reversed.toList()[index];
        final List<Entry> dateEntries = entries[date];
        list.add(new Divider());
        list.add(new Container(
            key: new Key('__entrylist' + date.toIso8601String() + '__'),
            margin: const EdgeInsetsDirectional.only(start: 16.0),
            //need to change this to a DateFormat from intl package
            child: new Text('${date.day}/${date.month}/${date.year}',
                style: themeData.textTheme.body2.copyWith(
                    color: themeData.accentColor))
        ));
        dateEntries.forEach((entry) =>
            list.add(
                new Dismissible(
                    key: AppKeys.entry(entry.id.toString()),
                    onDismissed: (direction) {
                      onDismissed(direction, entry.id);
                    },
                    child: new ListTile(
                        key: AppKeys.entryListTile(entry.id.toString()),
                        title: new Text(
                          entry.text.indexOf('\n') > -1 ?
                            (entry.text.substring(0, min(30, entry.text.indexOf('\n')))
                              + (entry.text.indexOf('\n') > 30 ? '...' : '')):
                            (entry.text.substring(0, min(30, entry.text.length))
                              + (entry.text.length > 30 ? '...' : ''))
                        ),
                        subtitle: new Text(
                          //if there's a newline and the second line is long enough
                          entry.text.indexOf('\n') > -1 && entry.text.length - entry.text.indexOf('\n') > 1 ?
                            entry.text.substring(entry.text.indexOf('\n')+1, min(entry.text.indexOf('\n')+31, entry.text.length))
                              + (entry.text.length > entry.text.indexOf('\n') + 31 ? '...' : '') :
                            ' '
                        ),
                        isThreeLine: false,
                        dense: true,
                      onTap: () => onEntryPressed(entry),
                    ),
                    background: new Container(
                        color: Colors.red,
                        child: new ListTile(
                            dense: true
                        )
                    )
                )
            )
        );
        return new Column(
            key: new Key(date.toIso8601String()),
            children: list
        );
      },
    );
  }
}