import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();
  factory DatabaseHelper() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('restaurant.db');
    await _normalizeLegacyTableStatuses(_database!);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 8,
      onCreate: _onCreateDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE products ADD COLUMN cost_price REAL DEFAULT 0.0');
    }
    if (oldVersion < 3) {
      await db.execute('CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT)');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE orders ADD COLUMN type TEXT');
      await db.execute('ALTER TABLE orders ADD COLUMN status TEXT');
      await db.execute('ALTER TABLE orders ADD COLUMN item_count INTEGER DEFAULT 0');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE order_items ADD COLUMN price REAL DEFAULT 0.0');
      await db.execute('CREATE TABLE IF NOT EXISTS cart_items (table_id TEXT, product_id TEXT, quantity INTEGER, PRIMARY KEY (table_id, product_id))');
    }
    if (oldVersion < 6) {
      await db.execute('CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT UNIQUE, phone TEXT, password TEXT)');
    }
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE tables ADD COLUMN user_id TEXT DEFAULT "admin"');
      await db.execute('ALTER TABLE products ADD COLUMN user_id TEXT DEFAULT "admin"');
      await db.execute('ALTER TABLE orders ADD COLUMN user_id TEXT DEFAULT "admin"');
      await db.execute('ALTER TABLE expenses ADD COLUMN user_id TEXT DEFAULT "admin"');
      await db.execute('ALTER TABLE cart_items ADD COLUMN user_id TEXT DEFAULT "admin"');

      await db.execute('CREATE TABLE settings_new (user_id TEXT, key TEXT, value TEXT, PRIMARY KEY (user_id, key))');
      await db.execute('INSERT INTO settings_new (user_id, key, value) SELECT "admin", key, value FROM settings');
      await db.execute('DROP TABLE settings');
      await db.execute('ALTER TABLE settings_new RENAME TO settings');
    }
    if (oldVersion < 8) {
      await db.execute('ALTER TABLE orders ADD COLUMN is_synced INTEGER DEFAULT 0');
    }
  }

  Future<void> _onCreateDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        phone TEXT,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS tables (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        name TEXT,
        seats INTEGER,
        status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        cost_price REAL DEFAULT 0.0,
        category TEXT,
        imageUrl TEXT)
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        table_id TEXT NOT NULL,
        date_time TEXT NOT NULL,
        invoice_no TEXT NOT NULL,
        lookup_code TEXT NOT NULL,
        sub_total REAL NOT NULL,
        vat_amount REAL NOT NULL,
        total_amount REAL NOT NULL,
        type TEXT,
        status TEXT,
        item_count INTEGER DEFAULT 0,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL DEFAULT 0.0,
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cart_items (
        user_id TEXT,
        table_id TEXT,
        product_id TEXT,
        quantity INTEGER,
        PRIMARY KEY (user_id, table_id, product_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        title TEXT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        user_id TEXT,
        key TEXT,
        value TEXT,
        PRIMARY KEY (user_id, key)
      )
    ''');
  }

  Future<String> getSetting(String a, String b, [String? c]) async {
    final userId = c == null ? 'admin' : a;
    final key = c == null ? a : b;
    final defaultValue = c ?? b;

    final db = await database;
    final res = await db.query('settings', where: 'user_id = ? AND key = ?', whereArgs: [userId, key]);
    if (res.isNotEmpty) return res.first['value'].toString();
    return defaultValue;
  }

  Future<void> saveSetting(String a, String b, [String? c]) async {
    final userId = c == null ? 'admin' : a;
    final key = c == null ? a : b;
    final value = c ?? b;

    final db = await database;
    await db.insert(
      'settings',
      {'user_id': userId, 'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertExpense(dynamic a, [Map<String, dynamic>? b]) async {
    final userId = b == null ? 'admin' : a as String;
    final expense = b == null ? Map<String, dynamic>.from(a as Map) : Map<String, dynamic>.from(b);
    final db = await database;
    expense['user_id'] = userId;
    return db.insert('expenses', expense);
  }

  Future<List<Map<String, dynamic>>> getAllExpenses([String userId = 'admin']) async {
    final db = await database;
    return db.query('expenses', where: 'user_id = ?', whereArgs: [userId], orderBy: 'date DESC');
  }

  Future<int> deleteExpense(String a, [String? b]) async {
    final userId = b == null ? 'admin' : a;
    final id = b ?? a;
    final db = await database;
    return db.delete('expenses', where: 'user_id = ? AND id = ?', whereArgs: [userId, id]);
  }

  Future<List<Map<String, dynamic>>> getAllTablesFromDb([String userId = 'admin']) async {
    final db = await database;
    return db.query('tables', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> updateTableStatusInDb(String a, String b, [String? c]) async {
    final userId = c == null ? 'admin' : a;
    final id = c == null ? a : b;
    final status = c ?? b;
    final db = await database;
    return db.update('tables', {'status': status}, where: 'user_id = ? AND id = ?', whereArgs: [userId, id]);
  }

  Future<List<Map<String, dynamic>>> getAllOrders([String userId = 'admin']) async {
    final db = await database;
    return db.query('orders', where: 'user_id = ?', whereArgs: [userId], orderBy: 'date_time DESC');
  }

  Future<int> insertProduct(dynamic a, [Map<String, dynamic>? b]) async {
    final userId = b == null ? 'admin' : a as String;
    final product = b == null ? Map<String, dynamic>.from(a as Map) : Map<String, dynamic>.from(b);
    final db = await database;
    product['user_id'] = userId;
    return db.insert('products', product, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllProducts([String userId = 'admin']) async {
    final db = await database;
    return db.query('products', where: 'user_id = ?', whereArgs: [userId], orderBy: 'name ASC');
  }

  Future<int> deleteProduct(String a, [String? b]) async {
    final userId = b == null ? 'admin' : a;
    final id = b ?? a;
    final db = await database;
    return db.delete('products', where: 'user_id = ? AND id = ?', whereArgs: [userId, id]);
  }

  Future<void> insertCartItem(String a, String b, dynamic c, [int? d]) async {
    final userId = d == null ? 'admin' : a;
    final tableId = d == null ? a : b;
    final productId = d == null ? b : c as String;
    final quantity = d ?? (c as int);

    final db = await database;
    await db.insert(
      'cart_items',
      {'user_id': userId, 'table_id': tableId, 'product_id': productId, 'quantity': quantity},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getCartItems(String a, [String? b]) async {
    final userId = b == null ? 'admin' : a;
    final tableId = b ?? a;
    final db = await database;
    return db.rawQuery('''
      SELECT ci.quantity, p.*
      FROM cart_items ci
      JOIN products p ON ci.product_id = p.id
      WHERE ci.user_id = ? AND ci.table_id = ?
    ''', [userId, tableId]);
  }

  Future<void> deleteCartItem(String a, String b, [String? c]) async {
    final userId = c == null ? 'admin' : a;
    final tableId = c == null ? a : b;
    final productId = c ?? b;
    final db = await database;
    await db.delete('cart_items', where: 'user_id = ? AND table_id = ? AND product_id = ?', whereArgs: [userId, tableId, productId]);
  }

  Future<void> clearCart(String a, [String? b]) async {
    final userId = b == null ? 'admin' : a;
    final tableId = b ?? a;
    final db = await database;
    await db.delete('cart_items', where: 'user_id = ? AND table_id = ?', whereArgs: [userId, tableId]);
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    final id = await db.insert('users', user);
    return id;
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final res = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    if (res.isNotEmpty) return res.first;
    return null;
  }

  Future<void> _normalizeLegacyTableStatuses(Database db) async {
    await db.update('tables', {'status': 'TRONG'}, where: 'status IN (?, ?, ?)', whereArgs: ['TRONG', 'Tr?ng', 'TRONG']);
    await db.update('tables', {'status': 'CO_KHACH'}, where: 'status IN (?, ?, ?)', whereArgs: ['CO KHACH', 'Co khach', 'CO_KHACH']);
  }
}

