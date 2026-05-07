import 'package:flutter/material.dart';

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
  final StatusObat status;
  final String keterangan;

  const CatatanHarian({
    required this.hari,
    required this.tanggal,
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

  int _selectedNavIndex = 2; // Riwayat aktif

  final List<CatatanHarian> _catatanList = const [
    CatatanHarian(
      hari: 'SEN',
      tanggal: 4,
      status: StatusObat.semua,
      keterangan: 'Tidak ada gejala',
    ),
    CatatanHarian(
      hari: 'MIN',
      tanggal: 3,
      status: StatusObat.terlewat,
      keterangan: 'Tidak ada gejala',
    ),
    CatatanHarian(
      hari: 'SAB',
      tanggal: 2,
      status: StatusObat.semua,
      keterangan: '1 Gejala',
    ),
    CatatanHarian(
      hari: 'JUM',
      tanggal: 1,
      status: StatusObat.semua,
      keterangan: 'Tidak ada gejala',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
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

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: _primaryColor, size: 22),
          const SizedBox(width: 8),
          Text(
            'TBCare',
            style: TextStyle(
              color: _primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Kepatuhan Card ─────────────────────────────────────────────────────────

  Widget _buildKepatuhanCard() {
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
                      const Text(
                        '95%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 10),
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
                              '+2%',
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
                  value: 0.95,
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
              value: 0.95,
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
            onPressed: () {},
            icon: const Icon(Icons.chevron_left, color: Colors.grey),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Row(
            children: const [
              Icon(
                Icons.calendar_month_outlined,
                color: _primaryColor,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'November 2024',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
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
      onTap: () {},
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

  // ── Bottom Nav Bar ─────────────────────────────────────────────────────────
}
