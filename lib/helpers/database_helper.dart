import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/patient.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("patients.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // bump version (since schema change: id -> TEXT)
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY, -- Firestore ID or UUID
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        lastAppointmentDate TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Drop old table (with int id) and recreate with text id
      await db.execute("DROP TABLE IF EXISTS patients");
      await _createDB(db, newVersion);
    }
  }

  /// Insert a new patient
  Future<int> insertPatient(Patient patient) async {
    final db = await instance.database;
    return await db.insert(
      'patients',
      patient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // ✅ if same id, replace
    );
  }

  /// Insert or update patient (used for Firestore sync)
  Future<void> insertOrUpdatePatient(Patient patient) async {
    final db = await instance.database;
    await db.insert(
      'patients',
      patient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all patients
  Future<List<Patient>> getPatients() async {
    final db = await instance.database;
    final result = await db.query('patients', orderBy: "name ASC");
    return result.map((map) => Patient.fromMap(map, map['id'] as String)).toList();
  }

  /// Update patient
  Future<int> updatePatient(Patient patient) async {
    final db = await instance.database;
    return await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  /// Delete patient
  Future<int> deletePatient(String id) async {
    final db = await instance.database;
    return await db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
