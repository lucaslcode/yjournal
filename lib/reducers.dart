import 'dart:math';
import 'package:redux/redux.dart';

import 'package:yjournal/models.dart';
import 'package:yjournal/actions.dart';

AppState appReducer(AppState state, action) {
  return new AppState(
    selectedDate: selectedDateReducer(state.selectedDate, action),
    entries: entriesReducer(state.entries, action),
    isLoading: isLoadingReducer(state.isLoading, action),
  );
}

final selectedDateReducer = combineTypedReducers([
  new ReducerBinding<DateTime, UpdateSelectedDateAction>(_updateSelectedDate)
]);

final entriesReducer = combineTypedReducers([
  new ReducerBinding<List<Entry>, AddEntryAction>(_addEntry),
  new ReducerBinding<List<Entry>, EditEntryAction>(_editEntry),
  new ReducerBinding<List<Entry>, RemoveEntryAction>(_removeEntry),
  new ReducerBinding<List<Entry>, UpdateEntryAction>(_updateEntry),
  new ReducerBinding<List<Entry>, EntriesLoadedAction>(_loadEntries),
]);

final isLoadingReducer = combineTypedReducers([
  new ReducerBinding<bool, EntriesLoadedAction>(_finishLoading),
  new ReducerBinding<bool, EntriesNotLoadedAction>(_finishLoading),
]);

DateTime _updateSelectedDate(DateTime date, UpdateSelectedDateAction action) {
  return DateTime.parse(action.newDate.toIso8601String());
}

List<Entry> _addEntry(List<Entry> entries, AddEntryAction action) {
  Entry entry = new Entry(action.entry.id, action.entry.date, action.entry.text);
  if (entry.id == null) {
    entry.id = entries.fold(0, (previousValue, e) => max(previousValue, e.id));
    entry.id += 1;
  }
  return new List<Entry>.from(entries)..add(entry);
}

List<Entry> _editEntry(List<Entry> entries, EditEntryAction action) {
  Entry editedEntry = new Entry(action.id, action.entry.date, action.entry.text);
  assert(editedEntry.id != null);
  return entries.map((e) => action.id == e.id ? editedEntry : e).toList();
}

List<Entry> _removeEntry(List<Entry> entries, RemoveEntryAction action) {
  return entries.where((e) => e.id != action.id).toList();
}

List<Entry> _updateEntry(List<Entry> entries, UpdateEntryAction action) {
  return entries.map((e) => e.id == action.id ? action.updatedEntry : e).toList();
}

List<Entry> _loadEntries(List<Entry> entries, EntriesLoadedAction action) {
  return new List<Entry>.from(action.entries);
}

bool _finishLoading(bool isLoading, action) {
  return false;
}