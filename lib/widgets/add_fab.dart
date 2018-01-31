import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:yjournal/app_keys.dart';
import 'package:yjournal/models.dart';
import 'package:yjournal/actions.dart';
import 'package:yjournal/selectors.dart';
import 'package:yjournal/screens/detail_page.dart';

class AddFab extends StatelessWidget {
  AddFab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new StoreConnector(
        converter: _ViewModel.fromStore,
        builder: (context, vm) => new _View(
          addEntry: () async {
            Entry e = await Navigator.of(context).push(
              new MaterialPageRoute(builder: (_) =>
                new DetailPage(key: AppKeys.detailPage, title: 'New Entry', id: null, date: new DateTime(vm.selectedDate.year, vm.selectedDate.month, vm.selectedDate.day), text: '')
              )
            );
            if (e != null) vm.addEntry(e);
          },
        ),
    );
  }
}

class _ViewModel {
  final ValueSetter<Entry> addEntry;
  final DateTime selectedDate;

  _ViewModel({@required this.addEntry, @required this.selectedDate});
  static _ViewModel fromStore(Store<AppState> store) {
    return new _ViewModel(
      addEntry: (entry) => store.dispatch(new AddEntryAction(entry)),
      selectedDate: selectedDateSelector(store.state),
    );
  }
}

class _View extends StatelessWidget {
  final VoidCallback addEntry;
  _View({this.addEntry});

  @override
  Widget build(BuildContext context) => new FloatingActionButton(
      onPressed: addEntry,
      child: new Icon(Icons.add)
  );
}