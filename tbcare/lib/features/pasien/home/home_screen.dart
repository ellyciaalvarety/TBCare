import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/features/pasien/home/widgets/kepatuhan_card.dart';
import 'package:tbcare/features/pasien/home/widgets/obat_checklist.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: ganti dengan data dari HomeBloc
    const String namaUser = 'John Doe';
    const int hariKe = 8;
    const int totalHari = 90;
    const double persenKepatuhan = 0.10;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            const Icon(
              Icons.health_and_safety_rounded,
              color: TBCareTheme.primary,
              size: 22,
            ),
            const SizedBox(width: 8),
            const Text(
              'TBCare',
              style: TextStyle(
                color: TBCareTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: Color(0xFF1A1A1A)),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: TBCareTheme.primary,
        onRefresh: () async {
          // TODO: trigger HomeBloc reload
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            // Greeting
            _GreetingHeader(nama: namaUser),
            const SizedBox(height: 16),

            // Kepatuhan card
            KepatuhanCard(
              hariKe: hariKe,
              totalHari: totalHari,
              persen: persenKepatuhan,
            ),
            const SizedBox(height: 16),

            // Obat checklist
            const ObatChecklist(),
            const SizedBox(height: 16),

            // Tombol input kondisi
            _InputKondisiButton(
              onTap: () => context.go(Routes.laporan),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Greeting ─────────────────────────────────────────────────────
class _GreetingHeader extends StatelessWidget {
  final String nama;
  const _GreetingHeader({required this.nama});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi,';
    if (hour < 15) return 'Selamat siang,';
    if (hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B6B6B),
          ),
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

// ── Tombol Input Kondisi ──────────────────────────────────────────
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