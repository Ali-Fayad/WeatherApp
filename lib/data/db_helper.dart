import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/favorite.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper _instance = DBHelper._privateConstructor();
  factory DBHelper() => _instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'weather_app.db');

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          passwordHash TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE favorites (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cityName TEXT,
          lat REAL,
          lon REAL,
          note TEXT
        )
      ''');
    });
  }

  // User operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<User?> getAnyUser() async {
    final db = await database;
    final maps = await db.query('users', limit: 1);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Favorites CRUD
  Future<int> insertFavorite(Favorite fav) async {
    final db = await database;
    return await db.insert('favorites', fav.toMap());
  }

  Future<List<Favorite>> getFavorites() async {
    final db = await database;
    final maps = await db.query('favorites', orderBy: 'cityName');
    return maps.map((m) => Favorite.fromMap(m)).toList();
  }

  Future<int> updateFavorite(Favorite fav) async {
    final db = await database;
    return await db.update('favorites', fav.toMap(), where: 'id = ?', whereArgs: [fav.id]);
  }

  Future<int> deleteFavorite(int id) async {
    final db = await database;
    return await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }
}
