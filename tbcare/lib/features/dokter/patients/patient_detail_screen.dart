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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: TBCareTheme.primary, size: 20),
          onPressed: () => context.go(Routes.patients),
        ),
        title: const Text(
          'Pasien',
          style: TextStyle(
            color: TBCareTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child:
              Container(height: 1, color: const Color(0xFFF0F0F0)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          _ProfilCard(),
          const SizedBox(height: 16),
          _KepatuhanSection(patientId: patientId),
          const SizedBox(height: 16),
          _JadwalObatSection(onEdit: () {}),
          const SizedBox(height: 16),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: TBCareTheme.primary, width: 2.5),
                ),
                child: ClipOval(
                  child: Container(
                    color: TBCareTheme.primary.withOpacity(0.1),
                    child: const Icon(Icons.person_rounded,
                        size: 50, color: TBCareTheme.primary),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: TBCareTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Jane Doe',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 6),
          const Text('PID: #TBC-2023-0942',
              style:
                  TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Icon(Icons.phone_outlined,
                size: 14, color: Color(0xFF6B6B6B)),
            SizedBox(width: 6),
            Text('+62 812-3456-7890',
                style: TextStyle(
                    fontSize: 13, color: Color(0xFF6B6B6B))),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Icon(Icons.calendar_today_outlined,
                size: 14, color: Color(0xFF6B6B6B)),
            SizedBox(width: 6),
            Text('TTL: 14 Jan 1995',
                style: TextStyle(
                    fontSize: 13, color: Color(0xFF6B6B6B))),
          ]),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoChip(
                  label: 'Fase: Intensif',
                  color: TBCareTheme.primary),
              const SizedBox(width: 10),
              _InfoChip(
                  label: 'Hari: 42/180',
                  color: const Color(0xFF185FA5)),
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
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color)),
    );
  }
}

// ── Kepatuhan section ─────────────────────────────────────────────
class _KepatuhanSection extends StatelessWidget {
  final String patientId;
  const _KepatuhanSection({required this.patientId});

  void _showResetDialog(BuildContext context) {
    final TextEditingController ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          bool isMatch = ctrl.text.trim() == 'RESET';
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text('Reset Progress Pasien',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFFFCDD2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFB71C1C), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tindakan ini akan menghapus seluruh data progres pasien dan tidak dapat dibatalkan.',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB71C1C)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Ketik RESET untuk konfirmasi:',
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFF3D3D3D))),
                const SizedBox(height: 8),
                TextField(
                  controller: ctrl,
                  onChanged: (_) => setStateDialog(() {}),
                  decoration: InputDecoration(
                    hintText: 'RESET',
                    hintStyle: const TextStyle(
                        color: Color(0xFFBBBBBB)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: isMatch
                              ? const Color(0xFFB71C1C)
                              : const Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: isMatch
                              ? const Color(0xFFB71C1C)
                              : const Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFFB71C1C), width: 1.5),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal',
                    style: TextStyle(color: Color(0xFF6B6B6B))),
              ),
              TextButton(
                onPressed: isMatch
                    ? () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Progress pasien berhasil direset'),
                            backgroundColor: Color(0xFFB71C1C),
                          ),
                        );
                      }
                    : null,
                child: Text('Reset',
                    style: TextStyle(
                        color: isMatch
                            ? const Color(0xFFB71C1C)
                            : const Color(0xFFCCCCCC),
                        fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
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
                    const Text('88%',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A))),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kepatuhan',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => context
                        .go('/medis/patients/$patientId/riwayat'),
                    child: const Text('Lihat riwayat harian',
                        style: TextStyle(
                            fontSize: 13,
                            color: TBCareTheme.primary,
                            fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _showResetDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB71C1C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Reset Progress',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Jadwal Obat Harian',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A))),
              GestureDetector(
                onTap: onEdit,
                child: Row(
                  children: const [
                    Icon(Icons.edit_outlined,
                        size: 14, color: TBCareTheme.primary),
                    SizedBox(width: 4),
                    Text('Ubah',
                        style: TextStyle(
                            fontSize: 13,
                            color: TBCareTheme.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 160,
                decoration: const BoxDecoration(
                  color: TBCareTheme.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.access_time_rounded,
                              size: 16, color: Color(0xFF3D3D3D)),
                          SizedBox(width: 6),
                          Text('18:00',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A))),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _ObatRowSimple(
                          nama: 'Rifampicin',
                          keterangan: '1 Kapsul • Setelah Makan'),
                      const SizedBox(height: 10),
                      _ObatRowSimple(
                          nama: 'Isoniazid',
                          keterangan: '1 Kapsul • Setelah Makan'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ObatRowSimple extends StatelessWidget {
  final String nama;
  final String keterangan;
  const _ObatRowSimple(
      {required this.nama, required this.keterangan});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: TBCareTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.medication_rounded,
              size: 16, color: TBCareTheme.primary),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nama,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A))),
            Text(keterangan,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9E9E9E))),
          ],
        ),
      ],
    );
  }
}

// ── Kunjungan mendatang ───────────────────────────────────────────
class _KunjunganSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kunjungan Mendatang',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A))),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: TBCareTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_rounded,
                          size: 13, color: TBCareTheme.primary),
                    ),
                    const SizedBox(width: 5),
                    const Text('Tambah Jadwal',
                        style: TextStyle(
                            fontSize: 13,
                            color: TBCareTheme.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _KunjunganCard(
          label: 'REVIEW LAB TEST',
          tanggal: '20 Okt 2023 • 10:30',
          ruangan: 'A 3.06',
          bgColor: const Color(0xFFF5C518),
          textColor: const Color(0xFF5D4200),
          badgeText: 'Dari Rumah Sakit',
          badgeBg: const Color(0xFFE8A800),
          badgeTextColor: Colors.white,
        ),
        const SizedBox(height: 10),
        _KunjunganCard(
          label: 'KONSULTASI',
          tanggal: '18 Okt 2023 • 10:30',
          ruangan: 'A 3.06',
          bgColor: const Color(0xFF2979FF),
          textColor: Colors.white,
          badgeText: 'Dari Pasien',
          badgeBg: Colors.white.withOpacity(0.25),
          badgeTextColor: Colors.white,
        ),
      ],
    );
  }
}

class _KunjunganCard extends StatelessWidget {
  final String label;
  final String tanggal;
  final String ruangan;
  final Color bgColor;
  final Color textColor;
  final String badgeText;
  final Color badgeBg;
  final Color badgeTextColor;

  const _KunjunganCard({
    required this.label,
    required this.tanggal,
    required this.ruangan,
    required this.bgColor,
    required this.textColor,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.calendar_month_rounded,
                size: 22, color: textColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: textColor.withOpacity(0.8),
                            letterSpacing: 0.5)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(badgeText,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: badgeTextColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(tanggal,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor)),
                const SizedBox(height: 2),
                Text(ruangan,
                    style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.75))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}