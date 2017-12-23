import 'package:yjournal/models.dart';

class AddEntryAction {
  final Entry entry;

  AddEntryAction(this.entry);
}

class EditEntryAction {
  final int id;
  final Entry entry;

  EditEntryAction(this.id, this.entry);
}

class RemoveEntryAction {
  final int id;

  RemoveEntryAction(this.id);
}

class UpdateEntryAction {
  final int id;
  final Entry updatedEntry;

  UpdateEntryAction(this.id, this.updatedEntry);
}

class UpdateSelectedDateAction {
  final DateTime newDate;

  UpdateSelectedDateAction(this.newDate);
}

class LoadEntriesAction {
  LoadEntriesAction();
}

class EntriesLoadedAction {
  List<Entry> entries;

  EntriesLoadedAction(this.entries);
}

class EntriesNotLoadedAction {
  Error error;

  EntriesNotLoadedAction(this.error);
}