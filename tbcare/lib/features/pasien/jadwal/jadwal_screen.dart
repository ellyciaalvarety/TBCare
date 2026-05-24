import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';

// Model sementara — nanti pindah ke data/models/jadwal_model.dart
class JadwalItem {
  final String id;
  final String tanggal;
  final String bulan;
  final String tahun;
  final String agenda;
  final String jamMulai;
  final String jamSelesai;
  final String ruangan;
  final JadwalStatus status;
  final bool dariRumahSakit;

  const JadwalItem({
    required this.id,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
    required this.agenda,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruangan,
    required this.status,
    this.dariRumahSakit = false,
  });
}

enum JadwalStatus { mendatang, selesai, terlewat }

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // TODO: ganti dengan data dari JadwalBloc
  final List<JadwalItem> _jadwalList = const [
    JadwalItem(
      id: '1',
      tanggal: '24',
      bulan: 'OKT',
      tahun: '2023',
      agenda: 'Konsultasi',
      jamMulai: '08:30',
      jamSelesai: '10:00',
      ruangan: 'A 3.05',
      status: JadwalStatus.selesai,
    ),
    JadwalItem(
      id: '2',
      tanggal: '02',
      bulan: 'NOV',
      tahun: '2023',
      agenda: 'Test Review',
      jamMulai: '11:00',
      jamSelesai: '12:00',
      ruangan: 'Ruang 3.06',
      status: JadwalStatus.mendatang,
      dariRumahSakit: true,
    ),
    JadwalItem(
      id: '3',
      tanggal: '24',
      bulan: 'OKT',
      tahun: '2023',
      agenda: 'Konsultasi',
      jamMulai: '08:30',
      jamSelesai: '10:00',
      ruangan: 'A 3.05',
      status: JadwalStatus.terlewat,
    ),
    JadwalItem(
      id: '4',
      tanggal: '15',
      bulan: 'NOV',
      tahun: '2023',
      agenda: 'Kontrol Bulanan',
      jamMulai: '09:00',
      jamSelesai: '09:30',
      ruangan: 'A 3.05',
      status: JadwalStatus.mendatang,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<JadwalItem> get _mendatang => _jadwalList
      .where((j) => j.status == JadwalStatus.mendatang)
      .toList();

  List<JadwalItem> get _selesai => _jadwalList
      .where((j) =>
          j.status == JadwalStatus.selesai ||
          j.status == JadwalStatus.terlewat)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            const Icon(
              Icons.health_and_safety_rounded,
              color: TBCareTheme.primary,
              size: 22,
            ),
            const SizedBox(width: 8),
            const Text(
              'TBCare',
              style: TextStyle(
                color: TBCareTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: TBCareTheme.primary,
          labelColor: TBCareTheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Mendatang'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(Routes.ajukanJadwal),
        backgroundColor: TBCareTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Mendatang
          _JadwalTabView(
            items: _mendatang,
            emptyMessage: 'Belum ada jadwal mendatang',
            emptyIcon: Icons.calendar_month_outlined,
            onReschedule: _showRescheduleSheet,
          ),
          // Tab Selesai
          _JadwalTabView(
            items: _selesai,
            emptyMessage: 'Belum ada riwayat jadwal',
            emptyIcon: Icons.history,
            onReschedule: _showRescheduleSheet,
          ),
        ],
      ),
    );
  }

  void _showRescheduleSheet(JadwalItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RescheduleSheet(item: item),
    );
  }
}

// ── Tab view ──────────────────────────────────────────────────────
class _JadwalTabView extends StatelessWidget {
  final List<JadwalItem> items;
  final String emptyMessage;
  final IconData emptyIcon;
  final ValueChanged<JadwalItem> onReschedule;

  const _JadwalTabView({
    required this.items,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 48, color: const Color(0xFFDDDDDD)),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _JadwalCard(
        item: items[i],
        onReschedule: () => onReschedule(items[i]),
      ),
    );
  }
}

// ── Jadwal card ───────────────────────────────────────────────────
class _JadwalCard extends StatelessWidget {
  final JadwalItem item;
  final VoidCallback onReschedule;

  const _JadwalCard({required this.item, required this.onReschedule});

  Color get _statusColor {
    switch (item.status) {
      case JadwalStatus.mendatang:
        return TBCareTheme.primary;
      case JadwalStatus.selesai:
        return const Color(0xFF9E9E9E);
      case JadwalStatus.terlewat:
        return TBCareTheme.perlaPantauan;
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case JadwalStatus.mendatang:
        return 'Mendatang';
      case JadwalStatus.selesai:
        return 'Selesai';
      case JadwalStatus.terlewat:
        return 'Terlewat';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.8),
      ),
      child: Column(
        children: [
          // Header tanggal + status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(color: const Color(0xFFE8E8E8), width: 0.8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 13, color: _statusColor),
                const SizedBox(width: 6),
                Text(
                  '${item.bulan} ${item.tanggal}, ${item.tahun}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Konten
          Padding(
            padding: const EdgeInsets.all(16),
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
                          // Agenda
                          Row(
                            children: [
                              Text(
                                item.agenda,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              if (item.dariRumahSakit) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FD),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Dari rumah sakit',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF1565C0),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Jam
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 13, color: Color(0xFF9E9E9E)),
                              const SizedBox(width: 5),
                              Text(
                                '${item.jamMulai} — ${item.jamSelesai}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B6B6B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Ruangan
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 13, color: Color(0xFF9E9E9E)),
                              const SizedBox(width: 5),
                              Text(
                                item.ruangan,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B6B6B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Tombol reschedule (hanya kalau bukan selesai)
                if (item.status != JadwalStatus.selesai) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: onReschedule,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TBCareTheme.primary,
                        side: const BorderSide(
                            color: TBCareTheme.primary, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'Reschedule',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reschedule bottom sheet ───────────────────────────────────────
class _RescheduleSheet extends StatefulWidget {
  final JadwalItem item;
  const _RescheduleSheet({required this.item});

  @override
  State<_RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<_RescheduleSheet> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '08:00';
  bool _isLoading = false;

  static const _timeSlots = [
    '08:00', '09:00', '10:00',
    '11:00', '12:00', '13:00',
    '14:00', '15:00', '16:00',
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: TBCareTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _konfirmasi() async {
    setState(() => _isLoading = true);
    // TODO: panggil JadwalRepository.reschedule()
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Jadwal berhasil diubah'),
        backgroundColor: TBCareTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Reschedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.item.agenda,
              style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
            ),

            const SizedBox(height: 20),

            // Pilih tanggal
            const Text(
              'Pilih Tanggal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3D3D3D),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: TBCareTheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: TBCareTheme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 16, color: TBCareTheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      '${_selectedDate.day} ${months[_selectedDate.month]} ${_selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TBCareTheme.primary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down,
                        color: TBCareTheme.primary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pilih waktu
            const Text(
              'Pilih Waktu',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3D3D3D),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((t) {
                final isSelected = _selectedTime == t;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TBCareTheme.primary
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? TBCareTheme.primary
                            : const Color(0xFFE0E0E0),
                        width: isSelected ? 1.5 : 0.8,
                      ),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF3D3D3D),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: Color(0xFFF57F17)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pastikan Anda datang 15 menit sebelum waktu konsultasi dimulai untuk proses administrasi ulang.',
                      style: TextStyle(
                          fontSize: 11, color: Color(0xFFF57F17)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tombol konfirmasi
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _konfirmasi,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: const Text('Konfirmasi Jadwal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}