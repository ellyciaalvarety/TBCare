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
      home: const JadwalScreen(),
    );
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────

enum StatusObat { diminum, terlewat, belum }

class ObatItem {
  final String nama;
  final String dosis;
  final StatusObat status;

  const ObatItem({
    required this.nama,
    required this.dosis,
    required this.status,
  });
}

class JadwalObat {
  final String jam;
  final List<ObatItem> obatList;

  const JadwalObat({required this.jam, required this.obatList});
}

// ─── JadwalScreen ─────────────────────────────────────────────────────────────

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  static const Color _primaryColor = Color(0xFF1A9E8F);
  static const Color _errorColor = Color(0xFFD94F4F);
  static const Color _bgColor = Color(0xFFF5F7F7);
  static const Color _cardColor = Colors.white;

  int _selectedNavIndex = 2; // History aktif

  final _catatanCtrl = TextEditingController();

  final List<JadwalObat> _jadwalList = const [
    JadwalObat(
      jam: '18:00',
      obatList: [
        ObatItem(
          nama: 'Isoniazid',
          dosis: '300mg • 1 Tablet • Setelah Makan',
          status: StatusObat.diminum,
        ),
        ObatItem(
          nama: 'Rifampicin',
          dosis: '300mg • 1 Tablet • Setelah Makan',
          status: StatusObat.diminum,
        ),
      ],
    ),
    JadwalObat(
      jam: '12:00',
      obatList: [
        ObatItem(
          nama: 'Isoniazid',
          dosis: '300mg • 1 Tablet • Setelah Makan',
          status: StatusObat.terlewat,
        ),
        ObatItem(
          nama: 'Rifampicin',
          dosis: '300mg • 1 Tablet • Setelah Makan',
          status: StatusObat.terlewat,
        ),
      ],
    ),
    JadwalObat(
      jam: '08:00',
      obatList: [
        ObatItem(
          nama: 'Isoniazid',
          dosis: '300mg • 1 Tablet • Setelah Makan',
          status: StatusObat.diminum,
        ),
        ObatItem(
          nama: 'Rifampicin',
          dosis: '300mg • 1 Tablet • Setelah Makan',
          status: StatusObat.diminum,
        ),
      ],
    ),
  ];

  final List<Map<String, dynamic>> _gejalList = const [
    {'icon': Icons.air, 'label': 'Batuk'},
    {'icon': Icons.thermostat_outlined, 'label': 'Demam'},
  ];

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

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
                    const SizedBox(height: 20),
                    _buildSectionTitle(
                      icon: Icons.medication_outlined,
                      title: 'Laporan Minum Obat',
                    ),
                    const SizedBox(height: 12),
                    ..._jadwalList.map(_buildJadwalCard),
                    const SizedBox(height: 20),
                    _buildSectionTitle(
                      icon: Icons.assignment_outlined,
                      title: 'Laporan Kondisi & Gejala',
                    ),
                    const SizedBox(height: 12),
                    _buildGejalCard(),
                    const SizedBox(height: 14),
                    _buildCatatanCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: _primaryColor),
            onPressed: () => Navigator.of(context).maybePop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Text(
            '22 Mei 2026',
            style: const TextStyle(
              color: _primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Avatar dokter
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
              border: Border.all(color: _primaryColor, width: 2),
            ),
            child: ClipOval(
              child: Icon(Icons.person, size: 26, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Title ──────────────────────────────────────────────────────────

  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: _primaryColor, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ── Jadwal Obat Card ───────────────────────────────────────────────────────

  Widget _buildJadwalCard(JadwalObat jadwal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
            children: [
              Icon(Icons.access_time_outlined, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Obat jam ${jadwal.jam}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...jadwal.obatList.map((obat) => _buildObatItem(obat)),
        ],
      ),
    );
  }

  Widget _buildObatItem(ObatItem obat) {
    final bool terlewat = obat.status == StatusObat.terlewat;
    final Color itemBg = terlewat
        ? const Color(0xFFFDECEC)
        : const Color(0xFFF4F6F6);
    final Color iconColor = terlewat ? _errorColor : Colors.grey.shade400;
    final Color checkColor = terlewat ? _errorColor : Colors.grey.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: itemBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.medication_outlined, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  obat.nama,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  obat.dosis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Icon(
            terlewat ? Icons.cancel_outlined : Icons.check_circle_outline,
            color: checkColor,
            size: 20,
          ),
        ],
      ),
    );
  }

  // ── Gejala Card ────────────────────────────────────────────────────────────

  Widget _buildGejalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: _gejalList.map((g) => _buildGejalItem(g)).toList(),
      ),
    );
  }

  Widget _buildGejalItem(Map<String, dynamic> gejala) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(gejala['icon'] as IconData, color: _primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            gejala['label'] as String,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ── Catatan Pasien Card ────────────────────────────────────────────────────

  Widget _buildCatatanCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0ECEA), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan Pasien',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _catatanCtrl,
            maxLines: 5,
            minLines: 5,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Tulis catatan di sini...',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav Bar ─────────────────────────────────────────────────────────

  Widget _buildBottomNavBar() {
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
      {'icon': Icons.people_outline, 'label': 'Patients'},
      {'icon': Icons.history_outlined, 'label': 'History'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final bool isSelected = index == _selectedNavIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedNavIndex = index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      navItems[index]['icon'] as IconData,
                      color: isSelected ? _primaryColor : Colors.grey,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      navItems[index]['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected ? _primaryColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
