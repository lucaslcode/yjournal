import 'package:redux/redux.dart';

import 'package:yjournal/models.dart';
import 'package:yjournal/actions.dart';
import 'package:yjournal/data_source.dart';

List<Middleware<AppState>> createMiddleware(final int dataSourceVersion) {
  final DataSource dataSource = new DataSource(dataSourceVersion);

  final loadEntries = _createLoadEntries(dataSource);
  final addEntry = _createAddEntry(dataSource);
  final editEntry = _createEditEntry(dataSource);
  final removeEntry = _createRemoveEntry(dataSource);
  
  return combineTypedMiddleware([
    new MiddlewareBinding<AppState, LoadEntriesAction>(loadEntries),
    new MiddlewareBinding<AppState, AddEntryAction>(addEntry),
    new MiddlewareBinding<AppState, EditEntryAction>(editEntry),
    new MiddlewareBinding<AppState, RemoveEntryAction>(removeEntry),
  ]);
}

Middleware<AppState> _createLoadEntries(DataSource dataSource) {
  return (Store<AppState> store, LoadEntriesAction action, NextDispatcher next) {
    dataSource.initialise().then((_) => dataSource.loadEntries())
      .then(
        (entries) {
          store.dispatch(new EntriesLoadedAction(entries));
        }
      ).catchError(
        (error) {
          store.dispatch(new EntriesNotLoadedAction(error));
        }
      );
    next(action);
  };
}

Middleware<AppState> _createAddEntry(DataSource dataSource) {
  return (Store<AppState> store, AddEntryAction action, NextDispatcher next) {
    next(action);
    dataSource.addEntry(action.entry).catchError(
        (error) {
          print(error);
        }
    );
  };
}

Middleware<AppState> _createEditEntry(DataSource dataSource) {
  return (Store<AppState> store, EditEntryAction action, NextDispatcher next) {
    next(action);
    dataSource.editEntry(action.id, action.entry).catchError(
        (error) {
          print(error);
        }
    );
  };
}

Middleware<AppState> _createRemoveEntry(DataSource dataSource) {
  return (Store<AppState> store, RemoveEntryAction action, NextDispatcher next) {
    next(action);
    dataSource.removeEntry(action.id).catchError(
        (error) {
          print(error);
        }
    );
  };
}