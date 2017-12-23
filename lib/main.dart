import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:yjournal/models.dart';
import 'package:yjournal/reducers.dart';
import 'package:yjournal/actions.dart';
import 'package:yjournal/middleware.dart';
import 'package:yjournal/screens/home_page.dart';

const VERSION = '0.1.0';
const DBVERSION = 2;

void main() {
  runApp(new App());
}

class App extends StatelessWidget {

  final store = new Store<AppState>(
    appReducer,
    middleware: createMiddleware(DBVERSION),
    initialState: new AppState.loading(
        selectedDate:new DateTime.now(),
        entries: []
    )
  );

  @override
  Widget build(BuildContext context) {
    return new StoreProvider(
      store: store,
      child: new StoreBuilder<AppState>(
        onInit: (store) {
          store.dispatch(new LoadEntriesAction());
        },
        builder: (context, store) => new MaterialApp(
          title: 'yJournal',
          theme: new ThemeData(
            primarySwatch: Colors.teal,
          ),
          home: new HomePage('yJournal'),
        ),
      ),
    );
  }
}
