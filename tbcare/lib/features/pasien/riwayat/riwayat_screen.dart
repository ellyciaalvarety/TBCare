import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/database/database_helper.dart';

void main() {
  runApp(const TBCareApp());
}

class TBCareApp extends StatelessWidget {
  const TBCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TBCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A9E8F)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const RiwayatScreen(),
    );
  }
}

// ─── Model ───────────────────────────────────────────────────────────────────

enum StatusObat { semua, terlewat }

class CatatanHarian {
  final String hari;
  final int tanggal;
  final String tanggalFull;
  final StatusObat status;
  final String keterangan;

  const CatatanHarian({
    required this.hari,
    required this.tanggal,
    required this.tanggalFull,
    required this.status,
    required this.keterangan,
  });
}

// ─── RiwayatScreen ───────────────────────────────────────────────────────────

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  static const Color _primaryColor = Color(0xFF1A9E8F);
  static const Color _warningColor = Color(0xFFE07B3C);
  static const Color _bgColor = Color(0xFFF5F7F7);
  static const Color _cardColor = Colors.white;

  bool _isLoading = true;
  DateTime _displayMonth = DateTime.now();
  String _monthLabel = '';
  double _kepatuhanPercent = 0.0;
  final List<CatatanHarian> _catatanList = [];

  @override
  void initState() {
    super.initState();
    _monthLabel = _formatMonthLabel(_displayMonth);
    _loadRiwayatData();
  }

  Future<void> _loadRiwayatData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? patientId = prefs.getString('patient_id');

      if (patientId == null || patientId.isEmpty) {
        _catatanList.clear();
        _kepatuhanPercent = 0.0;
        return;
      }

      final db = await DatabaseHelper().database;
      final String monthPattern =
          '${_displayMonth.year}-${_displayMonth.month.toString().padLeft(2, '0')}%';

      final List<Map<String, dynamic>> reports = await db.query(
        'patient_reports',
        where: 'patientId = ? AND tanggal LIKE ?',
        whereArgs: [patientId, monthPattern],
        orderBy: 'tanggal DESC',
      );

      _catatanList.clear();
      int missedCount = 0;

      for (final report in reports) {
        final String rawDate = report['tanggal']?.toString() ?? '';
        if (rawDate.isEmpty) continue;

        DateTime parsedDate;
        try {
          parsedDate = DateTime.parse(rawDate);
        } catch (_) {
          continue;
        }

        final bool isMissed =
            report['jam_obat']?.toString().toLowerCase().contains('terlewat') ??
            false;
        if (isMissed) missedCount += 1;

        _catatanList.add(
          CatatanHarian(
            hari: _weekdayLabel(parsedDate.weekday),
            tanggal: parsedDate.day,
            tanggalFull: rawDate,
            status: isMissed ? StatusObat.terlewat : StatusObat.semua,
            keterangan:
                report['catatan']?.toString() ?? 'Laporan harian pasien',
          ),
        );
      }

      final int totalReports = _catatanList.length;
      if (totalReports > 0) {
        _kepatuhanPercent = ((totalReports - missedCount) / totalReports).clamp(
          0.0,
          1.0,
        );
      } else {
        _kepatuhanPercent = 0.0;
      }
    } catch (e) {
      debugPrint('Gagal memuat riwayat pasien: $e');
      _catatanList.clear();
      _kepatuhanPercent = 0.0;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _weekdayLabel(int weekday) {
    const days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    return days[(weekday - 1) % 7];
  }

  String _formatMonthLabel(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.year}';
  }

  void _changeMonth(int delta) {
    _displayMonth = DateTime(
      _displayMonth.year,
      _displayMonth.month + delta,
      1,
    );
    _monthLabel = _formatMonthLabel(_displayMonth);
    _loadRiwayatData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildKepatuhanCard(),
                    const SizedBox(height: 16),
                    _buildMonthNavigator(),
                    const SizedBox(height: 20),
                    _buildCatatanHarianSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  // ── Kepatuhan Card ─────────────────────────────────────────────────────────

  Widget _buildKepatuhanCard() {
    final int percentValue = (_kepatuhanPercent * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kepatuhan Bulan Ini',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _catatanList.isEmpty ? '-' : '$percentValue%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (_catatanList.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F7F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.trending_up,
                                size: 13,
                                color: _primaryColor,
                              ),
                              SizedBox(width: 3),
                              Text(
                                '+0%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: _catatanList.isEmpty ? 0.0 : _kepatuhanPercent,
                  strokeWidth: 7,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    _primaryColor,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _catatanList.isEmpty ? 0.0 : _kepatuhanPercent,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(_primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  // ── Month Navigator ────────────────────────────────────────────────────────

  Widget _buildMonthNavigator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left, color: Colors.grey),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: _primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                _monthLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right, color: Colors.grey),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ── Catatan Harian Section ─────────────────────────────────────────────────

  Widget _buildCatatanHarianSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan Harian',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(color: TBCareTheme.primary),
            ),
          )
        else if (_catatanList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Belum ada laporan untuk bulan ini.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _catatanList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _buildCatatanCard(_catatanList[index]),
          ),
      ],
    );
  }

  Widget _buildCatatanCard(CatatanHarian catatan) {
    final bool isTerlewat = catatan.status == StatusObat.terlewat;

    return GestureDetector(
      onTap: () {
        context.push('/pasien/riwayat/${catatan.tanggalFull}');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Tanggal
            Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    catatan.hari,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    catatan.tanggal.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isTerlewat
                            ? Icons.error_outline
                            : Icons.check_circle_outline,
                        color: isTerlewat ? _warningColor : _primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isTerlewat ? 'Ada obat terlewat' : 'Semua obat diminum',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isTerlewat ? _warningColor : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    catatan.keterangan,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
