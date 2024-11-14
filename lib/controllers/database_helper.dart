import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/boleta_item.dart';
import '../models/product.dart';
import '../models/boleta_document.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    // Reinitialize the database if it is closed
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      singleInstance: true,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        birthdate TEXT NOT NULL,
        address TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT NOT NULL UNIQUE,
        stock INTEGER NOT NULL,
        descripcion TEXT NOT NULL,
        precio double NOT NULL,
        bodega TEXT NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE boleta_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        cantidad INTEGER NOT NULL,
        precioUnitario REAL NOT NULL,
        valorTotal REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS boleta_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folio TEXT,
        rut TEXT,
        total REAL,
        fecha TEXT,
        pdfPath TEXT,
        estado TEXT,
        usuario TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
    }
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    Database db = await database;
    return await db.query('users');
  }

  Future<int> deleteUser(int id) async {
    Database db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> printDatabasePath() async {
    String path = await getDatabasesPath();
    print('Database path: $path');
  }

  Future<bool> deleteUserById(int id) async {
    final db = await database;
    int result = await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }

  Future<void> deleteUserDatabase() async {
    String path = join(await getDatabasesPath(), 'user_database.db');
    await deleteDatabase(path);
  }

  Future<int> insertBoletaItem(BoletaItem item) async {
    try {
      final db = await database;
      if (!db.isOpen) {
        _database = null;
        return insertBoletaItem(item);
      }

      return await db.transaction((txn) async {
        return await txn.insert(
          'boleta_items',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    } catch (e) {
      print('Error inserting boleta item: $e');
      if (e.toString().contains('database_closed')) {
        _database = null;
        return insertBoletaItem(item);
      }
      rethrow;
    }
  }

  Future<List<BoletaItem>> getBoletaItems() async {
    try {
      final db = await database;
      if (!db.isOpen) {
        _database = null;
        return getBoletaItems();
      }

      return await db.transaction((txn) async {
        final List<Map<String, dynamic>> maps = await txn.query('boleta_items');
        return List.generate(maps.length, (i) {
          return BoletaItem.fromMap(maps[i]);
        });
      });
    } catch (e) {
      print('Error getting boleta items: $e');
      if (e.toString().contains('database_closed')) {
        _database = null;
        return getBoletaItems();
      }
      rethrow;
    }
  }

  Future<int> updateBoletaItem(BoletaItem item) async {
    final db = await database;
    return await db.update(
      'boleta_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteBoletaItem(int id) async {
    final db = await database;
    await db.delete(
      'boleta_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> insertProduct(Product product) async {
    try {
      final db = await database;
      if (!db.isOpen) {
        _database = null;
        return insertProduct(product);
      }

      await db.transaction((txn) async {
        await txn.insert(
          'products',
          product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      });
      print('Product inserted successfully');
    } catch (e) {
      print('Error inserting product: $e');
      if (e.toString().contains('database_closed')) {
        _database = null;
        return insertProduct(product);
      }
      rethrow;
    }
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<bool> checkIfTableExists(String tableName) async {
    final db = await database;
    var tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    print('Tables found: ${tables.length}');
    return tables.isNotEmpty;
  }

  Future<List<String>> getAllTables() async {
    final db = await database;
    var tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    return tables.map((table) => table['name'] as String).toList();
  }

// Method to check database status
  Future<bool> isDatabaseOpen() async {
    try {
      final db = await database;
      return db.isOpen;
    } catch (e) {
      print('Error checking database status: $e');
      return false;
    }
  }

  // Method to explicitly close database
  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  Future<bool> checkProductExists(String codigo) async {
    final db = await database;
    final result = await db.query(
      'products',
      where: 'codigo = ?',
      whereArgs: [codigo],
    );
    return result.isNotEmpty;
  }

  Future<void> createBoletaRecordsTable() async {
    final db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS boleta_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folio TEXT,
        rut TEXT,
        total REAL,
        fecha TEXT,
        pdfPath TEXT,
        estado TEXT,
        usuario TEXT
      )
    ''');
  }

  Future<int> insertBoletaRecord(BoletaRecord record) async {
    final db = await database;
    return await db.insert('boleta_records', record.toMap());
  }

  Future<List<BoletaRecord>> getBoletaRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('boleta_records');
    return List.generate(maps.length, (i) => BoletaRecord.fromMap(maps[i]));
  }

  Future<String> getNextFolio() async {
    final db = await database;
    final result = await db.rawQuery('SELECT MAX(CAST(folio AS INTEGER)) as maxFolio FROM boleta_records');
    final currentMaxFolio = result.first['maxFolio'] as int? ?? 0;
    return (currentMaxFolio + 1).toString().padLeft(6, '0');
  }

  Future<bool> deleteBoletaRecord(String folio) async {
    try {
      final db = await database;
      final result = await db.delete(
        'boleta_records',
        where: 'folio = ?',
        whereArgs: [folio],
      );
      return result > 0;
    } catch (e) {
      print('Error deleting boleta record: $e');
      return false;
    }
  }

  Future<int> updateBoletaRecord(BoletaRecord record) async {
    final db = await database;
    return await db.update(
      'boleta_records',
      record.toMap(),
      where: 'folio = ?',
      whereArgs: [record.folio],
    );
  }

  Future<String> getNextCreditNoteFolio() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT MAX(CAST(folio AS INTEGER)) as maxFolio FROM boleta_records WHERE estado = 'Nota Credito'");
    final currentMaxFolio = result.first['maxFolio'] as int? ?? 0;
    return (currentMaxFolio + 1).toString().padLeft(6, '0');
  }
}
