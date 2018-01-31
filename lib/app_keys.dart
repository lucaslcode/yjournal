import 'package:flutter/widgets.dart';

class AppKeys {
  //screens
  static final homePage = const Key('__homePage__');
  static final detailPage = const Key('__detailPage__');

  //widgets
  static final addFab = const Key('__addFab__');
  static final entryList = const Key('__entryList__');
  static final monthlyPicker = const Key('__monthlyPicker__');

  //entries
  static final entry = (String id) => new Key('entry_$id');
  static final entryListTile = (String id) => new Key('entryListTile_$id');


}