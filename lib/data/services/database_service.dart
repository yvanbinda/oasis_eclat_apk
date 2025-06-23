import 'package:oasis_eclat/data/models/customer_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor();
  static Database? _db;

  // Customers table
  final String _customersTableName = "Customers";
  final String _customerId = "id";
  final String _customerName = "customer_name";
  final String _customerService = "service";
  final String _customerAddress = "address";
  final String _customerPhone = "phone";
  final String _customerDateTime = "date_time";
  final String _customerAmount = "amount_to_be_paid";
  final String _customerIsCleaned = "is_paid";


  // DatabaseService's Constructor
  DatabaseService._constructor();

  Future<Database?> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db;
  }

  /// Setup the database and provide space to save database in device directory
  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    // Join path to database
    final databasePath = join(databaseDirPath, "cleaningServiceDatabase.db");
    // Open database
    final database = await openDatabase(
      databasePath,
      version: 2,
      // Define logic when database is being created
      onCreate: (db, version) {

        // Create Customers table
        db.execute('''
          CREATE TABLE $_customersTableName (
            $_customerId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_customerName TEXT NOT NULL,
            $_customerService TEXT NOT NULL,
            $_customerAddress TEXT NOT NULL,
            $_customerPhone TEXT NOT NULL,
            $_customerDateTime TEXT NOT NULL,
            $_customerAmount REAL NOT NULL,
            $_customerIsCleaned INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      // Handle database upgrades
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          // Add Customers table for existing databases
          db.execute('''
            CREATE TABLE $_customersTableName (
              $_customerId INTEGER PRIMARY KEY AUTOINCREMENT,
              $_customerName TEXT NOT NULL,
              $_customerService TEXT NOT NULL,
              $_customerAddress TEXT NOT NULL,
              $_customerPhone TEXT NOT NULL,
              $_customerDateTime TEXT NOT NULL,
              $_customerAmount REAL NOT NULL,
              $_customerIsCleaned INTEGER NOT NULL DEFAULT 0
            )
          ''');
        }
      },
    );
    return database;
  }

  // CRUD Operations for Customers

  // CREATE - Add a new customer
  Future<int> addCustomer(Customer customer) async {
    final db = await database;
    return await db!.insert(_customersTableName, customer.toMap());
  }

  // READ - Get all customers
  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(_customersTableName);
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  // READ - Get customer by ID
  Future<Customer?> getCustomerById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      _customersTableName,
      where: '$_customerId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  // READ - Get customers by payment status
  Future<List<Customer>> getCustomersByPaymentStatus(bool isCleaned) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      _customersTableName,
      where: '$_customerIsCleaned = ?',
      whereArgs: [isCleaned ? 1 : 0],
    );
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  // READ - Get customers by service type
  Future<List<Customer>> getCustomersByService(String service) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      _customersTableName,
      where: '$_customerService = ?',
      whereArgs: [service],
    );
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  // READ - Get customers by date range
  Future<List<Customer>> getCustomersByDateRange(String startDate, String endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      _customersTableName,
      where: '$_customerDateTime BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: '$_customerDateTime ASC',
    );
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  // UPDATE - Modify a customer
  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db!.update(
      _customersTableName,
      customer.toMap(),
      where: '$_customerId = ?',
      whereArgs: [customer.id],
    );
  }

  // UPDATE - Toggle customer payment status
  Future<int> togglePaymentStatus(int id) async {
    final db = await database;
    final customer = await getCustomerById(id);
    if (customer != null) {
      return await db!.update(
        _customersTableName,
        {'is_paid': customer.isCleaned ? 0 : 1},
        where: '$_customerId = ?',
        whereArgs: [id],
      );
    }
    return 0;
  }

  // DELETE - Remove a customer by ID
  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db!.delete(
      _customersTableName,
      where: '$_customerId = ?',
      whereArgs: [id],
    );
  }

  // DELETE - Remove all customers
  Future<int> deleteAllCustomers() async {
    final db = await database;
    return await db!.delete(_customersTableName);
  }

  // UTILITY - Reset all customers payment status to unpaid
  Future<int> resetAllPaymentStatus() async {
    final db = await database;
    return await db!.update(
      _customersTableName,
      {'is_paid': 0},
    );
  }

  // UTILITY - Get count of customers
  Future<int> getCustomersCount() async {
    final db = await database;
    final count = await db!.rawQuery('SELECT COUNT(*) FROM $_customersTableName');
    return Sqflite.firstIntValue(count) ?? 0;
  }

  // UTILITY - Get count of paid customers
  Future<int> getCleanedCustomersCount() async {
    final db = await database;
    final count = await db!.rawQuery(
        'SELECT COUNT(*) FROM $_customersTableName WHERE $_customerIsCleaned = 1'
    );
    return Sqflite.firstIntValue(count) ?? 0;
  }

  // UTILITY - Get total revenue from paid customers
  Future<double> getTotalRevenue() async {
    final db = await database;
    final result = await db!.rawQuery(
        'SELECT SUM($_customerAmount) FROM $_customersTableName WHERE $_customerIsCleaned = 1'
    );
    return (result.first.values.first as double?) ?? 0.0;
  }

  // UTILITY - Get total pending amount
  Future<double> getTotalPendingAmount() async {
    final db = await database;
    final result = await db!.rawQuery(
        'SELECT SUM($_customerAmount) FROM $_customersTableName WHERE $_customerIsCleaned = 0'
    );
    return (result.first.values.first as double?) ?? 0.0;
  }

  // UTILITY - Search customers by name
  Future<List<Customer>> searchCustomersByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      _customersTableName,
      where: '$_customerName LIKE ?',
      whereArgs: ['%$name%'],
    );
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }
}