import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:yjournal/models.dart';

class EntryList extends StatelessWidget {
  EntryList({this.entries, this.selectedDate, this.onDismissed, this.scrollController, this.onEntryPressed});

  final SplayTreeMap<DateTime, List<Entry>> entries;
  final DateTime selectedDate;
  final DismissEntryCallback onDismissed;
  final ScrollController scrollController;
  final EditEntryCallback onEntryPressed;



  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    if (entries.isEmpty) return new Column(children: <Widget>[
      new ListTile(title: const Text('No entries... yet'), dense: true)
    ]);

    return new ListView.builder(
      shrinkWrap: true,
      controller: scrollController,
      itemCount: entries.values.length,
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
                    key: new Key('__' + entry.id.toString() + '__'),
                    onDismissed: (direction) {
                      onDismissed(direction, entry.id);
                    },
                    child: new ListTile(
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