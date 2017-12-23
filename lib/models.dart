import 'package:flutter/material.dart';

typedef void DismissEntryCallback(DismissDirection dismissDirection, int id);
typedef void EditEntryCallback(Entry entry);

class Entry {
  int id;
  DateTime date;
  String text;

  Entry(this.id, this.date, [this.text='']);

  String toString() {
    return 'Entry id: $id, $date.\n$text';
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'date': date.toIso8601String(), 'text': text};
  }
  static Entry fromMap(Map<String, dynamic> map) {
    return new Entry(map['id'], DateTime.parse(map['date']), map['text']);
  }
}

class AppState {
  final DateTime selectedDate;
  final List<Entry> entries;
  final bool isLoading;

  AppState({this.selectedDate, this.entries, this.isLoading});
  AppState.loading({this.selectedDate, this.entries}) : isLoading = true;
}