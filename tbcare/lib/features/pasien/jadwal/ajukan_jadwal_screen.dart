//features/pasien/jadwal/ajukan_jadwal_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/database/database_helper.dart'; // Import DatabaseHelper Anda

class AjukanJadwalScreen extends StatefulWidget {
  const AjukanJadwalScreen({super.key});

  @override
  State<AjukanJadwalScreen> createState() => _AjukanJadwalScreenState();
}

class _AjukanJadwalScreenState extends State<AjukanJadwalScreen> {
  DateTime _selectedDate = DateTime.now().add(
    const Duration(days: 1),
  ); // Default besok[cite: 22]
  String _selectedTime = '08:00'; // Default jam[cite: 22]
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
  ]; //[cite: 22]

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)), //[cite: 22]
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: TBCareTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked); //[cite: 22]
  }

  // Fungsi untuk menyimpan pengajuan jadwal ke dalam SQLite
  Future<void> _konfirmasi() async {
    setState(() => _isLoading = true); //[cite: 22]

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? patientId = prefs.getString('patient_id');

      if (patientId == null) {
        throw Exception('Sesi pasien tidak ditemukan. Silakan login kembali.');
      }

      final db = await DatabaseHelper().database;

      // Format tanggal menjadi string YYYY-MM-DD agar mudah di-query di SQLite
      final String tanggalStr = _selectedDate.toIso8601String().split('T')[0];

      // Insert data ke tabel appointments/jadwal konsultasi
      await db.insert('appointments', {
        'patient_id': patientId,
        'tanggal': tanggalStr,
        'jam': _selectedTime,
        'status':
            'Menunggu Konfirmasi', // Status awal pengajuan dari sisi pasien
        'keterangan': 'Pengajuan konsultasi rutin TBC',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return; //[cite: 22]
      setState(() => _isLoading = false); //[cite: 22]

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal berhasil diajukan'),
          backgroundColor: TBCareTheme.primary,
        ),
      ); //[cite: 22]

      // Kembali ke halaman utama jadwal pasien
      context.go(Routes.jadwalPasien); //[cite: 22]
    } catch (e) {
      debugPrint('Gagal mengajukan jadwal ke SQLite: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengajukan jadwal: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ]; //[cite: 22]

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), //[cite: 22]
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Ajukan Jadwal',
          style: TextStyle(
            color: TBCareTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: TBCareTheme.primary,
            size: 20,
          ),
          onPressed: () => context.go(Routes.jadwalPasien), //[cite: 22]
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100), //[cite: 22]
        children: [
          // Pilih Tanggal
          _SectionCard(
            title: 'Pilih Tanggal', //[cite: 22]
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickDate, //[cite: 22]
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ), //[cite: 22]
                    decoration: BoxDecoration(
                      color: TBCareTheme.primary.withOpacity(0.06), //[cite: 22]
                      borderRadius: BorderRadius.circular(12), //[cite: 22]
                      border: Border.all(
                        color: TBCareTheme.primary.withOpacity(0.3),
                      ), //[cite: 22]
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: TBCareTheme.primary,
                        ), //[cite: 22]
                        const SizedBox(width: 10), //[cite: 22]
                        Text(
                          '${_selectedDate.day} ${months[_selectedDate.month]} ${_selectedDate.year}', //[cite: 22]
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: TBCareTheme.primary,
                          ),
                        ),
                        const Spacer(), //[cite: 22]
                        const Icon(
                          Icons.arrow_drop_down,
                          color: TBCareTheme.primary,
                        ), //[cite: 22]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16), //[cite: 22]
          // Pilih Waktu
          _SectionCard(
            title: 'Pilih Waktu', //[cite: 22]
            child: Wrap(
              spacing: 8, //[cite: 22]
              runSpacing: 8, //[cite: 22]
              children: _timeSlots.map((t) {
                final isSelected = _selectedTime == t; //[cite: 22]
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = t), //[cite: 22]
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150), //[cite: 22]
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ), //[cite: 22]
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TBCareTheme.primary
                          : Colors.white, //[cite: 22]
                      borderRadius: BorderRadius.circular(10), //[cite: 22]
                      border: Border.all(
                        color: isSelected
                            ? TBCareTheme.primary
                            : const Color(0xFFE0E0E0), //[cite: 22]
                        width: isSelected ? 1.5 : 0.8, //[cite: 22]
                      ),
                    ),
                    child: Text(
                      t, //[cite: 22]
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF3D3D3D), //[cite: 22]
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16), //[cite: 22]
          // Info
          Container(
            padding: const EdgeInsets.all(14), //[cite: 22]
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1), //[cite: 22]
              borderRadius: BorderRadius.circular(12), //[cite: 22]
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start, //[cite: 22]
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Color(0xFFF57F17),
                ), //[cite: 22]
                SizedBox(width: 10), //[cite: 22]
                Expanded(
                  child: Text(
                    'Pastikan Anda datang 15 menit sebelum waktu konsultasi dimulai untuk proses administrasi ulang.', //[cite: 22]
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFF57F17),
                    ), //[cite: 22]
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Tombol konfirmasi fixed bawah
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28), //[cite: 22]
        decoration: const BoxDecoration(
          color: Colors.white, //[cite: 22]
          border: Border(
            top: BorderSide(color: Color(0xFFEEEEEE)),
          ), //[cite: 22]
        ),
        child: SizedBox(
          width: double.infinity, //[cite: 22]
          height: 52, //[cite: 22]
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _konfirmasi, //[cite: 22]
            style: ElevatedButton.styleFrom(
              backgroundColor: TBCareTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: TBCareTheme.primary.withOpacity(0.6),
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ) //[cite: 22]
                : const Icon(Icons.check_rounded, size: 18), //[cite: 22]
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

  const _SectionCard({required this.title, required this.child}); //[cite: 22]

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), //[cite: 22]
      decoration: BoxDecoration(
        color: Colors.white, //[cite: 22]
        borderRadius: BorderRadius.circular(16), //[cite: 22]
        border: Border.all(
          color: const Color(0xFFE8E8E8),
          width: 0.8,
        ), //[cite: 22]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, //[cite: 22]
        children: [
          Text(
            title, //[cite: 22]
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3D3D3D), //[cite: 22]
            ),
          ),
          const SizedBox(height: 14), //[cite: 22]
          child, //[cite: 22]
        ],
      ),
    );
  }
}
