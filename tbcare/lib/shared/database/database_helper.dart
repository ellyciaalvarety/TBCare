import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tbcare.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabel User (Auth)
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            role TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE doctors (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            no_hp TEXT,
            str_number TEXT,
            spesialisasi TEXT,
            tanggal_lahir TEXT,
            jenis_kelamin TEXT,
            FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        // Tabel Pasien
        await db.execute('''
          CREATE TABLE patients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            userId INTEGER,
            pid TEXT,
            phone TEXT,
            kepatuhan REAL,
            terakhir_cek TEXT,
            risiko TEXT,
            tanggal_lahir TEXT,
            jenis_kelamin TEXT,
            FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        // Tabel Jadwal Obat
        await db.execute('''
          CREATE TABLE schedules (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patientId INTEGER,
            time TEXT,
            medicineName TEXT,
            dosage TEXT,
            instruction TEXT,
            FOREIGN KEY (patientId) REFERENCES patients (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE appointments (
            id TEXT PRIMARY KEY,
            patientName TEXT,
            patientId INTEGER,
            type TEXT,
            time TEXT,
            room TEXT,
            isCompleted INTEGER DEFAULT 0,
            FOREIGN KEY (patientId) REFERENCES patients (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE patient_reports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patientId INTEGER,
            tanggal TEXT, -- format: "YYYY-MM-DD" atau angka tanggal seperti "24"
            bulan_tahun TEXT, -- contoh: "Mei 2026"
            jam_obat TEXT, -- contoh: "Obat jam 18:00"
            obat_list TEXT, -- Data JSON String untuk daftar obat dan statusnya
            gejala_list TEXT, -- Data JSON String untuk daftar gejala yang dirasakan
            catatan TEXT,
            FOREIGN KEY (patientId) REFERENCES patients (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }
}
