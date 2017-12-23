import 'dart:io';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:yjournal/models.dart';

class DataSource {
  Database _db;
  final int version;

  DataSource(this.version);

  Future<dynamic> initialise() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = "${documentsDirectory.path}/app.db";
    _db = await openDatabase(path, version: version,
      onOpen: (Database db) async {
          await db.execute(
              '''CREATE TABLE IF NOT EXISTS entries (
              id INTEGER PRIMARY KEY,
              date TEXT,
              text TEXT);
              ''');
        },
      onDowngrade: (Database db, int oldVersion, int newVersion) async {
        if (newVersion == 1) await db.delete('entries');
      },
    );
  }

  Future<List<Entry>> loadEntries() async {
    final List<Map<String, dynamic>> entryMaps = await _db.query('entries', columns: ['id', 'date', 'text']);
    return entryMaps.map((entryMap) => Entry.fromMap(entryMap)).toList();
  }

  Future<int> addEntry(Entry entry) async {
    return await _db.insert('entries', entry.toMap());
  }

  Future<int> editEntry(int id, Entry entry) async {
    return await _db.update('entries', entry.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  Future<int> removeEntry(int id) async {
    return await _db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }
}