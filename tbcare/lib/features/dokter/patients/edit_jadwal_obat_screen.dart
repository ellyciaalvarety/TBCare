import 'package:flutter/material.dart';
import 'package:tbcare/data/tbcare_database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jadwal Obat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A8C7E)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const EditJadwalObatPage(),
    );
  }
}

// ─── Model ───────────────────────────────────────────────────────────────────

class ObatItem {
  String namaObat;
  String dosis;
  bool sebelumMakan; // true = Sebelum, false = Sesudah

  ObatItem({
    required this.namaObat,
    required this.dosis,
    required this.sebelumMakan,
  });
}

// ─── Page ────────────────────────────────────────────────────────────────────

class EditJadwalObatPage extends StatefulWidget {
  const EditJadwalObatPage({super.key});

  @override
  State<EditJadwalObatPage> createState() => _EditJadwalObatPageState();
}

class _EditJadwalObatPageState extends State<EditJadwalObatPage> {
  static const Color _teal = Color(0xFF1A8C7E);
  static const Color _tealLight = Color(0xFFE6F4F2);
  static const Color _bgPage = Color(0xFFF4F9F8);
  static const Color _cardBg = Colors.white;
  static const Color _border = Color(0xFFDDE8E6);

  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);

  final List<ObatItem> _obatList = [
    ObatItem(namaObat: 'Rifampicin', dosis: '1 Kapsul', sebelumMakan: true),
    ObatItem(namaObat: 'Vitamin B6', dosis: '1 Tablet', sebelumMakan: false),
  ];

  // Controllers
  late List<TextEditingController> _namaControllers;
  late List<TextEditingController> _dosisControllers;

  @override
  void initState() {
    super.initState();
    _namaControllers = _obatList
        .map((o) => TextEditingController(text: o.namaObat))
        .toList();
    _dosisControllers = _obatList
        .map((o) => TextEditingController(text: o.dosis))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _namaControllers) {
      c.dispose();
    }
    for (final c in _dosisControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(
            ctx,
          ).copyWith(colorScheme: const ColorScheme.light(primary: _teal)),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _tambahObat() {
    setState(() {
      _obatList.add(ObatItem(namaObat: '', dosis: '', sebelumMakan: true));
      _namaControllers.add(TextEditingController());
      _dosisControllers.add(TextEditingController());
    });
  }

  void _hapusObat(int index) {
    setState(() {
      _namaControllers[index].dispose();
      _dosisControllers[index].dispose();
      _namaControllers.removeAt(index);
      _dosisControllers.removeAt(index);
      _obatList.removeAt(index);
    });
  }

  void _simpanPerubahan() {
    // Sync controller text back to model
    for (int i = 0; i < _obatList.length; i++) {
      _obatList[i].namaObat = _namaControllers[i].text;
      _obatList[i].dosis = _dosisControllers[i].text;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Perubahan berhasil disimpan!'),
        backgroundColor: _teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody()),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _bgPage,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _teal),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: const Text(
        'Edit Jadwal Obat',
        style: TextStyle(
          color: _teal,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          ..._buildObatCards(),
          const SizedBox(height: 12),
          _buildTambahObatButton(),
          const SizedBox(height: 24),
          _buildSimpanButton(),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Perubahan akan disinkronisasi ke aplikasi pasien',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Jadwal Minum Obat',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        GestureDetector(
          onTap: _pickTime,
          child: const Icon(
            Icons.access_time_rounded,
            color: Color(0xFF6B7280),
            size: 24,
          ),
        ),
      ],
    );
  }

  // ignore: must_be_immutable — inline widget via local helper
  Widget _buildTimeBadge() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _teal,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.alarm, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              _formatTime(_selectedTime),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Obat Cards ───────────────────────────────────────────────────────────

  List<Widget> _buildObatCards() {
    return [
      _buildTimeBadge(),
      const SizedBox(height: 12),
      ..._obatList.asMap().entries.map((entry) {
        final i = entry.key;
        final obat = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ObatCard(
            namaController: _namaControllers[i],
            dosisController: _dosisControllers[i],
            sebelumMakan: obat.sebelumMakan,
            onAturanChanged: (val) => setState(() => obat.sebelumMakan = val),
            onDelete: _obatList.length > 1 ? () => _hapusObat(i) : null,
          ),
        );
      }),
    ];
  }

  // ── Tambah Obat ──────────────────────────────────────────────────────────

  Widget _buildTambahObatButton() {
    return GestureDetector(
      onTap: _tambahObat,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: _teal,
            style: BorderStyle.solid,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        // Dashed border effect via CustomPaint
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline, color: _teal, size: 20),
            SizedBox(width: 8),
            Text(
              'Tambah Obat',
              style: TextStyle(
                color: _teal,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Simpan ───────────────────────────────────────────────────────────────

  Widget _buildSimpanButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _simpanPerubahan,
        style: ElevatedButton.styleFrom(
          backgroundColor: _teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Simpan Perubahan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border, width: 1)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: _teal,
        unselectedItemColor: Colors.grey[400],
        currentIndex: 0,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─── Obat Card Widget ─────────────────────────────────────────────────────────

class _ObatCard extends StatelessWidget {
  const _ObatCard({
    required this.namaController,
    required this.dosisController,
    required this.sebelumMakan,
    required this.onAturanChanged,
    this.onDelete,
  });

  final TextEditingController namaController;
  final TextEditingController dosisController;
  final bool sebelumMakan;
  final ValueChanged<bool> onAturanChanged;
  final VoidCallback? onDelete;

  static const Color _teal = Color(0xFF1A8C7E);
  static const Color _fieldBg = Color(0xFFF0F4F3);
  static const Color _border = Color(0xFFDDE8E6);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              const Text(
                'Nama Obat',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4B5563),
                ),
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.close, size: 18, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(namaController, 'Nama obat...'),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dosis',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(dosisController, 'e.g. 1 Tablet'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aturan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildAturanToggle(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _teal, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildAturanToggle() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _aturanChip(
            label: 'Sebelum',
            active: sebelumMakan,
            onTap: () => onAturanChanged(true),
          ),
          _aturanChip(
            label: 'Sesudah',
            active: !sebelumMakan,
            onTap: () => onAturanChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _aturanChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: active ? _teal : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}
