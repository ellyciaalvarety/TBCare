// features/pasien/laporan_harian/laporan_screen.dart

import 'dart:convert'; // Wajib untuk fungsi jsonEncode
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tbcare/features/pasien/laporan_harian/widgets/gejala_selector.dart';
import 'package:tbcare/features/pasien/laporan_harian/widgets/catatan_input.dart';
import 'package:tbcare/shared/database/database_helper.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  // Status obat harian
  bool _semuaObatDiminum = false;

  // Gejala yang dipilih
  final List<String> _gejalaSelected = [];

  // Catatan teks tambahan
  String _catatan = '';

  // Mood / perasaan: 0=buruk, 1=biasa, 2=baik, 3=sangat baik
  int _moodIndex = -1;

  bool _isLoading = false;

  // Fungsi menyimpan data laporan harian ke tabel patient_reports di SQLite
  Future<void> _kirimLaporan() async {
    if (_moodIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kondisi perasaan Anda hari ini terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      // Mengambil email dari sesi login SharedPreferences
      final String? email = prefs.getString('email');

      if (email == null || email.trim().isEmpty) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }

      final db = await DatabaseHelper().database;
      final cleanEmail = email.trim().toLowerCase();

      // 1. Cari data user berdasarkan email yang sedang aktif login
      final List<Map<String, dynamic>> userCheck = await db.query(
        'users',
        where: 'LOWER(TRIM(email)) = ?',
        whereArgs: [cleanEmail],
      );

      if (userCheck.isEmpty) {
        throw Exception('Data akun tidak terdaftar di database.');
      }

      final int userId = userCheck.first['id'];

      // 2. Cari patientId asli dari relasi tabel patients
      final List<Map<String, dynamic>> patientCheck = await db.query(
        'patients',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      if (patientCheck.isEmpty) {
        throw Exception(
          'Profil data pasien Anda belum dikonfigurasi di database.',
        );
      }

      // Ambil ID Pasien sesungguhnya sebagai Foreign Key untuk tabel patient_reports
      final int originalPatientId = patientCheck.first['id'];

      // 3. Persiapkan format data waktu sesuai kebutuhan kolom tabel Anda
      final waktuSekarang = DateTime.now();

      // format tanggal: "YYYY-MM-DD"
      final String formatTanggal = waktuSekarang.toIso8601String().split(
        'T',
      )[0];

      // format bulan_tahun: "Juni 2026"
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final String formatBulanTahun =
          '${months[waktuSekarang.month - 1]} ${waktuSekarang.year}';

      // format jam_obat: "Obat jam 08:00" atau "Laporan jam 13:45"
      final String formatJamObat =
          'Laporan jam ${waktuSekarang.hour.toString().padLeft(2, '0')}:${waktuSekarang.minute.toString().padLeft(2, '0')}';

      // 4. Konversi data list ke format JSON String (karena tipe data kolom di SQLite Anda berupa TEXT)
      final String gejalaJson = jsonEncode(
        _gejalaSelected,
      ); // Hasil: '["Batuk","Demam"]'

      final String obatJson = jsonEncode({
        'semua_diminum': _semuaObatDiminum,
        'waktu_input': waktuSekarang.toIso8601String(),
      });

      // Menggabungkan keluhan teks dengan status indeks perasaan/mood pasien
      final String catatanFinal = _catatan.isEmpty
          ? 'Kondisi Perasaan: $_moodIndex'
          : '$_catatan (Mood: $_moodIndex)';

      // 5. Simpan (INSERT/REPLACE) data ke tabel patient_reports
      await db.insert('patient_reports', {
        'patientId': originalPatientId, // INTEGER
        'tanggal': formatTanggal, // TEXT
        'bulan_tahun': formatBulanTahun, // TEXT
        'jam_obat': formatJamObat, // TEXT
        'obat_list': obatJson, // TEXT (JSON String)
        'gejala_list': gejalaJson, // TEXT (JSON String)
        'catatan': catatanFinal, // TEXT
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan harian Anda berhasil disimpan!'),
            backgroundColor: TBCareTheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Kembali ke halaman beranda utama pasien
        context.go(Routes.pasienHome);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan laporan harian: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: TBCareTheme.primary,
            size: 20,
          ),
          onPressed: () => context.go(Routes.pasienHome),
        ),
        title: const Text(
          'Lapor Kondisi Harian',
          style: TextStyle(
            color: TBCareTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Kuesioner Obat ──
          _SectionCard(
            title: 'Kepatuhan Minum Obat',
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Apakah semua obat hari ini sudah diminum?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kejujuran Anda membantu pemulihan',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _semuaObatDiminum,
                  activeColor: TBCareTheme.primary,
                  onChanged: (val) {
                    setState(() => _semuaObatDiminum = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Kuesioner Gejala ──
          _SectionCard(
            title: 'Gejala yang Dirasakan',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih gejala yang Anda alami hari ini (bisa pilih lebih dari satu):',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                GejalaSelector(
                  selected: _gejalaSelected,
                  onChanged: (list) {
                    setState(() {
                      _gejalaSelected.clear();
                      _gejalaSelected.addAll(list);
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Kuesioner Mood / Kondisi Tubuh Secara Umum ──
          _SectionCard(
            title: 'Kondisi Tubuh Secara Umum',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bagaimana perasaan fisik/tubuh Anda secara keseluruhan hari ini?',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMoodItem(
                      0,
                      Icons.sentiment_very_dissatisfied_rounded,
                      'Buruk',
                      Colors.red,
                    ),
                    _buildMoodItem(
                      1,
                      Icons.sentiment_neutral_rounded,
                      'Biasa',
                      Colors.orange,
                    ),
                    _buildMoodItem(
                      2,
                      Icons.sentiment_satisfied_rounded,
                      'Baik',
                      Colors.blue,
                    ),
                    _buildMoodItem(
                      3,
                      Icons.sentiment_very_satisfied_rounded,
                      'Sangat Baik',
                      TBCareTheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Catatan Tambahan ──
          _SectionCard(
            title: 'Catatan Tambahan Keluhan',
            child: CatatanInput(
              initialValue: _catatan,
              onChanged: (text) {
                _catatan = text;
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
      bottomNavigationBar: _BottomKirim(
        isLoading: _isLoading,
        onKirim: _kirimLaporan,
      ),
    );
  }

  Widget _buildMoodItem(
    int index,
    IconData icon,
    String label,
    Color activeColor,
  ) {
    final isSelected = _moodIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _moodIndex = index),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withOpacity(0.12)
                  : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? activeColor : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: 28,
              color: isSelected ? activeColor : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? activeColor : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3D3D3D),
            ),
          ),
          const Divider(color: Color(0xFFEEEEEE), height: 20, thickness: 0.8),
          child,
        ],
      ),
    );
  }
}

class _BottomKirim extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onKirim;

  const _BottomKirim({required this.isLoading, required this.onKirim});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onKirim,
              style: ElevatedButton.styleFrom(
                backgroundColor: TBCareTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(isLoading ? 'Mengirim...' : 'Kirim Laporan Hari Ini'),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Data Anda hanya akan dilihat oleh dokter yang memantau.',
            style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }
}
