import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbcare/app/theme.dart';

class LaporanPasienScreen extends StatelessWidget {
  final String patientId;
  const LaporanPasienScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> riwayat = [
      {'tanggal': '24', 'bulan': 'MEI', 'hari': 'Hari Ini', 'status': 'ok', 'keterangan': 'Obat Diminum'},
      {'tanggal': '23', 'bulan': 'MEI', 'hari': 'Kamis', 'status': 'ok', 'keterangan': 'Obat Diminum'},
      {'tanggal': '22', 'bulan': 'MEI', 'hari': 'Rabu', 'status': 'miss', 'keterangan': '2 Dosis Terlewat'},
      {'tanggal': '21', 'bulan': 'MEI', 'hari': 'Selasa', 'status': 'miss', 'keterangan': '1 Dosis Terlewat'},
      {'tanggal': '20', 'bulan': 'MEI', 'hari': 'Minggu', 'status': 'ok', 'keterangan': 'Obat Diminum'},
      {'tanggal': '19', 'bulan': 'MEI', 'hari': 'Sabtu', 'status': 'ok', 'keterangan': 'Obat Diminum'},
      {'tanggal': '18', 'bulan': 'MEI', 'hari': 'Jum\'at', 'status': 'ok', 'keterangan': 'Obat Diminum'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F7F6),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: TBCareTheme.primary, size: 20),
          onPressed: () => context.go('/medis/patients/$patientId'),
        ),
        title: const Text(
          'Riwayat Harian',
          style: TextStyle(
            color: TBCareTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const Text(
            'Bulan ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          ...riwayat.map((item) => _RiwayatCard(
                tanggal: item['tanggal'],
                bulan: item['bulan'],
                hari: item['hari'],
                status: item['status'],
                keterangan: item['keterangan'],
                onTap: () => context.go(
                  '/medis/patients/$patientId/riwayat/${item['tanggal']}',
                ),
              )),
        ],
      ),
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  final String tanggal;
  final String bulan;
  final String hari;
  final String status;
  final String keterangan;
  final VoidCallback onTap;

  const _RiwayatCard({
    required this.tanggal,
    required this.bulan,
    required this.hari,
    required this.status,
    required this.keterangan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOk = status == 'ok';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: Row(
          children: [
            // Tanggal box
            Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    bulan,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: TBCareTheme.primary,
                    ),
                  ),
                  Text(
                    tanggal,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Hari & status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hari,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isOk
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: 15,
                        color: isOk
                            ? TBCareTheme.primary
                            : const Color(0xFFE53935),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        keterangan,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isOk
                              ? TBCareTheme.primary
                              : const Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }
}