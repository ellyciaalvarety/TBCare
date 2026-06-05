// features/pasien/jadwal/jadwal_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/database/database_helper.dart';

class JadwalPasienItem {
  final String id;
  final String tanggalJam;
  final String status;
  final String tipeKonsul;
  final int isCompleted;

  const JadwalPasienItem({
    required this.id,
    required this.tanggalJam,
    required this.status,
    required this.tipeKonsul,
    required this.isCompleted,
  });

  factory JadwalPasienItem.fromMap(Map<String, dynamic> map) {
    // Kita cetak log ke console untuk melihat isi asli data dari DB Anda
    debugPrint("=== DATA DARI DATABASE ===");
    debugPrint(
      "ID: ${map['id']}, Time: ${map['time']}, Room/Status: ${map['room']}, IsCompleted: ${map['isCompleted']}",
    );

    return JadwalPasienItem(
      id: map['id']?.toString() ?? '',
      tanggalJam: map['time']?.toString() ?? '',
      status: map['room']?.toString() ?? 'Menunggu Konfirmasi',
      tipeKonsul: map['type']?.toString() ?? 'Konsultasi Rutin TBC',
      isCompleted: map['isCompleted'] is int ? map['isCompleted'] : 0,
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

  Future<void> _loadDataJadwal() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final db = await DatabaseHelper().database;

      // BYPASS: Kita ambil SEMUA data dari tabel appointments tanpa filter patientId!
      final List<Map<String, dynamic>> maps = await db.query(
        'appointments',
        orderBy: 'time DESC',
      );

      // Cetak ke log untuk melihat isi data aslinya di Run/Debug Console
      debugPrint("===============================================");
      debugPrint("TOTAL DATA DI TABEL APPOINTMENTS: ${maps.length} BARIS");
      for (var row in maps) {
        debugPrint(
          "Isi Baris DB -> ID: ${row['id']}, patientId di DB: ${row['patientId']}, Nama: ${row['patientName']}, Jam: ${row['time']}",
        );
      }
      debugPrint("===============================================");

      if (mounted) {
        setState(() {
          _allJadwal = maps
              .map((item) => JadwalPasienItem.fromMap(item))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Terjadi error saat load data SQLite: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // KITA LONGGARKAN FILTERNYA:
    // Tab Aktif: Menampilkan semua data yang 'isCompleted == 0' tanpa peduli teks statusnya apa
    final jadwalAktif = _allJadwal.where((j) => j.isCompleted == 0).toList();

    // Tab Riwayat: Menampilkan data yang sudah ditandai selesai
    final riwayatJadwal = _allJadwal.where((j) => j.isCompleted == 1).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(Routes.ajukanJadwal),
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

    return RefreshIndicator(
      onRefresh: _loadDataJadwal,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: list.length,
        itemBuilder: (context, index) => _JadwalCard(item: list[index]),
      ),
    );
  }
}

class _JadwalCard extends StatelessWidget {
  final JadwalPasienItem item;
  const _JadwalCard({required this.item});

  String _getTanggalLokal(String rawDateTime) {
    try {
      final String datePart = rawDateTime.split(' ')[0];
      final parsed = DateTime.parse(datePart);
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
      return rawDateTime;
    }
  }

  String _getJamMenit(String rawDateTime) {
    try {
      final List<String> parts = rawDateTime.split(' ');
      if (parts.length > 1) return parts[1];
    } catch (_) {}
    return '--:--';
  }

  Color _getStatusColor(String status) {
    // Normalisasi string status agar tidak sensitif huruf besar-kecil
    final normalized = status.trim().toLowerCase();
    if (normalized.contains('mendatang')) return TBCareTheme.primary;
    if (normalized.contains('konfirmasi')) return const Color(0xFFF57F17);
    if (normalized.contains('selesai')) return Colors.green;
    if (normalized.contains('batal')) return Colors.red;
    return Colors.grey;
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
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_getJamMenit(item.tanggalJam)} WIB',
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
                      Text(
                        _getTanggalLokal(item.tanggalJam),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.tipeKonsul,
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
