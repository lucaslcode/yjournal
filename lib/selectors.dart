import 'dart:collection';

import 'package:yjournal/models.dart';

DateTime selectedDateSelector(AppState state) => state.selectedDate;

List<Entry> entriesSelector(AppState state) => state.entries;

bool isLoadingSelector(AppState state) => state.isLoading;

SplayTreeMap<DateTime, List<Entry>> dateMappedEntriesSelector(AppState state) {
  List<Entry> entries = entriesSelector(state);
  SplayTreeMap<DateTime, List<Entry>> entriesMap = new SplayTreeMap((key1, key2) => key1.compareTo(key2));
  if (entries == null || entries.isEmpty) return entriesMap;
  entries.forEach((entry) {
    if (!entriesMap.containsKey(entry.date)) { entriesMap[entry.date] = [entry]; }
    else { entriesMap[entry.date].add(entry); }
  });
  return entriesMap;
}

List<DateTime> entryDatesSelector(AppState state) =>
    state.entries.map((e) => new DateTime(e.date.year, e.date.month, e.date.day)).toList();