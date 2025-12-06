import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fuel_management.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Equipment table
    await db.execute('''
      CREATE TABLE equipment (
        equipment_id INTEGER PRIMARY KEY,
        equipment_code TEXT UNIQUE,
        equipment_type TEXT,
        plate_number TEXT,
        driver_name TEXT,
        department TEXT,
        status TEXT DEFAULT 'ACTIVE',
        last_sync_date TEXT
      )
    ''');

    // Fuel transactions table
    await db.execute('''
      CREATE TABLE fuel_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_transaction_id TEXT UNIQUE,
        equipment_id INTEGER,
        fuel_type TEXT,
        quantity REAL,
        unit_price REAL,
        total_amount REAL,
        odometer INTEGER,
        operator_id INTEGER,
        transaction_date TEXT,
        notes TEXT,
        sync_status TEXT DEFAULT 'PENDING',
        sync_error TEXT,
        created_at TEXT,
        synced_at TEXT,
        FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id)
      )
    ''');

    // Fuel prices table
    await db.execute('''
      CREATE TABLE fuel_prices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fuel_type TEXT UNIQUE,
        unit_price REAL,
        updated_at TEXT
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_equipment_code ON equipment(equipment_code)');
    await db.execute('CREATE INDEX idx_transaction_date ON fuel_transactions(transaction_date)');
    await db.execute('CREATE INDEX idx_sync_status ON fuel_transactions(sync_status)');

    // Insert default fuel prices
    await db.insert('fuel_prices', {'fuel_type': 'PETROL80', 'unit_price': 10.0, 'updated_at': DateTime.now().toIso8601String()});
    await db.insert('fuel_prices', {'fuel_type': 'PETROL92', 'unit_price': 12.5, 'updated_at': DateTime.now().toIso8601String()});
    await db.insert('fuel_prices', {'fuel_type': 'PETROL95', 'unit_price': 15.0, 'updated_at': DateTime.now().toIso8601String()});
    await db.insert('fuel_prices', {'fuel_type': 'DIESEL', 'unit_price': 11.5, 'updated_at': DateTime.now().toIso8601String()});
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // ============ EQUIPMENT Methods ============

  Future<List<Map<String, dynamic>>> getAllEquipment() async {
    final db = await database;
    return await db.query('equipment', where: 'status = ?', whereArgs: ['ACTIVE']);
  }

  Future<Map<String, dynamic>?> getEquipmentByCode(String code) async {
    final db = await database;
    final result = await db.query(
      'equipment',
      where: 'equipment_code = ?',
      whereArgs: [code],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getEquipmentById(int id) async {
    final db = await database;
    final result = await db.query(
      'equipment',
      where: 'equipment_id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> insertOrUpdateEquipment(Map<String, dynamic> equipment) async {
    final db = await database;
    final data = {
      'equipment_id': equipment['EQUIPMENT_ID'] ?? equipment['equipment_id'],
      'equipment_code': equipment['EQUIPMENT_CODE'] ?? equipment['equipment_code'],
      'equipment_type': equipment['EQUIPMENT_TYPE'] ?? equipment['equipment_type'],
      'plate_number': equipment['PLATE_NUMBER'] ?? equipment['plate_number'],
      'driver_name': equipment['DRIVER_NAME'] ?? equipment['driver_name'],
      'department': equipment['DEPARTMENT'] ?? equipment['department'],
      'status': equipment['STATUS'] ?? equipment['status'] ?? 'ACTIVE',
      'last_sync_date': DateTime.now().toIso8601String(),
    };

    await db.insert(
      'equipment',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============ TRANSACTION Methods ============

  Future<List<Map<String, dynamic>>> getTransactions({
    int? equipmentId,
    String? fuelType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    final db = await database;
    
    String where = '1=1';
    List<dynamic> whereArgs = [];
    
    if (equipmentId != null) {
      where += ' AND equipment_id = ?';
      whereArgs.add(equipmentId);
    }
    
    if (fuelType != null) {
      where += ' AND fuel_type = ?';
      whereArgs.add(fuelType);
    }
    
    if (startDate != null) {
      where += ' AND transaction_date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      where += ' AND transaction_date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    return await db.query(
      'fuel_transactions',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'transaction_date DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getPendingTransactions() async {
    final db = await database;
    return await db.query(
      'fuel_transactions',
      where: 'sync_status = ?',
      whereArgs: ['PENDING'],
      orderBy: 'created_at ASC',
    );
  }

  Future<int> getPendingTransactionsCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM fuel_transactions WHERE sync_status = ?',
      ['PENDING'],
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<Map<String, dynamic>> getTodayStats() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as count,
        COALESCE(SUM(quantity), 0) as total
      FROM fuel_transactions
      WHERE transaction_date >= ?
    ''', [startOfDay.toIso8601String()]);
    
    return {
      'count': result.first['count'] as int? ?? 0,
      'total': (result.first['total'] as num?)?.toDouble() ?? 0.0,
    };
  }

  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    final data = {
      ...transaction,
      'created_at': DateTime.now().toIso8601String(),
    };
    return await db.insert('fuel_transactions', data);
  }

  Future<void> updateTransactionSyncStatus(String localId, String status, {String? error}) async {
    final db = await database;
    await db.update(
      'fuel_transactions',
      {
        'sync_status': status,
        'sync_error': error,
        'synced_at': status == 'SYNCED' ? DateTime.now().toIso8601String() : null,
      },
      where: 'local_transaction_id = ?',
      whereArgs: [localId],
    );
  }

  // ============ FUEL PRICES Methods ============

  Future<double> getFuelPrice(String fuelType) async {
    final db = await database;
    final result = await db.query(
      'fuel_prices',
      where: 'fuel_type = ?',
      whereArgs: [fuelType],
    );
    return result.isNotEmpty ? (result.first['unit_price'] as num).toDouble() : 0.0;
  }

  Future<Map<String, double>> getAllFuelPrices() async {
    final db = await database;
    final result = await db.query('fuel_prices');
    return {
      for (var row in result)
        row['fuel_type'] as String: (row['unit_price'] as num).toDouble()
    };
  }

  // ============ UTILITY Methods ============

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('fuel_transactions');
    await db.delete('equipment');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
