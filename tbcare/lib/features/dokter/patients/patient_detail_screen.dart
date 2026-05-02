import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/widgets/kepatuhan_chart.dart';

class PatientDetailScreen extends StatelessWidget {
  final String patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    // TODO: load dari PatientsBloc berdasarkan patientId
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Pasien'),
        leading: BackButton(onPressed: () => context.go(Routes.patients)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          // Profil card
          _ProfilCard(),
          const SizedBox(height: 16),

          // Kepatuhan + chart
          _KepatuhanSection(),
          const SizedBox(height: 16),

          // Jadwal obat harian
          _JadwalObatSection(
            onEdit: () {},
          ),
          const SizedBox(height: 16),

          // Kunjungan mendatang
          _KunjunganSection(),
        ],
      ),
    );
  }
}

// ── Profil card ───────────────────────────────────────────────────
class _ProfilCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: TBCareTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 32,
                  color: TBCareTheme.primary,
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jane Doe',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'PID: #TBC-2023-0942',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E)),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '+62 812-3456-7890',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF6B6B6B)),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'TTL: 14 Jan 1995',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF6B6B6B)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),

          // Fase & hari
          Row(
            children: [
              _InfoChip(
                label: 'Fase: Intensif',
                color: TBCareTheme.primary,
              ),
              const SizedBox(width: 8),
              _InfoChip(
                label: 'Hari: 42/180',
                color: const Color(0xFF6B6B6B),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Kepatuhan + chart ─────────────────────────────────────────────
class _KepatuhanSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header kepatuhan
          Row(
            children: [
              // Ring kecil
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: 0.88,
                      strokeWidth: 7,
                      backgroundColor: const Color(0xFFEEEEEE),
                      color: TBCareTheme.primary,
                      strokeCap: StrokeCap.round,
                    ),
                    const Text(
                      '88%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kepatuhan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Lihat riwayat harian',
                        style: TextStyle(
                          fontSize: 12,
                          color: TBCareTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Line chart
          const KepatuhanChart(),
        ],
      ),
    );
  }
}

// ── Jadwal obat harian ────────────────────────────────────────────
class _JadwalObatSection extends StatelessWidget {
  final VoidCallback onEdit;
  const _JadwalObatSection({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jadwal Obat Harian',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: const Text(
                  '✎ Ubah',
                  style: TextStyle(
                    fontSize: 13,
                    color: TBCareTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _JamObatGroup(
            jam: '18:00',
            obatList: const [
              {'nama': 'Rifampicin', 'dosis': '1 Kapsul', 'aturan': 'Sesudah Makan'},
              {'nama': 'Isoniazid', 'dosis': '1 Tablet', 'aturan': 'Sesudah Makan'},
            ],
          ),
          const SizedBox(height: 12),

          _JamObatGroup(
            jam: '12:00',
            aturanJam: 'Sesudah Makan',
            obatList: const [
              {'nama': 'Rifampicin', 'dosis': '1 Kapsul', 'aturan': 'Sesudah Makan'},
              {'nama': 'Isoniazid', 'dosis': '1 Tablet', 'aturan': 'Sesudah Makan'},
            ],
          ),
          const SizedBox(height: 12),

          _JamObatGroup(
            jam: '07:00',
            aturanJam: 'Sebelum Makan',
            obatList: const [
              {'nama': 'Rifampicin', 'dosis': '1 Kapsul', 'aturan': 'Sebelum Makan'},
              {'nama': 'Isoniazid', 'dosis': '1 Tablet', 'aturan': 'Sebelum Makan'},
            ],
          ),
        ],
      ),
    );
  }
}

class _JamObatGroup extends StatelessWidget {
  final String jam;
  final String? aturanJam;
  final List<Map<String, String>> obatList;

  const _JamObatGroup({
    required this.jam,
    this.aturanJam,
    required this.obatList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time_rounded,
                size: 13, color: Color(0xFF9E9E9E)),
            const SizedBox(width: 5),
            Text(
              jam,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3D3D3D),
              ),
            ),
            if (aturanJam != null) ...[
              const SizedBox(width: 6),
              Text(
                '• $aturanJam',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9E9E9E)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ...obatList.map(
          (o) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.medication_rounded,
                    size: 14, color: TBCareTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    o['nama']!,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF3D3D3D)),
                  ),
                ),
                Text(
                  o['dosis']!,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Kunjungan mendatang ───────────────────────────────────────────
class _KunjunganSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kunjungan Mendatang',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  '+ Tambah Jadwal',
                  style: TextStyle(
                    fontSize: 12,
                    color: TBCareTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _KunjunganCard(
            label: 'REVIEW LAB TEST',
            tanggal: '20 Okt 2023 • 10:30',
            ruangan: 'A 3.06',
            color: const Color(0xFFE3F2FD),
            labelColor: const Color(0xFF1565C0),
            badgeText: 'Dari Domisili Sakit',
          ),
          const SizedBox(height: 10),
          _KunjunganCard(
            label: 'KONSULTASI',
            tanggal: '18 Okt 2023 • 10:30',
            ruangan: 'A 3.06',
            color: TBCareTheme.primary.withOpacity(0.08),
            labelColor: TBCareTheme.primaryDark,
            badgeText: 'Dari Pasien',
          ),
        ],
      ),
    );
  }
}

class _KunjunganCard extends StatelessWidget {
  final String label;
  final String tanggal;
  final String ruangan;
  final Color color;
  final Color labelColor;
  final String badgeText;

  const _KunjunganCard({
    required this.label,
    required this.tanggal,
    required this.ruangan,
    required this.color,
    required this.labelColor,
    required this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_rounded, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 9,
                          color: labelColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  tanggal,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF3D3D3D)),
                ),
                Text(
                  ruangan,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}