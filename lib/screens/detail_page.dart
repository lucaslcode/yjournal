import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:yjournal/models.dart';

class DetailPage extends StatefulWidget {
  final String title;
  final int id;
  final DateTime date;
  final String text;

  DetailPage({
    Key key,
    @required this.title,
    @required this.id,
    @required this.date,
    @required this.text
  }) : super(key: key);

  @override
  _DetailPageState createState() => new _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController controller;
  FocusNode focusNode;
  DateTime date;

  @override
  initState() {
    super.initState();
    controller = new TextEditingController(text: widget.text);
    date = widget.date;
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        actions: <Widget>[
          new FlatButton(
              onPressed: () => Navigator.of(context).pop(new Entry(widget.id, date, controller.text)),
              child: const Text('Save')
          )
        ]
      ),
      body: new Container(
        padding: new EdgeInsets.all(8.0),
        child: new Column(
          children: <Widget>[
            new Row(children: <Widget>[ new Text('${date.day}/${date.month}/${date.year}', style: Theme.of(context).textTheme.body1.apply(fontSizeFactor: 0.8, color: Colors.black54))]),
            new Expanded(
              child:  new TextField(
                controller: controller,
                style: Theme.of(context).textTheme.body1,
                maxLines: null,
                decoration: new InputDecoration.collapsed(hintText: ''),
              ),
            ),
          ]
        ),
      ),
    );
  }
}