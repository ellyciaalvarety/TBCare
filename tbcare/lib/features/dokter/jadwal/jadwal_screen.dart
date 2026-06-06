//features/dokter/jadwal/jadwal_screen.dart

import 'package:flutter/material.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/widgets/tbcare_app_bar.dart';
import 'package:tbcare/shared/database/database_helper.dart';

class Appointment {
  final String id;
  final String patientName;
  final String patientId; // Tetap String di model UI tidak apa-apa
  final String type;
  final String time;
  final String room;
  bool isCompleted;

  Appointment({
    required this.id,
    required this.patientName,
    required this.patientId,
    required this.type,
    required this.time,
    required this.room,
    this.isCompleted = false,
  });

  // Helper untuk konversi dari Map SQLite ke objek Appointment
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'].toString(),
      patientName: map['patientName'] ?? '',
      // PERBAIKAN: Ditambahkan .toString() karena di database bertipe INTEGER
      patientId: map['patientId'] != null ? map['patientId'].toString() : '',
      type: map['type'] ?? '',
      time: map['time'] ?? '',
      room: map['room'] ?? '',
      isCompleted:
          map['isCompleted'] == 1, // SQLite menyimpan boolean sebagai 0 atau 1
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
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil data dari SQLite
  Future<void> _loadAppointments() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper().database;

      // Ambil semua data dari tabel appointments
      final List<Map<String, dynamic>> maps = await db.query('appointments');

      if (mounted) {
        setState(() {
          _appointments = maps.map((map) => Appointment.fromMap(map)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat jadwal: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Fungsi untuk mengubah status isCompleted di SQLite
  Future<void> _markAsCompleted(String id) async {
    try {
      final db = await DatabaseHelper().database;

      // Update kolom isCompleted menjadi 1 (true) berdasarkan id
      await db.update(
        'appointments',
        {'isCompleted': 1},
        where: 'id = ?',
        whereArgs: [id],
      );

      // Refresh data dari database untuk memperbarui UI
      await _loadAppointments();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konsultasi telah selesai'),
          backgroundColor: TBCareTheme.primary,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmAppointment(String id) async {
    try {
      final db = await DatabaseHelper().database;

      await db.update(
        'appointments',
        {'room': 'Dikonfirmasi oleh Nakes'},
        where: 'id = ?',
        whereArgs: [id],
      );

      await _loadAppointments();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal berhasil dikonfirmasi'),
          backgroundColor: TBCareTheme.primary,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengonfirmasi jadwal: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _rejectAppointment(String id) async {
    try {
      final db = await DatabaseHelper().database;

      await db.update(
        'appointments',
        {'room': 'Ditolak oleh Nakes', 'isCompleted': 1},
        where: 'id = ?',
        whereArgs: [id],
      );

      await _loadAppointments();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal berhasil ditolak'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menolak jadwal: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeAppointments = _appointments
        .where((a) => a.isCompleted == false)
        .toList();
    final historyAppointments = _appointments
        .where((a) => a.isCompleted == true)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Jadwal Konsultasi',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: TBCareTheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: TBCareTheme.primary,
          tabs: const [
            Tab(text: 'Aktif'),
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
                activeAppointments.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada jadwal aktif saat ini.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: activeAppointments.length,
                        itemBuilder: (_, i) =>
                            _buildAppointmentCard(activeAppointments[i]),
                      ),
                historyAppointments.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada jadwal riwayat.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: historyAppointments.length,
                        itemBuilder: (_, i) =>
                            _buildAppointmentCard(historyAppointments[i]),
                      ),
              ],
            ),
    );
  }

  Color _getStatusColor(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized.contains('menunggu konfirmasi'))
      return const Color(0xFFF57F17);
    if (normalized.contains('dikonfirmasi')) return Colors.green;
    if (normalized.contains('ditolak') || normalized.contains('batal'))
      return Colors.red;
    if (normalized.contains('selesai')) return Colors.green;
    return Colors.grey.shade700;
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PID: ${appointment.patientId}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (appointment.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F7F3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      color: TBCareTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            appointment.type,
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                appointment.time,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                appointment.room,
                style: TextStyle(
                  fontSize: 16,
                  color: _getStatusColor(appointment.room),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (!appointment.isCompleted)
            appointment.room.toLowerCase().contains('menunggu konfirmasi')
                ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _confirmAppointment(appointment.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A9E8F),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Konfirmasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _rejectAppointment(appointment.id),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Tolak',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _markAsCompleted(appointment.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TBCareTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Selesai',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
