import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbcare/app/theme.dart';

class DetailLaporanScreen extends StatelessWidget {
  final String patientId;
  final String tanggal;

  const DetailLaporanScreen({
    super.key,
    required this.patientId,
    required this.tanggal,
  });

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
              context.go('/medis/patients/$patientId/riwayat'),
        ),
        title: Text(
          '$tanggal Mei 2026',
          style: const TextStyle(
            color: TBCareTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Laporan Minum Obat
          _SectionHeader(
            icon: Icons.medication_rounded,
            label: 'Laporan Minum Obat',
          ),
          const SizedBox(height: 10),
          _ObatCard(),
          const SizedBox(height: 20),

          // Laporan Kondisi & Gejala
          _SectionHeader(
            icon: Icons.assignment_outlined,
            label: 'Laporan Kondisi & Gejala',
          ),
          const SizedBox(height: 10),
          _GejalaCard(),
          const SizedBox(height: 20),

          // Catatan Pasien
          _CatatanCard(),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: TBCareTheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

// ── Obat card ─────────────────────────────────────────────────────
class _ObatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Jam header
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 15, color: Color(0xFF6B6B6B)),
              const SizedBox(width: 6),
              const Text(
                'Obat jam 18:00',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3D3D3D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Isoniazid — diminum (abu)
          _ObatRow(
            nama: 'Isoniazid',
            keterangan: '300mg • 1 Tablet • Sebelum Makan',
            isDiminum: true,
          ),
          const SizedBox(height: 8),

          // Rifampicin — terlewat (merah)
          _ObatRow(
            nama: 'Rifampicin',
            keterangan: '300mg • 1 Tablet • Sebelum Makan',
            isDiminum: false,
          ),
        ],
      ),
    );
  }
}

class _ObatRow extends StatelessWidget {
  final String nama;
  final String keterangan;
  final bool isDiminum;

  const _ObatRow({
    required this.nama,
    required this.keterangan,
    required this.isDiminum,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDiminum
            ? const Color(0xFFF5F5F5)
            : const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.medication_rounded,
            size: 18,
            color: isDiminum
                ? const Color(0xFF9E9E9E)
                : const Color(0xFFE53935),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  keterangan,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),
          Icon(
            isDiminum
                ? Icons.check_circle_outline_rounded
                : Icons.cancel_outlined,
            size: 20,
            color: isDiminum
                ? const Color(0xFF9E9E9E)
                : const Color(0xFFE53935),
          ),
        ],
      ),
    );
  }
}

// ── Gejala card ───────────────────────────────────────────────────
class _GejalaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> gejalaList = [
      {'label': 'Batuk', 'icon': Icons.air_rounded},
      {'label': 'Demam', 'icon': Icons.thermostat_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: gejalaList
            .map(
              (g) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(g['icon'] as IconData,
                        size: 18, color: TBCareTheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      g['label'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3D3D3D),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Catatan card ──────────────────────────────────────────────────
class _CatatanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: TBCareTheme.primary.withOpacity(0.3), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catatan Pasien',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: TBCareTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FFFE),
              borderRadius: BorderRadius.circular(10),
            ),
            // Kosong — belum ada catatan dari pasien
          ),
        ],
      ),
    );
  }
}