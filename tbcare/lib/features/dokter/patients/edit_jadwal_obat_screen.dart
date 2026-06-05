//features/medis/patients/edit_jadwal_obat_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/database/database_helper.dart'; // Import DatabaseHelper Anda

class ObatEntry {
  TextEditingController namaCtrl;
  TextEditingController dosisCtrl;
  String aturan;

  ObatEntry({String nama = '', String dosis = '', this.aturan = 'Sebelum'})
    : namaCtrl = TextEditingController(text: nama),
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
  State<EditJadwalObatScreen> createState() => _EditJadwalObatScreenState();
}

class _EditJadwalObatScreenState extends State<EditJadwalObatScreen> {
  // Jam minum obat — satu waktu saja
  TimeOfDay _jamMinum = const TimeOfDay(hour: 18, minute: 0);
  bool _isLoading = true;

  // List obat yang akan diisi dari database
  List<ObatEntry> _obatList = [];

  @override
  void initState() {
    super.initState();
    _loadJadwalObat();
  }

  // 1. Fungsi untuk memuat data jadwal obat yang sudah ada di SQLite
  Future<void> _loadJadwalObat() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper().database;

      // Ambil data jadwal obat berdasarkan patientId
      final List<Map<String, dynamic>> maps = await db.query(
        'schedules',
        where: 'patientId = ?',
        whereArgs: [widget.patientId],
      );

      if (maps.isNotEmpty) {
        // Ambil jam minum obat dari data pertama (karena dalam rancangan ini jamnya sama)
        final String timeStr = maps.first['time'] ?? '18:00';
        final List<String> timeParts = timeStr.split(':');
        if (timeParts.length == 2) {
          _jamMinum = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }

        // Masukkan data dari SQLite ke list form instruksi obat
        setState(() {
          _obatList = maps.map((item) {
            return ObatEntry(
              nama: item['medicineName'] ?? '',
              dosis: item['dosage'] ?? '',
              aturan: item['instruction'] ?? 'Sebelum',
            );
          }).toList();
        });
      } else {
        // Jika belum ada data di database sama sekali, berikan 1 form kosong default
        setState(() {
          _obatList = [ObatEntry()];
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat jadwal obat: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. Fungsi untuk menyimpan perubahan ke SQLite
  Future<void> _simpan() async {
    // Validasi input kosong
    for (var obat in _obatList) {
      if (obat.namaCtrl.text.trim().isEmpty ||
          obat.dosisCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua kolom nama obat dan dosis wajib diisi!'),
            backgroundColor: TBCareTheme.risikoTinggi,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final db = await DatabaseHelper().database;

      // Gunakan transaksi agar proses penghapusan dan penambahan berjalan aman
      await db.transaction((txn) async {
        // A. Hapus semua jadwal obat lama milik pasien ini
        await txn.delete(
          'schedules',
          where: 'patientId = ?',
          whereArgs: [widget.patientId],
        );

        // Format waktu menjadi "HH:mm" (contoh: "18:00")
        final String formattedTime = _formatJam(_jamMinum);

        // B. Masukkan baris data baru dari form input list obat satu per satu
        for (var obat in _obatList) {
          await txn.insert('schedules', {
            'patientId': widget.patientId,
            'time': formattedTime,
            'medicineName': obat.namaCtrl.text.trim(),
            'dosage': obat.dosisCtrl.text.trim(),
            'instruction': obat.aturan,
          });
        }
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal obat berhasil diperbarui'),
          backgroundColor: TBCareTheme.primary,
        ),
      );

      // Kembali ke halaman detail pasien
      context.go('/medis/patients/${widget.patientId}');
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan perubahan: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _formatJam(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pilihJam() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _jamMinum,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: TBCareTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _jamMinum = picked);
    }
  }

  void _tambahObat() {
    setState(() => _obatList.add(ObatEntry()));
  }

  void _hapusObat(int index) {
    if (_obatList.length > 1) {
      setState(() {
        _obatList[index].dispose();
        _obatList.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    for (var o in _obatList) {
      o.dispose();
    }
    super.dispose();
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: TBCareTheme.primary,
            size: 20,
          ),
          onPressed: () => context.go('/medis/patients/${widget.patientId}'),
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: TBCareTheme.primary),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                // Pengaturan Waktu
                const Text(
                  'Waktu Minum Obat',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pilihJam,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: TBCareTheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _formatJam(_jamMinum),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_drop_down_rounded,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Daftar Obat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Obat',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _tambahObat,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'Tambah',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: TBCareTheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // List Form Obat Builder
                ..._obatList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final obat = entry.value;

                  return _CardObatForm(
                    index: index,
                    total: _obatList.length,
                    obat: obat,
                    onDelete: () => _hapusObat(index),
                    onAturanChanged: (val) {
                      setState(() => obat.aturan = val);
                    },
                  );
                }).toList(),
              ],
            ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        color: const Color(0xFFF0F7F6),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _simpan,
            style: ElevatedButton.styleFrom(
              backgroundColor: TBCareTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Simpan Perubahan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Widget Card Form Item ───────────────────────────────────────────
class _CardObatForm extends StatelessWidget {
  final int index;
  final int total;
  final ObatEntry obat;
  final VoidCallback onDelete;
  final ValueChanged<String> onAturanChanged;

  const _CardObatForm({
    required this.index,
    required this.total,
    required this.obat,
    required this.onDelete,
    required this.onAturanChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              Text(
                'Obat #${index + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              if (total > 1)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Nama Obat
          const Text(
            'Nama Obat',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)),
          ),
          const SizedBox(height: 4),
          _FormField(controller: obat.namaCtrl, hint: 'Contoh: Isoniazid'),

          const SizedBox(height: 12),

          // Dosis & Aturan Makan
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dosis / Takaran',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)),
                    ),
                    const SizedBox(height: 4),
                    _FormField(
                      controller: obat.dosisCtrl,
                      hint: 'Contoh: 300mg • 1 Tab',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aturan Minum',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: ['Sebelum', 'Sesudah'].map((type) {
                        final isSelected = obat.aturan == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => onAturanChanged(type),
                            child: Container(
                              margin: EdgeInsets.only(
                                right: type == 'Sebelum' ? 6 : 0,
                              ),
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? TBCareTheme.primary.withOpacity(0.06)
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? TBCareTheme.primary
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  type,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? TBCareTheme.primary
                                        : const Color(0xFF555555),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Input field Custom ─────────────────────────────────────────────
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
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFBBBBBB)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
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
          borderSide: const BorderSide(color: TBCareTheme.primary, width: 1.2),
        ),
      ),
    );
  }
}
