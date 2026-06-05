//features/medis/patients/detail_laporan_screen.dart

import 'dart:convert'; // Diperlukan untuk melakukan decode JSON teks dari SQLite
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/database/database_helper.dart'; // Import DatabaseHelper Anda

class DetailLaporanScreen extends StatefulWidget {
  final String patientId;
  final String tanggal;

  const DetailLaporanScreen({
    super.key,
    required this.patientId,
    required this.tanggal,
  });

  @override
  State<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends State<DetailLaporanScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _reportData;

  List<dynamic> _obatList = [];
  List<dynamic> _gejalaList = [];
  String _jamObat = 'Belum ada jadwal';
  String _catatanPasien = '';
  String _bulanTahun = 'Mei 2026';

  @override
  void initState() {
    super.initState();
    _loadReportDetails();
  }

  // Fungsi untuk memuat detail laporan harian dari SQLite
  Future<void> _loadReportDetails() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper().database;

      // Ambil laporan berdasarkan id pasien dan kesamaan tanggal laporan
      final List<Map<String, dynamic>> results = await db.query(
        'patient_reports',
        where: 'patientId = ? AND tanggal = ?',
        whereArgs: [widget.patientId, widget.tanggal],
      );

      if (results.isNotEmpty) {
        final data = results.first;
        setState(() {
          _reportData = data;
          _jamObat = data['jam_obat'] ?? 'Obat jam 18:00';
          _bulanTahun = data['bulan_tahun'] ?? 'Mei 2026';
          _catatanPasien = data['catatan'] ?? '';

          // Parsing string JSON kembali menjadi objek List
          if (data['obat_list'] != null) {
            _obatList = jsonDecode(data['obat_list']);
          }
          if (data['gejala_list'] != null) {
            _gejalaList = jsonDecode(data['gejala_list']);
          }
        });
      }
    } catch (e) {
      // Menangani error jika query gagal
      debugPrint("Error loading report details: $e");
    } finally {
      setState(() => _isLoading = false);
    }
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
          onPressed: () =>
              context.go('/medis/patients/${widget.patientId}/riwayat'),
        ),
        title: Text(
          '${widget.tanggal} $_bulanTahun',
          style: const TextStyle(
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                // Laporan Minum Obat
                _SectionHeader(
                  icon: Icons.medication_rounded,
                  label: 'Laporan Minum Obat',
                ),
                const SizedBox(height: 10),
                _buildObatCard(),
                const SizedBox(height: 20),

                // Laporan Kondisi & Gejala
                _SectionHeader(
                  icon: Icons.assignment_outlined,
                  label: 'Laporan Kondisi & Gejala',
                ),
                const SizedBox(height: 10),
                _buildGejalaCard(),
                const SizedBox(height: 20),

                // Catatan Pasien
                _buildCatatanCard(),
              ],
            ),
    );
  }

  // Builder widget untuk Obat Card dari data SQLite
  Widget _buildObatCard() {
    if (_obatList.isEmpty) {
      return const _EmptyDataCard(
        message: 'Tidak ada laporan minum obat pada hari ini.',
      );
    }

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
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 15,
                color: Color(0xFF6B6B6B),
              ),
              const SizedBox(width: 6),
              Text(
                _jamObat,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3D3D3D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._obatList.map((obat) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _ObatRow(
                nama: obat['nama'] ?? '',
                keterangan: obat['keterangan'] ?? '',
                isDiminum: obat['isDiminum'] == 1 || obat['isDiminum'] == true,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Builder widget untuk Gejala Card dari data SQLite
  Widget _buildGejalaCard() {
    if (_gejalaList.isEmpty) {
      return const _EmptyDataCard(
        message: 'Pasien tidak merasakan gejala apapun hari ini.',
      );
    }

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
        children: _gejalaList.map((g) {
          // Mapping icon data dari penamaan teks string database
          IconData iconData = Icons.health_and_safety_outlined;
          if (g['icon_name'] == 'air_rounded' || g['label'] == 'Batuk') {
            iconData = Icons.air_rounded;
          } else if (g['icon_name'] == 'thermostat_rounded' ||
              g['label'] == 'Demam') {
            iconData = Icons.thermostat_rounded;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(iconData, size: 18, color: TBCareTheme.primary),
                const SizedBox(width: 12),
                Text(
                  g['label'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3D3D3D),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Builder widget untuk Catatan Card dari data SQLite
  Widget _buildCatatanCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TBCareTheme.primary.withOpacity(0.3),
          width: 0.8,
        ),
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
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(minHeight: 100),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FFFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _catatanPasien.isEmpty
                  ? 'Tidak ada catatan tertulis dari pasien untuk laporan hari ini.'
                  : _catatanPasien,
              style: TextStyle(
                fontSize: 13,
                color: _catatanPasien.isEmpty
                    ? Colors.grey
                    : const Color(0xFF3D3D3D),
                fontStyle: _catatanPasien.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
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

// ── Obat row ─────────────────────────────────────────────────────
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
        color: isDiminum ? const Color(0xFFF5F5F5) : const Color(0xFFFFF0F0),
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
                    fontSize: 11,
                    color: Color(0xFF9E9E9E),
                  ),
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

// ── Widget pembantu jika data kosong ─────────────────────────────────
class _EmptyDataCard extends StatelessWidget {
  final String message;
  const _EmptyDataCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
