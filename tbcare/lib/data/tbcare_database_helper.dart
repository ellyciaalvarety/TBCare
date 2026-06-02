import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TBCareDatabaseHelper {
  static final TBCareDatabaseHelper instance = TBCareDatabaseHelper._init();
  static Database? _database;

  TBCareDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tbcare.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. TABEL USER (Pasien & Nakes)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pid TEXT NOT NULL,
        name TEXT NOT NULL,
        role TEXT NOT NULL, -- 'pasien' atau 'nakes'
        birth_date TEXT,
        gender TEXT,
        phone TEXT,
        email TEXT,
        password TEXT,
        fase TEXT,          -- Khusus Pasien: misal 'Intensif'
        hari_ke INTEGER     -- Khusus Pasien: misal 42
      )
    ''');

    // 2. TABEL OBAT YANG DIJADWALKAN
    await db.execute('''
      CREATE TABLE medications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER, -- Terhubung ke tabel users (pasien)
        name TEXT NOT NULL,
        dose TEXT,       -- misal '1 Tablet', '1 Kapsul'
        rule TEXT,       -- misal 'Sebelum Makan', 'Sesudah Makan'
        time_to_take TEXT, -- misal '08:00', '18:00'
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 3. TABEL LAPORAN KONDISI & GEJALA HARIAN
    await db.execute('''
      CREATE TABLE daily_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        date TEXT NOT NULL,        -- Format: YYYY-MM-DD
        condition TEXT NOT NULL,   -- 'Buruk', 'Biasa', 'Baik', 'Sangat Baik'
        has_batuk INTEGER,         -- 1 jika true, 0 jika false
        has_demam INTEGER,
        has_nafsu_kurang INTEGER,
        has_sesak_nafas INTEGER,
        has_keringat_malam INTEGER,
        notes TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 4. TABEL LOG MINUM OBAT (Untuk hitung persentase kepatuhan)
    await db.execute('''
      CREATE TABLE medication_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        medication_id INTEGER,
        date TEXT NOT NULL,        -- Format: YYYY-MM-DD
        time_taken TEXT,           -- Jam aktual diminum
        status TEXT NOT NULL,      -- 'Diminum' atau 'Terlewat'
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (medication_id) REFERENCES medications (id)
      )
    ''');

    // 5. TABEL JADWAL KONSULTASI / PERTEMUAN
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER,
        agenda TEXT NOT NULL,       -- 'Konsultasi', 'Test Review', dll
        date TEXT NOT NULL,         -- Format: YYYY-MM-DD
        time_start TEXT NOT NULL,   -- misal '08:30'
        time_end TEXT NOT NULL,     -- misal '10:00'
        room TEXT NOT NULL,         -- misal 'A 3.05'
        status TEXT NOT NULL,       -- 'Mendatang', 'Selesai', 'Terlewat'
        is_from_hospital INTEGER DEFAULT 0, -- 1 jika dari RS (ada tag merah)
        FOREIGN KEY (patient_id) REFERENCES users (id)
      )
    ''');
  }

  // =========================================================================
  // OPERASI RELEVAN UNTUK SCREEN MOCKUP ANDA
  // =========================================================================

  // --- Fungsi untuk HomeScreen & RiwayatScreen (Menghitung % Kepatuhan) ---
  Future<double> getComplianceRate(int userId) async {
    final db = await instance.database;
    // Hitung total obat yang harusnya diminum vs yang benar-benar diminum
    final total = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM medication_logs WHERE user_id = ?', [userId])) ?? 0;
    final diminum = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM medication_logs WHERE user_id = ? AND status = "Diminum"', [userId])) ?? 0;
    
    if (total == 0) return 100.0;
    return (diminum / total) * 100;
  }

  // --- Fungsi untuk TanggapanScreen (Input Kondisi Harian) ---
  Future<int> insertDailyReport(Map<String, dynamic> reportMap) async {
    final db = await instance.database;
    return await db.insert('daily_reports', reportMap);
  }

  // --- Fungsi untuk JadwalScreen (Ambil jadwal Mendatang / Selesai) ---
  Future<List<Map<String, dynamic>>> getSchedulesByStatus(int userId, String status) async {
    final db = await instance.database;
    return await db.query(
      'schedules',
      where: 'patient_id = ? AND status = ?',
      whereArgs: [userId, status],
      orderBy: 'date ASC',
    );
  }

  // --- Fungsi untuk AjukanJadwalScreen & RescheduleScreen ---
  Future<int> insertSchedule(Map<String, dynamic> scheduleMap) async {
    final db = await instance.database;
    return await db.insert('schedules', scheduleMap);
  }

  Future<int> updateScheduleTime(int scheduleId, String newDate, String newTimeStart, String newTimeEnd) async {
    final db = await instance.database;
    return await db.update(
      'schedules',
      {
        'date': newDate,
        'time_start': newTimeStart,
        'time_end': newTimeEnd,
        'status': 'Mendatang'
      },
      where: 'id = ?',
      whereArgs: [scheduleId],
    );
  }

  // --- Fungsi untuk ProfilScreen & EditProfilScreen ---
  Future<Map<String, dynamic>?> getUserProfile(int userId) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<int> updateUserProfile(int userId, Map<String, dynamic> updateData) async {
    final db = await instance.database;
    return await db.update('users', updateData, where: 'id = ?', whereArgs: [userId]);
  }

  // --- SISI NAKES: PatientsScreen (Ambil daftar semua pasien beserta kepatuhannya) ---
  Future<List<Map<String, dynamic>>> getPatientsForNakes() async {
    final db = await instance.database;
    // Query ini mengambil data pasien sekaligus menghitung rata-rata kepatuhannya secara real-time
    return await db.rawQuery('''
      SELECT u.id, u.pid, u.name, u.fase, u.hari_ke,
             (SELECT COUNT(*) FROM daily_reports WHERE user_id = u.id) as total_laporan,
             COALESCE(
               (CAST((SELECT COUNT(*) FROM medication_logs WHERE user_id = u.id AND status = 'Diminum') AS REAL) / 
                CAST(NULLIF((SELECT COUNT(*) FROM medication_logs WHERE user_id = u.id), 0) AS REAL)) * 100, 
               0
             ) as kepatuhan
      FROM users u 
      WHERE u.role = 'pasien'
    ''');
  }

  // --- SISI NAKES: EditJadwalObatScreen ---
  Future<int> insertOrUpdateMedication(Map<String, dynamic> medData) async {
    final db = await instance.database;
    if (medData['id'] != null) {
      return await db.update('medications', medData, where: 'id = ?', whereArgs: [medData['id']]);
    } else {
      return await db.insert('medications', medData);
    }
  }
}