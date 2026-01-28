import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FavoritesDb {
  static final FavoritesDb instance = FavoritesDb._();
  FavoritesDb._();

  static const _dbName = 'favorites.db';
  static const _dbVersion = 1;

  static const tableHotels = 'favorite_hotels';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableHotels (
            hotel_id TEXT PRIMARY KEY,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> addHotel(String hotelId) async {
    final db = await database;
    await db.insert(
      tableHotels,
      {'hotel_id': hotelId, 'created_at': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeHotel(String hotelId) async {
    final db = await database;
    await db.delete(tableHotels, where: 'hotel_id = ?', whereArgs: [hotelId]);
  }

  Future<bool> isFavorite(String hotelId) async {
    final db = await database;
    final rows = await db.query(
      tableHotels,
      columns: ['hotel_id'],
      where: 'hotel_id = ?',
      whereArgs: [hotelId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<Set<String>> getAllFavoriteIds() async {
    final db = await database;
    final rows = await db.query(tableHotels, columns: ['hotel_id']);
    return rows.map((e) => e['hotel_id'] as String).toSet();
  }
}
