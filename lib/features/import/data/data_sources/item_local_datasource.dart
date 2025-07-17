import 'package:flutter_stock_scanner/features/import/data/models/item_model.dart';
import 'package:flutter_stock_scanner/features/import/domain/entities/item.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ItemLocalDataSource {
  static final ItemLocalDataSource _instance = ItemLocalDataSource._internal();

  factory ItemLocalDataSource() => _instance;
  ItemLocalDataSource._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'items.db');
    return await openDatabase(
      path,
      version: 2, // Increment version to trigger onUpgrade
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE items(
         code TEXT PRIMARY KEY,
            label TEXT,
            description TEXT,
            date TEXT,
            quantity REAL, 
            imageBase64 TEXT
        )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Migrate from INTEGER to REAL for quantity
          await db.execute('''
          CREATE TABLE items_temp(
           code TEXT PRIMARY KEY,
              label TEXT,
              description TEXT,
              date TEXT,
              quantity REAL, 
              imageBase64 TEXT
          )
          ''');

          // Copy data, converting INTEGER to REAL
          await db.execute('''
          INSERT INTO items_temp (code, label, description, date, quantity, imageBase64)
          SELECT code, label, description, date, CAST(quantity AS REAL), imageBase64 
          FROM items
          ''');

          // Drop old table and rename temp table
          await db.execute('DROP TABLE items');
          await db.execute('ALTER TABLE items_temp RENAME TO items');
        }
      },
    );
  }

  Future<void> insertItems(List<ItemModel> items) async {
    final dbClient = await db;
    final batch = dbClient.batch();
    for (var item in items) {
      batch.insert('items', item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // Future<List<ItemModel>> getAllItems() async {
  //   final dbClient = await db;
  //   final maps = await dbClient.query('items');
  //   return maps.map((map) => ItemModel.fromMap(map)).toList();
  // }

  Future<List<ItemModel>> getAllItems() async {
    final dbClient = await db;
    final maps = await dbClient.query('items');
    print('DEBUG: getAllItems returned ${maps.length} items');
    return maps.map((map) => ItemModel.fromMap(map)).toList();
  }

  Future<void> deleteItem(String code) async {
    final dbClient = await db;
    await dbClient.delete(
      'items',
      where: 'code = ?',
      whereArgs: [code],
    );
  }

  Future<void> updateItem(ItemModel item) async {
    final dbClient = await db;
    await dbClient.update(
      'items',
      item.toMap(),
      where: 'code = ?',
      whereArgs: [item.code],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Item?> getItemByCode(String code) async {
    final dbClient = await db;
    final maps = await dbClient.query(
      'items',
      where: 'code = ?',
      whereArgs: [code],
    );
    if (maps.isNotEmpty) {
      return ItemModel.fromMap(maps.first);
    }
    return null;
  }
}
