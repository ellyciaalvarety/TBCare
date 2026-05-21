import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laporan Pasien',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2BAE8E)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LaporanPasienScreen(),
    );
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────────

enum StatusObat { diminum, terlewat }

class RiwayatHarian {
  final int tanggal;
  final String bulan;
  final String namaHari;
  final StatusObat status;
  final int jumlahDosis; // hanya relevan jika status == terlewat

  const RiwayatHarian({
    required this.tanggal,
    required this.bulan,
    required this.namaHari,
    required this.status,
    this.jumlahDosis = 0,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class LaporanPasienScreen extends StatelessWidget {
  const LaporanPasienScreen({super.key});

  static const Color _primaryGreen = Color(0xFF2BAE8E);
  static const Color _errorRed = Color(0xFFD94040);
  static const Color _bgColor = Color(0xFFF0F7F5);
  static const Color _cardBg = Colors.white;
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textGray = Color(0xFF6B7280);

  static const List<RiwayatHarian> _riwayat = [
    RiwayatHarian(
      tanggal: 24,
      bulan: 'MEI',
      namaHari: 'Hari Ini',
      status: StatusObat.diminum,
    ),
    RiwayatHarian(
      tanggal: 23,
      bulan: 'MEI',
      namaHari: 'Kamis',
      status: StatusObat.diminum,
    ),
    RiwayatHarian(
      tanggal: 22,
      bulan: 'MEI',
      namaHari: 'Rabu',
      status: StatusObat.terlewat,
      jumlahDosis: 2,
    ),
    RiwayatHarian(
      tanggal: 21,
      bulan: 'MEI',
      namaHari: 'Selasa',
      status: StatusObat.terlewat,
      jumlahDosis: 1,
    ),
    RiwayatHarian(
      tanggal: 20,
      bulan: 'MEI',
      namaHari: 'Minggu',
      status: StatusObat.diminum,
    ),
    RiwayatHarian(
      tanggal: 19,
      bulan: 'MEI',
      namaHari: 'Sabtu',
      status: StatusObat.diminum,
    ),
    RiwayatHarian(
      tanggal: 18,
      bulan: 'MEI',
      namaHari: "Jum'at",
      status: StatusObat.diminum,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _bgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: _primaryGreen,
          size: 20,
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: const Text(
        'Riwayat Harian',
        style: TextStyle(
          color: _primaryGreen,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      centerTitle: false,
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Section header
        const Padding(
          padding: EdgeInsets.only(bottom: 12, top: 4),
          child: Text(
            'Bulan ini',
            style: TextStyle(
              color: _textDark,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
        ),

        // Cards
        ...List.generate(_riwayat.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RiwayatCard(data: _riwayat[index]),
          );
        }),

        const SizedBox(height: 12),
      ],
    );
  }
}

// ─── Card Widget ──────────────────────────────────────────────────────────────

class _RiwayatCard extends StatelessWidget {
  final RiwayatHarian data;

  const _RiwayatCard({required this.data});

  static const Color _primaryGreen = Color(0xFF2BAE8E);
  static const Color _errorRed = Color(0xFFD94040);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textGray = Color(0xFF6B7280);
  static const Color _dateBg = Color(0xFFEEEEEE);

  bool get _isDiminum => data.status == StatusObat.diminum;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              // Date badge
              _buildDateBadge(),
              const SizedBox(width: 14),
              // Info
              Expanded(child: _buildInfo()),
              // Chevron
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFCBCBCB),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateBadge() {
    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _dateBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.bulan,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _textGray,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            '${data.tanggal}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textDark,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.namaHari,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              _isDiminum ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 16,
              color: _isDiminum ? _primaryGreen : _errorRed,
            ),
            const SizedBox(width: 5),
            Text(
              _isDiminum
                  ? 'Obat Diminum'
                  : '${data.jumlahDosis} Dosis Terlewat',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _isDiminum ? _primaryGreen : _errorRed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Bottom Nav Item ──────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : const Color(0xFFAAAAAA);

    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
