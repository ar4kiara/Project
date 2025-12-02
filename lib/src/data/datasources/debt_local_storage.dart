import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/debt_entry.dart';

class DebtLocalStorage {
  static const _table = 'debts';
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'mytagiheun.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id TEXT PRIMARY KEY,
            contactName TEXT,
            nominal INTEGER,
            flow TEXT,
            keterangan TEXT,
            jatuhTempo INTEGER,
            dibuatPada INTEGER,
            diperbaruiPada INTEGER
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> insertOrUpdate(DebtEntry entry) async {
    final db = await database;
    await db.insert(
      _table,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DebtEntry>> getAll() async {
    final db = await database;
    final results = await db.query(
      _table,
      orderBy: 'dibuatPada DESC',
    );
    return results.map(DebtEntry.fromMap).toList();
  }

  Future<void> delete(String id) async {
    final db = await database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete(_table);
  }

  Future<void> close() async {
    await _db?.close();
  }
}

