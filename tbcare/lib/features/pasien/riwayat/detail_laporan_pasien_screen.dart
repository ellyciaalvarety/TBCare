import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/database/database_helper.dart';

class DetailLaporanPasienScreen extends StatefulWidget {
  final String tanggal;
  const DetailLaporanPasienScreen({super.key, required this.tanggal});

  @override
  State<DetailLaporanPasienScreen> createState() =>
      _DetailLaporanPasienScreenState();
}

class _DetailLaporanPasienScreenState extends State<DetailLaporanPasienScreen> {
  bool _isLoading = true;
  String _jamObat = '-';
  String _statusObat = 'Belum ada data obat';
  double _persentaseKepatuhan = 0.0;
  List<String> _obatDiminum = [];
  List<String> _gejalaList = [];
  String _catatanPasien = '';
  int _moodIndex = -1;
  bool _hasReport = false;

  @override
  void initState() {
    super.initState();
    _loadReportDetail();
  }

  Future<void> _loadReportDetail() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? patientId = prefs.getString('patient_id');
      if (patientId == null || patientId.isEmpty) {
        return;
      }

      final db = await DatabaseHelper().database;
      final List<Map<String, dynamic>> reports = await db.query(
        'patient_reports',
        where: 'patientId = ? AND tanggal = ?',
        whereArgs: [patientId, widget.tanggal],
        orderBy: 'id ASC',
      );

      if (reports.isEmpty) {
        setState(() {
          _hasReport = false;
          _isLoading = false;
        });
        return;
      }

      _hasReport = true;
      final List<Map<String, dynamic>> scheduleRows = await db.query(
        'schedules',
        where: 'patientId = ?',
        whereArgs: [patientId],
      );

      final Set<String> scheduleNames = scheduleRows
          .map(
            (row) => row['medicineName']?.toString().toLowerCase().trim() ?? '',
          )
          .where((name) => name.isNotEmpty)
          .toSet();

      // Aggregate taken meds and find the patient's main submission row (the daily full report)
      final Set<String> takenMeds = {};
      bool semuaDiminum = false;
      Map<String, dynamic>? mainRow;

      for (final row in reports) {
        final jamObat = row['jam_obat']?.toString() ?? '';
        if (_jamObat == '-' && jamObat.isNotEmpty) {
          _jamObat = jamObat;
        }

        final catatan = row['catatan']?.toString().trim() ?? '';
        final catatanLower = catatan.toLowerCase();

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

        // Determine main submission row by heuristics
        if (mainRow == null) {
          if (jamObat.toLowerCase().contains('laporan jam') ||
              catatanLower.contains('mood:') ||
              rowSemuaDiminum) {
            mainRow = row;
          }
        }

        // Also consider catatan that equals medicine name as a taken med log
        if (scheduleNames.isNotEmpty &&
            catatan.isNotEmpty &&
            scheduleNames.contains(catatanLower) &&
            !jamObat.toLowerCase().contains('terlewat')) {
          takenMeds.add(catatan);
        }
      }

      // Populate gejala and catatan only from the main submission row (unique per report)
      if (mainRow != null) {
        // Prefer gejala from first submission (earliest row with non-empty gejala_list)
        Map<String, dynamic>? firstGejalaRow;
        for (final row in reports) {
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

        final rawCat = mainRow['catatan']?.toString().trim() ?? '';
        _catatanPasien = rawCat;
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
        _moodIndex = -1;
      }

      _obatDiminum = takenMeds.toList();

      if (scheduleNames.isEmpty) {
        _persentaseKepatuhan = semuaDiminum ? 1.0 : 0.0;
      } else if (semuaDiminum) {
        _persentaseKepatuhan = 1.0;
      } else {
        _persentaseKepatuhan = (takenMeds.length / scheduleNames.length).clamp(
          0.0,
          1.0,
        );
      }

      if (_persentaseKepatuhan >= 1.0) {
        _statusObat = 'Semua obat diminum';
      } else if (reports.any(
        (row) =>
            row['jam_obat']?.toString().toLowerCase().contains('terlewat') ==
            true,
      )) {
        _statusObat = 'Ada obat terlewat';
      } else if (_obatDiminum.isNotEmpty) {
        _statusObat = 'Beberapa obat sudah dicatat';
      } else {
        _statusObat = 'Belum minum';
      }
    } catch (e) {
      debugPrint('Gagal memuat detail laporan pasien: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Laporan ${widget.tanggal}',
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
          : _hasReport
          ? ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _buildSectionHeader(
                  'Kepatuhan Minum Obat',
                  Icons.medication_rounded,
                ),
                const SizedBox(height: 12),
                _buildObatStatusCard(),
                const SizedBox(height: 20),
                _buildSectionHeader(
                  'Gejala yang Dirasakan',
                  Icons.sentiment_dissatisfied_rounded,
                ),
                const SizedBox(height: 12),
                _buildGejalaCard(),
                const SizedBox(height: 20),
                _buildSectionHeader(
                  'Catatan Tambahan',
                  Icons.note_alt_outlined,
                ),
                const SizedBox(height: 12),
                _buildCatatanCard(),
              ],
            )
          : Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    const BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Tidak ditemukan laporan untuk tanggal tersebut.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: TBCareTheme.primary),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
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

  Widget _buildObatStatusCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Obat',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
          Text(
            _statusObat,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  _statusObat.toLowerCase().contains('terlewat') ||
                      _statusObat.toLowerCase().contains('belum')
                  ? Colors.red
                  : Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Waktu catatan: $_jamObat',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
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
          const SizedBox(height: 16),
          if (_obatDiminum.isNotEmpty) ...[
            const Text(
              'Obat yang dicatat diminum:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
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
          ] else ...[
            const Text(
              'Belum ada catatan obat yang diminum pada tanggal ini.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGejalaCard() {
    if (_gejalaList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'Tidak ada gejala yang tercatat untuk hari ini.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _gejalaList
            .map(
              (gejala) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bubble_chart_rounded,
                      color: TBCareTheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        gejala,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF3D3D3D),
                        ),
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

  Widget _buildCatatanCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        _catatanPasien.isEmpty
            ? 'Tidak ada catatan tambahan dari pasien.'
            : _catatanPasien,
        style: TextStyle(
          fontSize: 13,
          color: _catatanPasien.isEmpty ? Colors.grey : const Color(0xFF3D3D3D),
        ),
      ),
    );
  }
}
