import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/features/pasien/laporan_harian/widgets/gejala_selector.dart';
import 'package:tbcare/features/pasien/laporan_harian/widgets/catatan_input.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  // Status obat
  bool _semuaObatDiminum = false;

  // Gejala yang dipilih
  final List<String> _gejalaSelected = [];

  // Catatan
  String _catatan = '';

  // Mood / perasaan
  int _moodIndex = -1; // 0=buruk,1=biasa,2=baik,3=sangat baik

  bool _isLoading = false;

  Future<void> _kirimLaporan() async {
    if (_moodIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kondisi perasaan hari ini dulu ya'),
          backgroundColor: TBCareTheme.perlaPantauan,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    // TODO: kirim via LaporanBloc / LaporanRepository
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Laporan harian berhasil dikirim!'),
        backgroundColor: TBCareTheme.primary,
      ),
    );
    context.go(Routes.pasienHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Input Kondisi Harian'),
        leading: BackButton(onPressed: () => context.go(Routes.pasienHome)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        children: [
          // Subjudul
          const Text(
            'Bagaimana perasaan Anda hari ini?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Laporan harian membantu tim medis memantau pemulihan Anda.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B6B6B)),
          ),

          const SizedBox(height: 20),

          // Mood selector
          _MoodSelector(
            selected: _moodIndex,
            onChanged: (i) => setState(() => _moodIndex = i),
          ),

          const SizedBox(height: 20),

          // Status obat
          _ObatStatusCard(
            checked: _semuaObatDiminum,
            onChanged: (v) => setState(() => _semuaObatDiminum = v),
          ),

          const SizedBox(height: 16),

          // Gejala
          _SectionTitle(label: 'Gejala yang dirasakan'),
          const SizedBox(height: 10),
          GejalaSelector(
            selected: _gejalaSelected,
            onChanged: (list) => setState(() {
              _gejalaSelected
                ..clear()
                ..addAll(list);
            }),
          ),

          const SizedBox(height: 16),

          // Catatan
          _SectionTitle(label: 'Catatan'),
          const SizedBox(height: 10),
          CatatanInput(
            onChanged: (val) => _catatan = val,
          ),
        ],
      ),

      // Tombol kirim fixed di bawah
      bottomSheet: _BottomKirim(
        isLoading: _isLoading,
        onKirim: _kirimLaporan,
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF3D3D3D),
      ),
    );
  }
}

// ── Mood selector ─────────────────────────────────────────────────
class _MoodSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _MoodSelector({required this.selected, required this.onChanged});

  static const _moods = [
    {'emoji': '😞', 'label': 'Buruk'},
    {'emoji': '😐', 'label': 'Biasa'},
    {'emoji': '🙂', 'label': 'Baik'},
    {'emoji': '😄', 'label': 'Sangat Baik'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_moods.length, (i) {
          final isSelected = selected == i;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? TBCareTheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? TBCareTheme.primary
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _moods[i]['emoji']!,
                    style: TextStyle(
                      fontSize: isSelected ? 30 : 26,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _moods[i]['label']!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? TBCareTheme.primary
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Status obat card ──────────────────────────────────────────────
class _ObatStatusCard extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;

  const _ObatStatusCard({required this.checked, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: checked
              ? TBCareTheme.primary.withOpacity(0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: checked
                ? TBCareTheme.primary.withOpacity(0.3)
                : const Color(0xFFE8E8E8),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: checked
                    ? TBCareTheme.primary.withOpacity(0.1)
                    : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.medication_rounded,
                size: 20,
                color: checked
                    ? TBCareTheme.primary
                    : const Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semua obat sudah diminum',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tap untuk konfirmasi',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: checked,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: TBCareTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom kirim ──────────────────────────────────────────────────
class _BottomKirim extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onKirim;

  const _BottomKirim({required this.isLoading, required this.onKirim});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onKirim,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(isLoading ? 'Mengirim...' : 'Kirim Laporan Hari Ini'),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Data Anda hanya akan dilihat oleh dokter.',
            style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }
}