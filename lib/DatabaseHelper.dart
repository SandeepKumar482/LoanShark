import 'package:loan_shark/LoanModel.dart';
import 'package:loan_shark/repayment_model.dart';
import 'package:loan_shark/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'user_database.db');
    print(path);

    return await databaseFactory.openDatabase(path,
        options: OpenDatabaseOptions(
          onCreate: _onCreate,
          //onUpgrade: _onUpgrade,
          version: 6, // Increment version if schema changes
        ));
  }

  void _onCreate(Database db, int version) async {
    print('Creating tables...');
    // ... (your table creation code for users and loans) ...
    await db.execute('''
          CREATE TABLE users(
            user_name TEXT PRIMARY KEY,
            password TEXT,
            display_name TEXT
          )
        ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS loans (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      borrower_name TEXT,
      principal_amount REAL,
      monthly_interest_rate REAL,
      balance REAL DEFAULT 0,
      address TEXT,
      phone_number TEXT,
      emi_repayment_date DATE,
      documents TEXT
    )
  ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS repayment (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  loan_id INTEGER NOT NULL,
  payment_date DATE NOT NULL,
  payment_amount REAL NOT NULL,
  payment_method TEXT NOT NULL,
  notes TEXT,
  FOREIGN KEY (loan_id) REFERENCES loans(id) ON DELETE CASCADE
)
  ''');

    await db.execute('''CREATE TABLE loan_update_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    loan_id INTEGER NOT NULL,
    updated_at TEXT NOT NULL,
    old_borrower_name TEXT,
    new_borrower_name TEXT,
    old_principal_amount REAL,
    new_principal_amount REAL,
    old_interest_rate REAL,
    new_interest_rate REAL,
    old_emi_date DATE,
    new_emi_date DATE,
    FOREIGN KEY (loan_id) REFERENCES loans(id)
)''');
    await db.execute("insert into users values('admin','admin', 'Vazir') ");
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Add the loans table
      await db.execute('''
      CREATE TABLE IF NOT EXISTS loans (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      borrower_name TEXT,
      principal_amount REAL,
      balance REAL DEFAULT 0,
      monthly_interest_rate REAL,
      address TEXT,
      phone_number TEXT,
      emi_repayment_date DATE,
      documents TEXT
    )
  ''');
      await db.execute('''
      CREATE TABLE IF NOT EXISTS repayment (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  loan_id INTEGER NOT NULL,
  payment_date DATE NOT NULL,
  payment_amount REAL NOT NULL,
  payment_method TEXT NOT NULL,
  notes TEXT,
  FOREIGN KEY (loan_id) REFERENCES loans(id) ON DELETE CASCADE
)
  ''');
      await db.execute('''CREATE TABLE loan_update_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    loan_id INTEGER NOT NULL,
    updated_at TEXT NOT NULL,
    old_borrower_name TEXT,
    new_borrower_name TEXT,
    old_principal_amount REAL,
    new_principal_amount REAL,
     old_interest_rate REAL,
    new_interest_rate REAL,
    old_emi_date DATE,
    new_emi_date DATE,
    FOREIGN KEY (loan_id) REFERENCES loans(id)
)''');
    }
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future<bool> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    try {
      await db.insert('users', user,
          conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    } catch (e) {
      print('Error inserting user: $e');
      return false;
    }
  }

  Future<User?> getUser(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'user_name = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> deleteUser(String username) async {
    final db = await database;
    try {
      await db.delete(
        'users',
        where: 'user_name = ?',
        whereArgs: [username],
      );
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  Future<void> updateUserPassword(
      String username, String newEncryptedPassword) async {
    final db = await database;
    await db.update(
      'users',
      {'password': newEncryptedPassword},
      where: 'user_name = ?',
      whereArgs: [username],
    );
  }

  // ... (other methods in DatabaseHelper) ...

// Insert a new loan record
  Future<int> insertLoan(Loan loan) async {
    final db = await database;
    return await db.insert('loans', loan.toMap());
  }

// Get all loan records
  Future<List<Loan>> getAllLoans() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('loans');
    return List.generate(maps.length, (i) => Loan.fromMap(maps[i]));
  }

// Update a loan record
  Future<int> updateLoan(Loan loan) async {
    final db = await database;
    return await db.update(
      'loans',
      loan.toMap(),
      where: 'id = ?',
      whereArgs: [loan.id],
    );
  }

// Delete a loan record
  Future<int> deleteLoan(int id) async {
    final db = await database;
    return await db.delete(
      'loans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Loan?> getLoanRecord(int id) async {
    final db = await database;
    final maps = await db.query(
      'loans',
      columns: [
        'id',
        'borrower_name',
        'principal_amount',
        'balance',
        'monthly_interest_rate',
        'address',
        'phone_number',
        'emi_repayment_date',
        'documents'
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Loan.fromMap(maps
          .first); // Assuming you have a fromMap constructor in your Loan model
    } else {
      return null;
    }
  }

  // Insert a repayment record
  Future<int> insertRepayment(Repayment repayment) async {
    final db = await database;
    return await db.insert('repayment', repayment.toMap());
  }

// Get all repayment records for a loan
  Future<List<Repayment>> getRepaymentsForLoan(int loanId) async {
    final db = await database;
    final maps = await db.query(
      'repayment',
      where: 'loan_id = ?',
      whereArgs: [loanId],
    );
    return List.generate(maps.length, (i) {
      return Repayment.fromMap(maps[i]);
    });
  }

// Update a repayment record
  Future<int> updateRepayment(Repayment repayment) async {
    final db = await database;
    return await db.update(
      'repayment',
      repayment.toMap(),
      where: 'id = ?',
      whereArgs: [repayment.id],
    );
  }

// Delete a repayment record
  Future<int> deleteRepayment(int id) async {
    final db = await database;
    return await db.delete(
      'repayment',
      where: 'loan_id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Loan>> searchLoans(String query) async {
    final db = await database;
    final queryParts = query.trim().toLowerCase().split(' '); // Split query into words
    final whereClauses = queryParts.map((part) =>
    '(LOWER(borrower_name) LIKE ? OR strftime(\'%d-%m-%Y\', emi_repayment_date) LIKE ?)'
    ).toList();
    final whereArgs = queryParts.expand((part) => ['%$part%', '%$part%']).toList();

    final List<Map<String, dynamic>> maps = await db.query(
      'loans',
      where: whereClauses.join(' AND '), // Combine where clauses with AND
      whereArgs: whereArgs,
    );
    return List.generate(maps.length, (i) {
      return Loan.fromMap(maps[i]);
    });
  }

  // Insert update history
  Future<void> insertLoanUpdateHistory(Map<String, dynamic> history) async {
    final db = await database;
    await db.insert('loan_update_history', history);
  }

// Get update history for a loan
  Future<List<Map<String, dynamic>>> getLoanUpdateHistory(int loanId) async {
    final db = await database;
    return await db.query(
      'loan_update_history',
      where: 'loan_id = ?',
      whereArgs: [loanId],
      orderBy: 'updated_at DESC', // Order by most recent updates
    );
  }
}
