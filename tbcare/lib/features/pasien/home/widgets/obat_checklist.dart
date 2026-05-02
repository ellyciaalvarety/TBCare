import 'package:flutter/material.dart';
import 'package:tbcare/app/theme.dart';

// Model sederhana — nanti pindah ke data/models/
class ObatItem {
  final String id;
  final String nama;
  final String dosis;
  final String aturan; // 'Sebelum Makan' | 'Sesudah Makan'
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
  const ObatChecklist({super.key});

  @override
  State<ObatChecklist> createState() => _ObatChecklistState();
}

class _ObatChecklistState extends State<ObatChecklist> {
  // TODO: ganti dengan data dari HomeBloc / API
  final List<ObatItem> _obatList = [
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
      selesai: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Kelompokkan obat per jam
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
              // Jam header
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

              // List obat
              ...entry.value.map((obat) => _ObatTile(
                    obat: obat,
                    onToggle: (val) {
                      setState(() => obat.selesai = val);
                    },
                  )),

              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Tile satu obat ────────────────────────────────────────────────
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
            // Ikon obat
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

            // Nama & dosis
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

            // Tombol selesai / checkmark
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
                          horizontal: 12, vertical: 6),
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