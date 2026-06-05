// features/pasien/jadwal/ajukan_jadwal_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/database/database_helper.dart';

class AjukanJadwalScreen extends StatefulWidget {
  const AjukanJadwalScreen({super.key});

  @override
  State<AjukanJadwalScreen> createState() => _AjukanJadwalScreenState();
}

class _AjukanJadwalScreenState extends State<AjukanJadwalScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1)); // Besok
  String _selectedTime = '08:00';
  bool _isLoading = false;

  static const _timeSlots = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
  ];

  Future<void> _konfirmasi() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('email');

      if (email == null || email.trim().isEmpty) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }

      final db = await DatabaseHelper().database;
      final cleanEmail = email.trim().toLowerCase();

      // 1. Cari user di tabel users
      final List<Map<String, dynamic>> userCheck = await db.query(
        'users',
        where: 'LOWER(TRIM(email)) = ?',
        whereArgs: [cleanEmail],
      );

      if (userCheck.isEmpty) {
        throw Exception('Data akun tidak terdaftar di database.');
      }

      final int userId = userCheck.first['id'];
      final String userName = userCheck.first['name'] ?? 'Pasien';

      // 2. Cari id asli dari tabel patients (sebagai Foreign Key)
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

      final int patientId = patientCheck.first['id'];
      final String tanggalStr = _selectedDate.toIso8601String().split('T')[0];
      final String appointmentId =
          'APT-${DateTime.now().millisecondsSinceEpoch}';

      // 3. INSERT sesuai skema tabel appointments di database Anda
      await db.insert('appointments', {
        'id': appointmentId, // TEXT PRIMARY KEY
        'patientName': userName, // TEXT
        'patientId': patientId, // INTEGER (FOREIGN KEY)
        'type': 'Konsultasi Rutin TBC', // TEXT
        'time':
            '$tanggalStr $_selectedTime', // TEXT (Format gabungan YYYY-MM-DD HH:MM)
        'room': 'Menunggu Konfirmasi', // TEXT
        'isCompleted': 0, // INTEGER (0 = Belum selesai)
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal konsultasi berhasil diajukan!'),
          backgroundColor: TBCareTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Kembali menggunakan go router rute jadwal pasien
      context.go(Routes.jadwalPasien);
    } catch (e) {
      debugPrint('Gagal mengajukan jadwal ke SQLite: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengajukan: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: TBCareTheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
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
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.go(Routes.jadwalPasien),
        ),
        title: const Text(
          'Ajukan Jadwal Konsultasi',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              title: 'Pilih Tanggal Konsultasi',
              child: Material(
                color: Colors
                    .transparent, // Mengatasi linter: ListTile background color
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: TBCareTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: TBCareTheme.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: const Text(
                    'Ketuk untuk mengubah tanggal',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                  ),
                  onTap: () => _selectDate(context),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Pilih Jam Konsultasi',
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _timeSlots.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final time = _timeSlots[index];
                  final isSelected = _selectedTime == time;
                  return InkWell(
                    onTap: () => setState(() => _selectedTime = time),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? TBCareTheme.primary
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? TBCareTheme.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _konfirmasi,
            style: ElevatedButton.styleFrom(
              backgroundColor: TBCareTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 18),
            label: const Text(
              'Konfirmasi Jadwal',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
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
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
