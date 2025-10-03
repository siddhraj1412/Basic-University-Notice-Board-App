import 'dart:async';
import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/notice.dart';

class DatabaseService {
  static Database? _database;
  static bool _initialized = false;
  static final List<Notice> _inMemoryNotices = [];
  static int _fallbackIdCounter = -1;

  Future<Database> get database async {
    if (!_initialized) {
      databaseFactory = databaseFactoryFfiWeb;
      _initialized = true;
    }

    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var path = 'notices.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            category TEXT,
            filePath TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertNotice(Notice notice) async {
    try {
      final db = await database.timeout(const Duration(seconds: 2));
      await db.insert('notices', notice.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      final fallbackId = _fallbackIdCounter--;
      _inMemoryNotices.insert(
        0,
        Notice(
          id: fallbackId,
          title: notice.title,
          description: notice.description,
          category: notice.category,
          filePath: notice.filePath,
        ),
      );
    }
  }

  Future<List<Notice>> getNotices() async {
    try {
      final db = await database.timeout(const Duration(seconds: 2));
      final List<Map<String, dynamic>> maps = await db.query(
        'notices',
        orderBy: 'id DESC',
      );
      final fromDb = List.generate(maps.length, (i) => Notice.fromMap(maps[i]));
      if (_inMemoryNotices.isNotEmpty) {
        return [..._inMemoryNotices, ...fromDb];
      }
      return fromDb;
    } catch (e) {
      return List.from(_inMemoryNotices);
    }
  }

  Future<List<Notice>> getNoticesByCategory(NoticeCategory? category) async {
    if (category == null) {
      return getNotices();
    }
    try {
      final db = await database.timeout(const Duration(seconds: 2));
      final List<Map<String, dynamic>> maps = await db.query(
        'notices',
        where: 'category = ?',
        whereArgs: [category.name],
        orderBy: 'id DESC',
      );
      final fromDb = List.generate(maps.length, (i) => Notice.fromMap(maps[i]));
      final fromMemory =
          _inMemoryNotices.where((n) => n.category == category).toList();
      return [...fromMemory, ...fromDb];
    } catch (e) {
      return _inMemoryNotices.where((n) => n.category == category).toList();
    }
  }

  Future<List<Notice>> searchNotices(String query) async {
    try {
      final db = await database.timeout(const Duration(seconds: 2));
      final List<Map<String, dynamic>> maps = await db.query(
        'notices',
        where: 'title LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'id DESC',
      );
      final fromDb = List.generate(maps.length, (i) => Notice.fromMap(maps[i]));
      final fromMemory =
          _inMemoryNotices.where((n) => n.title.contains(query)).toList();
      return [...fromMemory, ...fromDb];
    } catch (e) {
      return _inMemoryNotices.where((n) => n.title.contains(query)).toList();
    }
  }
}
