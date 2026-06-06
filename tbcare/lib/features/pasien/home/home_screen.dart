//features/pasien/home/home_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/features/pasien/home/widgets/kepatuhan_card.dart';
import 'package:tbcare/features/pasien/home/widgets/obat_checklist.dart';
import 'package:tbcare/shared/database/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String _namaUser = 'Pasien';
  int _hariKe = 1;
  int _totalHari = 90;
  double _persenKepatuhan = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPasienData();
  }

  Future<void> _loadPasienData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? patientId = prefs.getString('patient_id');

      final db = await DatabaseHelper().database;

      final List<Map<String, dynamic>> patients = await db.query(
        'patients',
        where: 'id = ?',
        whereArgs: [patientId],
      );

      if (patients.isNotEmpty) {
        final currentPatient = patients.first;
        _namaUser = currentPatient['nama'] ?? 'Pasien TBCare';
        _totalHari = currentPatient['total_hari_program'] ?? 90;

        // Hitung riwayat kepatuhan berdasarkan tanggal unik
        final List<Map<String, dynamic>> reports = await db.query(
          'patient_reports',
          where: 'patientId = ?',
          whereArgs: [patientId],
        );

        final distinctDates = reports
            .map((row) => row['tanggal']?.toString().trim() ?? '')
            .where((value) => value.isNotEmpty)
            .toSet();

        _hariKe = distinctDates.isEmpty ? 1 : distinctDates.length;

        final todayStr = DateTime.now().toIso8601String().split('T')[0];
        final todayReports = reports
            .where((row) => row['tanggal']?.toString() == todayStr)
            .toList();

        final List<Map<String, dynamic>> scheduleRows = await db.query(
          'schedules',
          where: 'patientId = ?',
          whereArgs: [patientId],
        );

        final Set<String> scheduleNames = scheduleRows
            .map(
              (row) =>
                  row['medicineName']?.toString().toLowerCase().trim() ?? '',
            )
            .where((name) => name.isNotEmpty)
            .toSet();

        double todayPercent = 0.0;
        final int scheduleCount = scheduleNames.length;

        if (scheduleCount > 0) {
          final Set<String> takenMedNames = {};
          bool isSemuaObatDiminum = false;

          for (final row in todayReports) {
            final catatan = row['catatan']?.toString().trim() ?? '';
            final jamObat = row['jam_obat']?.toString().toLowerCase() ?? '';

            if (jamObat.contains('terlewat')) continue;

            if (catatan.isNotEmpty &&
                scheduleNames.contains(catatan.toLowerCase())) {
              takenMedNames.add(catatan.toLowerCase());
            }

            final obatListRaw = row['obat_list']?.toString();
            if (obatListRaw != null && obatListRaw.isNotEmpty) {
              try {
                final decoded = jsonDecode(obatListRaw);
                if (decoded is Map<String, dynamic> &&
                    decoded['semua_diminum'] == true) {
                  isSemuaObatDiminum = true;
                }
              } catch (_) {}
            }
          }

          if (isSemuaObatDiminum) {
            todayPercent = 1.0;
          } else {
            todayPercent = (takenMedNames.length / scheduleCount).clamp(
              0.0,
              1.0,
            );
          }
        } else {
          todayPercent = 0.0;
        }

        _persenKepatuhan = todayPercent;
      }
    } catch (e) {
      debugPrint('Gagal mengambil ringkasan database: $e');
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
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(
              Icons.health_and_safety_rounded,
              color: TBCareTheme.primary,
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'TBCare',
              style: TextStyle(
                color: TBCareTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: TBCareTheme.primary),
            )
          : RefreshIndicator(
              color: TBCareTheme.primary,
              onRefresh: _loadPasienData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _GreetingHeader(nama: _namaUser),
                  const SizedBox(height: 16),
                  KepatuhanCard(
                    hariKe: _hariKe,
                    totalHari: _totalHari,
                    persen: _persenKepatuhan,
                  ),
                  const SizedBox(height: 16),
                  ObatChecklist(
                    onRefreshHome: _loadPasienData,
                  ), // Oper fungsi reload ke anak widget
                  const SizedBox(height: 16),
                  _InputKondisiButton(
                    onTap: () async {
                      await context.push(Routes.laporan);
                      _loadPasienData();
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final String nama;
  const _GreetingHeader({required this.nama});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = 'Selamat pagi,';
    if (hour >= 11 && hour < 15) greeting = 'Selamat siang,';
    if (hour >= 15 && hour < 18) greeting = 'Selamat sore,';
    if (hour >= 18) greeting = 'Selamat malam,';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B6B6B)),
        ),
        const SizedBox(height: 2),
        Text(
          'Hai, $nama!',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

class _InputKondisiButton extends StatelessWidget {
  final VoidCallback onTap;
  const _InputKondisiButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: TBCareTheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Input Kondisi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Lapor gejala harian',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
