//features/medis/patients/laporan_pasien_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/database/database_helper.dart'; // Import DatabaseHelper Anda

class LaporanPasienScreen extends StatefulWidget {
  final String patientId;
  const LaporanPasienScreen({super.key, required this.patientId});

  @override
  State<LaporanPasienScreen> createState() => _LaporanPasienScreenState();
}

class _LaporanPasienScreenState extends State<LaporanPasienScreen> {
  List<Map<String, dynamic>> _riwayatLaporan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRiwayatLaporan();
  }

  // Fungsi untuk mengambil daftar riwayat laporan harian dari SQLite
  Future<void> _loadRiwayatLaporan() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper().database;

      // Ambil riwayat laporan milik pasien ini, diurutkan dari tanggal terbaru (Descending)
      final List<Map<String, dynamic>> results = await db.query(
        'patient_reports',
        where: 'patientId = ?',
        whereArgs: [widget.patientId],
        orderBy:
            'id DESC', // Menggunakan ID auto-increment untuk urutan input terbaru
      );

      setState(() {
        _riwayatLaporan = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Gagal memuat riwayat laporan: $e");
    }
  }

  // Helper untuk menentukan nama hari fungsional/lokal (Opsional)
  String _determineHariLabel(String tanggalStr) {
    try {
      final hariIni = DateTime.now().day.toString();
      if (tanggalStr == hariIni) return 'Hari Ini';

      // Jika Anda menyimpan data DateTime lengkap di database,
      // Anda bisa memformatnya menjadi nama hari asli (Senin, Selasa, dll.)
      return 'Laporan Harian';
    } catch (_) {
      return 'Laporan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F7F6),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: TBCareTheme.primary,
            size: 20,
          ),
          onPressed: () => context.go('/medis/patients/${widget.patientId}'),
        ),
        title: const Text(
          'Riwayat Laporan',
          style: TextStyle(
            color: TBCareTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: TBCareTheme.primary),
            )
          : _riwayatLaporan.isEmpty
          ? const Center(
              child: Text(
                'Belum ada riwayat laporan dari pasien ini.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _riwayatLaporan.length,
              itemBuilder: (context, index) {
                final laporan = _riwayatLaporan[index];

                // Ekstraksi data dari kolom SQLite
                final String tgl = laporan['tanggal'] ?? '01';
                final String bln = (laporan['bulan_tahun'] ?? 'MEI')
                    .split(' ')[0]
                    .toUpperCase();
                final String labelHari = _determineHariLabel(tgl);

                // Cek status kepatuhan dari catatan obat (misal jika ada obat terlewat)
                // Anda bisa menyesuaikan logika penentuan teks status ini sesuai kebutuhan
                final bool isOk = !laporan['jam_obat'].toString().contains(
                  'Terlewat',
                );
                final String keterangan = isOk
                    ? 'Obat Diminum'
                    : 'Dosis Terlewat';

                return _buildRiwayatCard(
                  context: context,
                  tanggal: tgl,
                  bulan: bln,
                  hari: labelHari,
                  isOk: isOk,
                  keterangan: keterangan,
                );
              },
            ),
    );
  }

  Widget _buildRiwayatCard({
    required BuildContext context,
    required String tanggal,
    required String bulan,
    required String hari,
    required bool isOk,
    required String keterangan,
  }) {
    return GestureDetector(
      // Navigasi dinamis menuju halaman detail laporan berdasarkan tanggal riwayat yang diklik
      onTap: () =>
          context.go('/medis/patients/${widget.patientId}/riwayat/$tanggal'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Indikator Tanggal Kotak Kiri
            Container(
              width: 50,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tanggal,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      height: 1.1,
                    ),
                  ),
                  Text(
                    bulan,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Informasi Status Tengah
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hari,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isOk
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: 15,
                        color: isOk
                            ? TBCareTheme.primary
                            : const Color(0xFFE53935),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        keterangan,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isOk
                              ? TBCareTheme.primary
                              : const Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }
}
