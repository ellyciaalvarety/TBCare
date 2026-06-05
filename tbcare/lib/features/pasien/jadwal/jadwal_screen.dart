//features/pasien/jadwal/jadwal_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/database/database_helper.dart'; // Sesuaikan lokasi DatabaseHelper

// Model Data Janji Temu Pasien
class JadwalPasienItem {
  final int? id;
  final String tanggal; // Format: YYYY-MM-DD
  final String jam;
  final String
  status; // 'Mendatang', 'Selesai', 'Menunggu Konfirmasi', 'Dibatalkan'
  final String keterangan;

  const JadwalPasienItem({
    this.id,
    required this.tanggal,
    required this.jam,
    required this.status,
    required this.keterangan,
  });

  factory JadwalPasienItem.fromMap(Map<String, dynamic> map) {
    return JadwalPasienItem(
      id: map['id'],
      tanggal: map['tanggal'] ?? '',
      jam: map['jam'] ?? '',
      status: map['status'] ?? 'Menunggu Konfirmasi',
      keterangan: map['keterangan'] ?? '',
    );
  }
}

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<JadwalPasienItem> _allJadwal = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDataJadwal();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mengambil riwayat jadwal dari SQLite berdasarkan pasien yang sedang login
  Future<void> _loadDataJadwal() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? patientId = prefs.getString('patient_id');

      if (patientId != null) {
        final db = await DatabaseHelper().database;
        // Ambil data janji temu diurutkan dari yang paling baru diajukan/dijadwalkan
        final List<Map<String, dynamic>> maps = await db.query(
          'appointments',
          where: 'patient_id = ?',
          whereArgs: [patientId],
          orderBy: 'tanggal DESC, jam DESC',
        );

        setState(() {
          _allJadwal = maps
              .map((item) => JadwalPasienItem.fromMap(item))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat jadwal pasien: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter kategori jadwal aktif (Menunggu Konfirmasi & Mendatang)
    final jadwalAktif = _allJadwal
        .where(
          (j) => j.status == 'Mendatang' || j.status == 'Menunggu Konfirmasi',
        )
        .toList();

    // Filter kategori riwayat (Selesai & Dibatalkan)
    final riwayatJadwal = _allJadwal
        .where((j) => j.status == 'Selesai' || j.status == 'Dibatalkan')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Jadwal Konsultasi',
          style: TextStyle(
            color: TBCareTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: TBCareTheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: TBCareTheme.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Jadwal Aktif'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: TBCareTheme.primary),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildJadwalList(jadwalAktif, isAktifTab: true),
                _buildJadwalList(riwayatJadwal, isAktifTab: false),
              ],
            ),
      // Tombol mengambang untuk mengajukan jadwal baru
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(
          Routes.ajukanJadwal,
        ), // Rute mengarah ke halaman AjukanJadwalScreen
        backgroundColor: TBCareTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Ajukan Jadwal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildJadwalList(
    List<JadwalPasienItem> list, {
    required bool isAktifTab,
  }) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAktifTab
                  ? Icons.calendar_today_outlined
                  : Icons.history_rounded,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              isAktifTab
                  ? 'Tidak ada jadwal konsultasi aktif'
                  : 'Belum ada riwayat konsultasi',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        80,
      ), // Padding bawah longgar agar tidak tertutup FAB
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return _JadwalCard(item: item);
      },
    );
  }
}

class _JadwalCard extends StatelessWidget {
  final JadwalPasienItem item;

  const _JadwalCard({required this.item});

  // Fungsi helper memformat tampilan tanggal mentah YYYY-MM-DD menjadi format lokal ramah dibaca
  String _formatTanggalLokal(String rawDate) {
    try {
      final parsed = DateTime.parse(rawDate);
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
      return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
    } catch (_) {
      return rawDate;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Mendatang':
        return TBCareTheme.primary;
      case 'Menunggu Konfirmasi':
        return const Color(0xFFF57F17); // Oranye peringatan
      case 'Selesai':
        return Colors.green;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(item.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Garis vertikal dekorasi indikator status di sisi paling kiri card
              Container(width: 5, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Badge indikator status peninjauan jadwal
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: statusColor.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              item.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                          // Waktu Jam Pelaksanaan
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item.jam} WIB',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF555555),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Tanggal Agenda Konsultasi
                      Text(
                        _formatTanggalLokal(item.tanggal),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Deskripsi/Keterangan Keperluan Janji Temu
                      Text(
                        item.keterangan,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
