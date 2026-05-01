import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tbcare/features/auth/screens/splash_screen.dart';
import 'package:tbcare/features/auth/screens/login_screen.dart';
import 'package:tbcare/features/auth/screens/register_screen.dart';

import 'package:tbcare/features/pasien/home/home_screen.dart';
import 'package:tbcare/features/pasien/laporan_harian/laporan_screen.dart';
import 'package:tbcare/features/pasien/jadwal/jadwal_screen.dart';
import 'package:tbcare/features/pasien/jadwal/ajukan_jadwal_screen.dart';
import 'package:tbcare/features/pasien/riwayat/riwayat_screen.dart';
import 'package:tbcare/features/pasien/profil/profil_screen.dart';

import 'package:tbcare/features/dokter/patients/patients_screen.dart';
import 'package:tbcare/features/dokter/patients/patient_detail_screen.dart';
import 'package:tbcare/features/dokter/jadwal/jadwal_screen.dart'
    as dokter_jadwal;
import 'package:tbcare/features/dokter/profil/profil_screen.dart'
    as dokter_profil;

import 'package:tbcare/shared/navigation/bottom_nav_pasien.dart';
import 'package:tbcare/shared/navigation/bottom_nav_medis.dart';

// ── Route name constants ──────────────────────────────────────────
class Routes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';

  // Pasien
  static const pasienShell = '/pasien';
  static const pasienHome = '/pasien/home';
  static const laporan = '/pasien/laporan';
  static const jadwalPasien = '/pasien/jadwal';
  static const ajukanJadwal = '/pasien/jadwal/ajukan';
  static const riwayat = '/pasien/riwayat';
  static const profilPasien = '/pasien/profil';

  // Dokter / Perawat (pakai shell yang sama)
  static const medisShell = '/medis';
  static const patients = '/medis/patients';
  static const patientDetail = '/medis/patients/:id';
  static const jadwalMedis = '/medis/jadwal';
  static const profilMedis = '/medis/profil';
}

// ── Redirect helper — baca role dari SharedPreferences ───────────
Future<String?> _redirectByRole(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final role = prefs.getString('role'); // 'pasien' | 'dokter' | 'perawat'

  if (token == null) return Routes.login;
  if (role == 'pasien') return Routes.pasienHome;
  if (role == 'dokter' || role == 'perawat') return Routes.patients;
  return Routes.login;
}

// ── Router ────────────────────────────────────────────────────────
final router = GoRouter(
  initialLocation: Routes.splash,
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');

    final onAuthPage = state.matchedLocation == Routes.login ||
        state.matchedLocation == Routes.register ||
        state.matchedLocation == Routes.splash;

    // Belum login → paksa ke login (kecuali sudah di auth page)
    if (token == null && !onAuthPage) return Routes.login;

    // Sudah login tapi buka /login atau /register → redirect ke home role-nya
    if (token != null && onAuthPage && state.matchedLocation != Routes.splash) {
      if (role == 'pasien') return Routes.pasienHome;
      if (role == 'dokter' || role == 'perawat') return Routes.patients;
    }

    return null; // tidak perlu redirect
  },
  routes: [
    // ── Splash ──────────────────────────────────────────────────
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // ── Auth ────────────────────────────────────────────────────
    GoRoute(
      path: Routes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.register,
      builder: (context, state) => const RegisterScreen(),
    ),

    // ── Pasien shell (BottomNav) ─────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => BottomNavPasien(child: child),
      routes: [
        GoRoute(
          path: Routes.pasienHome,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: Routes.laporan,
          builder: (context, state) => const LaporanScreen(),
        ),
        GoRoute(
          path: Routes.jadwalPasien,
          builder: (context, state) => const JadwalScreen(),
          routes: [
            GoRoute(
              path: 'ajukan',
              builder: (context, state) => const AjukanJadwalScreen(),
            ),
          ],
        ),
        GoRoute(
          path: Routes.riwayat,
          builder: (context, state) => const RiwayatScreen(),
        ),
        GoRoute(
          path: Routes.profilPasien,
          builder: (context, state) => const ProfilScreen(),
        ),
      ],
    ),

    // ── Dokter / Perawat shell (BottomNav) ───────────────────────
    ShellRoute(
      builder: (context, state, child) => BottomNavMedis(child: child),
      routes: [
        GoRoute(
          path: Routes.patients,
          builder: (context, state) => const PatientsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final patientId = state.pathParameters['id']!;
                return PatientDetailScreen(patientId: patientId);
              },
            ),
          ],
        ),
        GoRoute(
          path: Routes.jadwalMedis,
          builder: (context, state) => const dokter_jadwal.JadwalScreen(),
        ),
        GoRoute(
          path: Routes.profilMedis,
          builder: (context, state) => const dokter_profil.ProfilScreen(),
        ),
      ],
    ),
  ],

  // Error page sederhana
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Halaman tidak ditemukan\n${state.error}',
        textAlign: TextAlign.center,
      ),
    ),
  ),
);