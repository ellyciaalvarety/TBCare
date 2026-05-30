import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbcare/app/theme.dart';

class ObatEntry {
  TextEditingController namaCtrl;
  TextEditingController dosisCtrl;
  String aturan;

  ObatEntry({
    String nama = '',
    String dosis = '',
    this.aturan = 'Sebelum',
  })  : namaCtrl = TextEditingController(text: nama),
        dosisCtrl = TextEditingController(text: dosis);

  void dispose() {
    namaCtrl.dispose();
    dosisCtrl.dispose();
  }
}

class EditJadwalObatScreen extends StatefulWidget {
  final String patientId;
  const EditJadwalObatScreen({super.key, required this.patientId});

  @override
  State<EditJadwalObatScreen> createState() =>
      _EditJadwalObatScreenState();
}

class _EditJadwalObatScreenState extends State<EditJadwalObatScreen> {
  // Jam minum obat — satu waktu saja
  TimeOfDay _jamMinum = const TimeOfDay(hour: 18, minute: 0);
  bool _isLoading = false;

  // List obat
  final List<ObatEntry> _obatList = [
    ObatEntry(nama: 'Rifampicin', dosis: '1 Kapsul', aturan: 'Sebelum'),
    ObatEntry(nama: 'Vitamin B6', dosis: '1 Tablet', aturan: 'Sesudah'),
  ];

  @override
  void dispose() {
    for (final e in _obatList) {
      e.dispose();
    }
    super.dispose();
  }

  String _formatJam(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickJam() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _jamMinum,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: TBCareTheme.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _jamMinum = picked);
  }

  void _tambahObat() {
    setState(() => _obatList.add(ObatEntry()));
  }

  void _hapusObat(int index) {
    setState(() {
      _obatList[index].dispose();
      _obatList.removeAt(index);
    });
  }

  Future<void> _simpan() async {
    setState(() => _isLoading = true);
    // TODO: panggil PasienRepository.updateJadwalObat()
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Jadwal obat berhasil disimpan'),
        backgroundColor: TBCareTheme.primary,
      ),
    );
    context.go('/medis/patient-detail/${widget.patientId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F7F6),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: TBCareTheme.primary, size: 20),
          onPressed: () =>
              context.go('/medis/patient-detail/${widget.patientId}'),
        ),
        title: const Text(
          'Edit Jadwal Obat',
          style: TextStyle(
            color: TBCareTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          // Judul
          const Text(
            'Jadwal Minum Obat',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),

          // Pengaturan jam — satu waktu
          _JamPicker(
            jam: _formatJam(_jamMinum),
            onTap: _pickJam,
          ),
          const SizedBox(height: 20),

          // List obat
          ...List.generate(_obatList.length, (i) => _ObatFormCard(
                obat: _obatList[i],
                onHapus: _obatList.length > 1
                    ? () => _hapusObat(i)
                    : null,
                onAturanChanged: (val) =>
                    setState(() => _obatList[i].aturan = val),
              )),

          const SizedBox(height: 8),

          // Tambah obat
          GestureDetector(
            onTap: _tambahObat,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TBCareTheme.primary.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_circle_outline_rounded,
                      size: 18, color: TBCareTheme.primary),
                  SizedBox(width: 8),
                  Text(
                    'Tambah Obat',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TBCareTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Tombol simpan fixed bawah
      bottomSheet: Container(
        color: const Color(0xFFF0F7F6),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TBCareTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Perubahan akan disinkronisasi ke aplikasi pasien',
              style:
                  TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Jam picker ────────────────────────────────────────────────────
class _JamPicker extends StatelessWidget {
  final String jam;
  final VoidCallback onTap;

  const _JamPicker({required this.jam, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Badge jam aktif
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: TBCareTheme.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  jam,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Tombol ubah jam
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: const Color(0xFFE0E0E0), width: 0.8),
            ),
            child: Row(
              children: const [
                Icon(Icons.edit_outlined,
                    size: 14, color: TBCareTheme.primary),
                SizedBox(width: 6),
                Text(
                  'Ubah Jam',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: TBCareTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Form card satu obat ───────────────────────────────────────────
class _ObatFormCard extends StatelessWidget {
  final ObatEntry obat;
  final VoidCallback? onHapus;
  final ValueChanged<String> onAturanChanged;

  const _ObatFormCard({
    required this.obat,
    required this.onHapus,
    required this.onAturanChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFE8E8E8), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + hapus
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nama Obat',
                style: TextStyle(
                    fontSize: 12, color: Color(0xFF9E9E9E)),
              ),
              if (onHapus != null)
                GestureDetector(
                  onTap: onHapus,
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: Color(0xFFE53935),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // Input nama obat
          _FormField(
            controller: obat.namaCtrl,
            hint: 'Nama obat',
          ),
          const SizedBox(height: 12),

          // Dosis + Aturan
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dosis
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dosis',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E)),
                    ),
                    const SizedBox(height: 6),
                    _FormField(
                      controller: obat.dosisCtrl,
                      hint: '1 Tablet',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Aturan toggle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aturan',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF9E9E9E)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: ['Sebelum', 'Sesudah'].map((val) {
                        final isActive = obat.aturan == val;
                        return GestureDetector(
                          onTap: () => onAturanChanged(val),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? TBCareTheme.primary
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Text(
                              val,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isActive
                                    ? Colors.white
                                    : const Color(0xFF9E9E9E),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Input field ───────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _FormField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 14, color: Color(0xFFBBBBBB)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
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
          borderSide: const BorderSide(
              color: TBCareTheme.primary, width: 1.5),
        ),
      ),
    );
  }
}