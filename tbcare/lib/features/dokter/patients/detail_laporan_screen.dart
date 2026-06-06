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
  bool _hasReport = false;
  double _persentaseKepatuhan = 0.0;

  List<String> _obatDiminum = [];
  List<String> _gejalaList = [];
  int _moodIndex = -1;
  String _jamObat = 'Belum ada jadwal';
  String _statusObat = 'Belum ada data obat';
  String _catatanPasien = '';
  String _bulanTahun = 'Mei 2026';

  @override
  void initState() {
    super.initState();
    _loadReportDetails();
  }

  String _moodLabel(int idx) {
    switch (idx) {
      case 0:
        return 'Buruk';
      case 1:
        return 'Kurang';
      case 2:
        return 'Biasa';
      case 3:
        return 'Baik';
      default:
        return '-';
    }
  }

  // Fungsi untuk memuat detail laporan harian dari SQLite
  Future<void> _loadReportDetails() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper().database;

      // Ambil laporan berdasarkan id pasien dan kesamaan tanggal laporan
      // Order by id ASC untuk ensure konsistensi urutan (row pertama = first submission)
      final List<Map<String, dynamic>> results = await db.query(
        'patient_reports',
        where: 'patientId = ? AND tanggal = ?',
        whereArgs: [widget.patientId, widget.tanggal],
        orderBy: 'id ASC',
      );

      if (results.isNotEmpty) {
        final db = await DatabaseHelper().database;
        final List<Map<String, dynamic>> scheduleRows = await db.query(
          'schedules',
          where: 'patientId = ?',
          whereArgs: [widget.patientId],
        );

        final Set<String> scheduleNames = scheduleRows
            .map(
              (row) =>
                  row['medicineName']?.toString().toLowerCase().trim() ?? '',
            )
            .where((name) => name.isNotEmpty)
            .toSet();

        final Set<String> takenMeds = {};
        bool semuaDiminum = false;
        bool adaTerlewat = false;
        Map<String, dynamic>? mainRow;

        for (final row in results) {
          final String jamObat = row['jam_obat']?.toString() ?? '';
          final String catatan = row['catatan']?.toString().trim() ?? '';
          final String catatanLower = catatan.toLowerCase();

          if (_jamObat == 'Belum ada jadwal' && jamObat.isNotEmpty) {
            _jamObat = jamObat;
          }

          if (jamObat.toLowerCase().contains('terlewat')) {
            adaTerlewat = true;
          }

          final obatListRaw = row['obat_list']?.toString();
          bool rowSemuaDiminum = false;
          if (obatListRaw != null && obatListRaw.isNotEmpty) {
            try {
              final decoded = jsonDecode(obatListRaw);
              if (decoded is Map<String, dynamic>) {
                if (decoded['semua_diminum'] == true) {
                  semuaDiminum = true;
                  rowSemuaDiminum = true;
                }
              } else if (decoded is List) {
                for (final item in decoded) {
                  if (item is String && item.isNotEmpty) {
                    takenMeds.add(item);
                  } else if (item is Map<String, dynamic> &&
                      item['nama'] != null) {
                    takenMeds.add(item['nama'].toString());
                  }
                }
              }
            } catch (_) {}
          }

          // determine main submission row
          if (mainRow == null) {
            if (jamObat.toLowerCase().contains('laporan jam') ||
                catatanLower.contains('mood:') ||
                rowSemuaDiminum) {
              mainRow = row;
            }
          }

          if (scheduleNames.isNotEmpty &&
              catatan.isNotEmpty &&
              scheduleNames.contains(catatanLower)) {
            takenMeds.add(catatan);
          }
        }

        // Determine status and calculate percent
        if (semuaDiminum) {
          _statusObat = 'Semua obat diminum';
        } else if (adaTerlewat) {
          _statusObat = 'Ada obat terlewat';
        } else if (takenMeds.isNotEmpty) {
          _statusObat = 'Beberapa obat sudah dicatat';
        } else {
          _statusObat = 'Belum minum';
        }

        final calculatedPercent = scheduleNames.isEmpty
            ? (semuaDiminum ? 1.0 : 0.0)
            : (semuaDiminum
                  ? 1.0
                  : (takenMeds.length / scheduleNames.length).clamp(0.0, 1.0));

        // Populate gejala and catatan only from the main submission row
        if (mainRow != null) {
          // Prefer gejala from first submission (earliest row with non-empty gejala_list)
          Map<String, dynamic>? firstGejalaRow;
          for (final row in results) {
            final gejalaRaw = row['gejala_list']?.toString() ?? '';
            if (gejalaRaw.isNotEmpty && gejalaRaw != '[]') {
              firstGejalaRow = row;
              break;
            }
          }

          final gejalaRaw = (firstGejalaRow ?? mainRow)['gejala_list']
              ?.toString();
          if (gejalaRaw != null && gejalaRaw.isNotEmpty) {
            try {
              final decoded = jsonDecode(gejalaRaw);
              if (decoded is List) {
                _gejalaList = decoded.whereType<String>().toList();
              }
            } catch (_) {
              _gejalaList = [];
            }
          } else {
            _gejalaList = [];
          }

          // Preserve full patient note but also parse mood if present
          final rawCat = mainRow['catatan']?.toString().trim() ?? '';
          _catatanPasien = rawCat;
          // parse mood: look for '(Mood: X)' or 'Kondisi Perasaan: X'
          final moodMatch = RegExp(
            r'Mood[:\s]*([0-9])',
            caseSensitive: false,
          ).firstMatch(rawCat);
          if (moodMatch != null) {
            _moodIndex = int.tryParse(moodMatch.group(1) ?? '') ?? -1;
          } else {
            final kpMatch = RegExp(
              r'Kondisi Perasaan[:\s]*([0-9])',
              caseSensitive: false,
            ).firstMatch(rawCat);
            if (kpMatch != null) {
              _moodIndex = int.tryParse(kpMatch.group(1) ?? '') ?? -1;
            }
          }
        } else {
          _gejalaList = [];
          _catatanPasien = '';
        }

        setState(() {
          _hasReport = true;
          _obatDiminum = takenMeds.toList();
          _persentaseKepatuhan = calculatedPercent;
          _bulanTahun = results.first['bulan_tahun'] ?? _bulanTahun;
          _isLoading = false;
        });
        return;
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
          : !_hasReport
          ? const Center(
              child: Text(
                'Tidak ada laporan untuk tanggal ini.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                _SectionHeader(
                  icon: Icons.medication_rounded,
                  label: 'Laporan Minum Obat',
                ),
                const SizedBox(height: 10),
                _buildObatCard(),
                const SizedBox(height: 20),
                _SectionHeader(
                  icon: Icons.assignment_outlined,
                  label: 'Laporan Kondisi & Gejala',
                ),
                const SizedBox(height: 10),
                _buildGejalaCard(),
                const SizedBox(height: 20),
                _buildCatatanCard(),
              ],
            ),
    );
  }

  // Builder widget untuk Obat Card dari data SQLite
  Widget _buildObatCard() {
    if (_obatDiminum.isEmpty) {
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
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status Obat',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3D3D3D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _statusObat,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color:
                          _statusObat.toLowerCase().contains('terlewat') ||
                              _statusObat.toLowerCase().contains('belum')
                          ? const Color(0xFFE53935)
                          : const Color(0xFF1A9E8F),
                    ),
                  ),
                ],
              ),
              Text(
                '${(_persentaseKepatuhan * 100).round()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TBCareTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 8),
          if (_moodIndex >= 0)
            Row(
              children: [
                const Icon(
                  Icons.sentiment_satisfied_outlined,
                  size: 16,
                  color: Color(0xFF6B6B6B),
                ),
                const SizedBox(width: 8),
                Text(
                  _moodLabel(_moodIndex),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF3D3D3D),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          ..._obatDiminum.map(
            (obat) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: TBCareTheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      obat,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF3D3D3D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _gejalaList.map((g) {
          final lower = g.toLowerCase();
          IconData iconData = Icons.health_and_safety_outlined;
          if (lower.contains('batuk')) {
            iconData = Icons.air_rounded;
          } else if (lower.contains('demam') || lower.contains('suhu')) {
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
                Expanded(
                  child: Text(
                    g,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3D3D3D),
                    ),
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
          color: const Color.fromRGBO(29, 158, 117, 0.3),
          width: 0.8,
        ),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
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
