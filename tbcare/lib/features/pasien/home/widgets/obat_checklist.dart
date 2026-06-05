//features/pasien/home/widgets/obat_checklist.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/database/database_helper.dart'; // Import DatabaseHelper Anda

class ObatItem {
  final String id;
  final String nama;
  final String dosis;
  final String aturan;
  final String jam;
  bool selesai;

  ObatItem({
    required this.id,
    required this.nama,
    required this.dosis,
    required this.aturan,
    required this.jam,
    this.selesai = false,
  });
}

class ObatChecklist extends StatefulWidget {
  final VoidCallback
  onRefreshHome; // Callback untuk memicu update persentase di KepatuhanCard

  const ObatChecklist({super.key, required this.onRefreshHome});

  @override
  State<ObatChecklist> createState() => _ObatChecklistState();
}

class _ObatChecklistState extends State<ObatChecklist> {
  List<ObatItem> _obatList = [];
  bool _isLoading = true;
  String? _patientId;

  @override
  void initState() {
    super.initState();
    _loadHariIniObat();
  }

  Future<void> _loadHariIniObat() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _patientId = prefs.getString('patient_id');

      final db = await DatabaseHelper().database;

      // 1. Ambil daftar resep/jadwal obat master untuk pasien ini
      final List<Map<String, dynamic>> masterObat = await db.query(
        'patient_medications',
        where: 'patientId = ?',
        whereArgs: [_patientId],
      );

      // 2. Ambil log minum obat khusus HARI INI (Format: YYYY-MM-DD)
      final String hariIniStr = DateTime.now().toIso8601String().split('T')[0];
      final List<Map<String, dynamic>> logsHariIni = await db.query(
        'patient_reports',
        where: 'patientId = ? AND tanggal = ?',
        whereArgs: [_patientId, hariIniStr],
      );

      final List<ObatItem> loadedObat = [];

      if (masterObat.isNotEmpty) {
        for (final row in masterObat) {
          final String obatId = row['id'].toString();

          // Periksa apakah obat ini sudah ditandai selesai/diminum hari ini
          final bool isSelesai = logsHariIni.any(
            (log) =>
                log['medicationId'].toString() == obatId &&
                !log['jam_obat'].toString().contains('Terlewat'),
          );

          loadedObat.add(
            ObatItem(
              id: obatId,
              nama: row['nama'] ?? 'Nama Obat',
              dosis: row['dosis'] ?? '1 Tablet',
              aturan: row['aturan'] ?? 'Sesudah Makan',
              jam: row['jam'] ?? '08:00',
              selesai: isSelesai,
            ),
          );
        }
      } else {
        // Fallback data bawaan jika resep di database lokal masih kosong
        loadedObat.addAll([
          ObatItem(
            id: '1',
            nama: 'Isoniazid',
            dosis: '1 Tablet',
            aturan: 'Sebelum Makan',
            jam: '08:00',
          ),
          ObatItem(
            id: '2',
            nama: 'Rifampicin',
            dosis: '1 Kapsul',
            aturan: 'Sebelum Makan',
            jam: '08:00',
          ),
        ]);
      }

      if (mounted) {
        setState(() {
          _obatList = loadedObat;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error load obat checklist: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsDone(ObatItem obat) async {
    if (_patientId == null) return;

    try {
      final db = await DatabaseHelper().database;
      final String hariIniStr = DateTime.now().toIso8601String().split('T')[0];
      final String jamSekarangStr = TimeOfDay.now().format(context);

      // Simpan log ke tabel report harian sebagai bukti kepatuhan
      await db.insert('patient_reports', {
        'patientId': _patientId,
        'medicationId': obat.id,
        'tanggal': hariIniStr,
        'jam_obat': 'Diminum jam $jamSekarangStr',
        'status': 'Tepat Waktu',
      });

      setState(() {
        obat.selesai = true;
      });

      // Picu pembaruan lingkaran persentase di home_screen secara realtime
      widget.onRefreshHome();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil mencatat konsumsi ${obat.nama}'),
            backgroundColor: TBCareTheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Gagal menyimpan log minum obat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: CircularProgressIndicator(color: TBCareTheme.primary),
        ),
      );
    }

    if (_obatList.isEmpty) return const SizedBox.shrink();

    // Mengelompokkan obat berdasarkan jam minum
    final Map<String, List<ObatItem>> grouped = {};
    for (final obat in _obatList) {
      grouped.putIfAbsent(obat.jam, () => []).add(obat);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 15,
                      color: Color(0xFF6B6B6B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Obat jam ${entry.key}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3D3D3D),
                      ),
                    ),
                  ],
                ),
              ),
              ...entry.value.map(
                (obat) => _ObatTile(
                  obat: obat,
                  onToggle: (val) {
                    if (val) _markAsDone(obat);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ObatTile extends StatelessWidget {
  final ObatItem obat;
  final ValueChanged<bool> onToggle;

  const _ObatTile({required this.obat, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: obat.selesai
              ? TBCareTheme.primary.withOpacity(0.04)
              : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: obat.selesai
                ? TBCareTheme.primary.withOpacity(0.2)
                : const Color(0xFFEEEEEE),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: TBCareTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.medication_rounded,
                size: 17,
                color: obat.selesai
                    ? TBCareTheme.primary.withOpacity(0.4)
                    : TBCareTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    obat.nama,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: obat.selesai
                          ? const Color(0xFFAAAAAA)
                          : const Color(0xFF1A1A1A),
                      decoration: obat.selesai
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${obat.dosis} • ${obat.aturan}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            obat.selesai
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: TBCareTheme.primary,
                    size: 22,
                  )
                : GestureDetector(
                    onTap: () => onToggle(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: TBCareTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
