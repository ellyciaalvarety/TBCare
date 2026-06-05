//features/medis/patients/patient_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/widgets/kepatuhan_chart.dart';
import 'package:tbcare/shared/database/database_helper.dart'; // Import DatabaseHelper Anda

class PatientDetailScreen extends StatefulWidget {
  final String patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  bool _isLoading = true;

  // State Data Pasien
  String _namaPasien = 'Memuat...';
  String _risikoText = 'stabil';
  Color _risikoColor = TBCareTheme.stabil;

  // State Jadwal Obat & Konsultasi
  List<Map<String, dynamic>> _obatList = [];
  Map<String, dynamic>? _nextAppointment;

  // State List Data untuk Grafik Garis Kepatuhan (30 hari terakhir)
  List<double> _kepatuhanDataHistory = [];

  @override
  void initState() {
    super.initState();
    _loadAllPatientData();
  }

  Future<void> _loadAllPatientData() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper().database;

      // 1. Ambil Profil Medis Pasien
      final List<Map<String, dynamic>> patientQuery = await db.query(
        'patients',
        where: 'id = ?',
        whereArgs: [widget.patientId],
      );

      if (patientQuery.isNotEmpty) {
        final p = patientQuery.first;
        _namaPasien = p['nama'] ?? 'Pasien Baru';

        // Memetakan Teks Risiko & Warna dari SQLite
        final String risikoRaw = p['risiko'] ?? 'PasienRisiko.stabil';
        if (risikoRaw.contains('risikoTinggi')) {
          _risikoText = 'Risiko Tinggi';
          _risikoColor = TBCareTheme.risikoTinggi;
        } else if (risikoRaw.contains('perlaPantauan')) {
          _risikoText = 'Perlu Pantauan';
          _risikoColor = TBCareTheme.perlaPantauan;
        } else {
          _risikoText = 'Stabil';
          _risikoColor = TBCareTheme.stabil;
        }
      }

      // 2. Ambil Riwayat Laporan Harian untuk diumpankan ke Grafik Garis Kepatuhan
      // Kita mengambil data laporan dari `patient_reports` (maksimal 30 entri terakhir)
      final List<Map<String, dynamic>> reportsQuery = await db.query(
        'patient_reports',
        where: 'patientId = ?',
        whereArgs: [widget.patientId],
        orderBy:
            'id ASC', // Diurutkan maju agar grafik digambar dari kiri (lama) ke kanan (baru)
        limit: 30,
      );

      if (reportsQuery.isNotEmpty) {
        _kepatuhanDataHistory = reportsQuery.map((report) {
          // Logika Penentuan Nilai: Jika tidak ada obat yang terlewat, beri nilai penuh (1.0)
          // Jika ada indikasi terlewat, kita asumsikan nilainya turun (misal 0.5 atau 0.0)
          final String jamObat = report['jam_obat']?.toString() ?? '';
          if (jamObat.contains('Terlewat')) {
            return 0.5;
          }
          return 1.0;
        }).toList();
      } else {
        // Jika data di database kosong, gunakan fallback list kosong agar KepatuhanChart memakai data default internalnya
        _kepatuhanDataHistory = [];
      }

      // 3. Ambil Daftar Jadwal Obat Pasien
      _obatList = await db.query(
        'schedules',
        where: 'patientId = ?',
        whereArgs: [widget.patientId],
      );

      // 4. Ambil Jadwal Konsultasi Terdekat yang Belum Selesai (isCompleted = 0)
      final List<Map<String, dynamic>> appointmentQuery = await db.query(
        'appointments',
        where: 'patientId = ? AND isCompleted = 0',
        whereArgs: [widget.patientId],
        orderBy: 'id ASC',
        limit: 1,
      );

      if (appointmentQuery.isNotEmpty) {
        _nextAppointment = appointmentQuery.first;
      } else {
        _nextAppointment = null;
      }
    } catch (e) {
      debugPrint("Gagal memuat detail data pasien: $e");
    } finally {
      setState(() => _isLoading = false);
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
          onPressed: () => context.go(Routes.patients),
        ),
        title: const Text(
          'Pasien',
          style: TextStyle(
            color: TBCareTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF0F0F0)),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: TBCareTheme.primary),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                // Card Profil Utama Pasien & Modul Grafik Kepatuhan
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: TBCareTheme.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _namaPasien,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'PID: ${widget.patientId}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _risikoColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              _risikoText,
                              style: TextStyle(
                                color: _risikoColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 20),

                      // Bagian Kepatuhan Terintegrasi dengan Line Chart asli bawaan file Anda
                      const Text(
                        'Tingkat Kepatuhan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Persentase konsumsi obat teratur 30 hari terakhir.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pemasangan KepatuhanChart asli dengan menyuplai List<double> history
                      SizedBox(
                        width: double.infinity,
                        height:
                            140, // Memberikan ruang tinggi yang cukup untuk render grafik garis kustom
                        child: KepatuhanChart(
                          data: _kepatuhanDataHistory.isNotEmpty
                              ? _kepatuhanDataHistory
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Card Navigasi Riwayat Laporan Harian
                _buildMenuRowCard(
                  icon: Icons.history_edu_rounded,
                  title: 'Riwayat Laporan Pasien',
                  subtitle: 'Lihat kepatuhan & gejala harian',
                  onTap: () =>
                      context.go('/medis/patients/${widget.patientId}/riwayat'),
                ),

                const SizedBox(height: 20),

                // Card Header & List Jadwal Minum Obat
                _buildSectionHeader(
                  title: 'Jadwal Obat',
                  actionLabel: 'Edit',
                  onActionTap: () => context.go(
                    '/medis/patients/${widget.patientId}/edit-obat',
                  ),
                ),
                const SizedBox(height: 10),
                _buildJadwalObatSection(),

                const SizedBox(height: 24),

                // Card Header & Tampilan Konsultasi Selanjutnya
                _buildSectionHeader(
                  title: 'Konsultasi Selanjutnya',
                  actionLabel: 'Ajukan',
                  onActionTap: () => context.go(
                    '/medis/patients/${widget.patientId}/ajukan-jadwal',
                  ),
                ),
                const SizedBox(height: 10),
                _buildKonsultasiSection(),
              ],
            ),
    );
  }

  Widget _buildMenuRowCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: TBCareTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: TBCareTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFFBBBBBB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionLabel,
    required VoidCallback onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        GestureDetector(
          onTap: onActionTap,
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TBCareTheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJadwalObatSection() {
    if (_obatList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'Belum ada jadwal obat yang diatur.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    final String jamMinum = _obatList.first['time'] ?? '18:00';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: Color(0xFF6B6B6B),
              ),
              const SizedBox(width: 6),
              Text(
                'Setiap jam $jamMinum',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3D3D3D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._obatList.map((obat) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.medication_rounded,
                    size: 16,
                    color: TBCareTheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      obat['medicineName'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  Text(
                    "${obat['dosage']} • ${obat['instruction'] ?? 'Sebelum'}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildKonsultasiSection() {
    if (_nextAppointment == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'Tidak ada jadwal konsultasi terdekat.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    final String agenda = _nextAppointment!['type'] ?? 'Konsultasi Medis';
    final String waktu = _nextAppointment!['time'] ?? '';
    final String ruangan = _nextAppointment!['room'] ?? '-';

    return _AppointmentCard(
      label: 'KONSULTASI MEDIS',
      badgeText: 'Mendatang',
      badgeBg: const Color(0xFFE8F5E9),
      badgeTextColor: TBCareTheme.primary,
      tanggal: waktu,
      ruangan: 'Ruangan: $ruangan — $agenda',
      textColor: TBCareTheme.primary,
      bgColor: Colors.white,
    );
  }
}

// ── Widget Card Janji Temu Komponen ─────────────────────────────────────
class _AppointmentCard extends StatelessWidget {
  final String label;
  final String badgeText;
  final Color badgeBg;
  final Color badgeTextColor;
  final String tanggal;
  final String ruangan;
  final Color textColor;
  final Color bgColor;

  const _AppointmentCard({
    required this.label,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeTextColor,
    required this.tanggal,
    required this.ruangan,
    required this.textColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
            child: Icon(
              Icons.calendar_today_rounded,
              color: badgeTextColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: textColor.withOpacity(0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tanggal,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ruangan,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
