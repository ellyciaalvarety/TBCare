import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
import 'package:tbcare/features/dokter/patients/laporan_pasien_screen.dart';
import 'package:tbcare/features/dokter/patients/detail_laporan_screen.dart';
import 'package:tbcare/features/dokter/patients/edit_jadwal_obat_screen.dart';
import 'package:tbcare/features/dokter/jadwal/jadwal_screen.dart'
    as dokter_jadwal;
import 'package:tbcare/features/dokter/jadwal/ajukan_jadwal_screen.dart'
    as dokter_ajukan;
import 'package:tbcare/features/dokter/profil/profil_screen.dart'
    as dokter_profil;
import 'package:tbcare/features/dokter/profil/edit_profil_screen.dart'
    as dokter_edit_profil;

import 'package:tbcare/shared/navigation/bottom_nav_pasien.dart';
import 'package:tbcare/shared/navigation/bottom_nav_medis.dart';

class Routes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';

  static const pasienShell = '/pasien';
  static const pasienHome = '/pasien/home';
  static const laporan = '/pasien/laporan';
  static const jadwalPasien = '/pasien/jadwal';
  static const ajukanJadwal = '/pasien/jadwal/ajukan';
  static const riwayat = '/pasien/riwayat';
  static const profilPasien = '/pasien/profil';

  static const medisShell = '/medis';
  static const patients = '/medis/patients';
  static const jadwalMedis = '/medis/jadwal';
  static const profilMedis = '/medis/profil';
  static const profilMedisEdit = '/medis/profil/edit';
}

final router = GoRouter(
  // ✅ BYPASS: langsung ke dokter
  initialLocation: Routes.patients,

  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: Routes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.register,
      builder: (context, state) => const RegisterScreen(),
    ),

    // Pasien shell
    ShellRoute(
      builder: (context, state, child) =>
          BottomNavPasien(child: child),
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
              builder: (context, state) =>
                  const AjukanJadwalScreen(),
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

    // Dokter / Perawat shell
    ShellRoute(
      builder: (context, state, child) =>
          BottomNavMedis(child: child),
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
              routes: [
                // Riwayat harian
                GoRoute(
                  path: 'riwayat',
                  builder: (context, state) {
                    final patientId = state.pathParameters['id']!;
                    return LaporanPasienScreen(patientId: patientId);
                  },
                  routes: [
                    GoRoute(
                      path: ':tanggal',
                      builder: (context, state) {
                        final patientId =
                            state.pathParameters['id']!;
                        final tanggal =
                            state.pathParameters['tanggal']!;
                        return DetailLaporanScreen(
                          patientId: patientId,
                          tanggal: tanggal,
                        );
                      },
                    ),
                  ],
                ),

                // Edit jadwal obat
                GoRoute(
                  path: 'edit-obat',
                  builder: (context, state) {
                    final patientId = state.pathParameters['id']!;
                    return EditJadwalObatScreen(patientId: patientId);
                  },
                ),

                // Ajukan jadwal dari detail pasien
                GoRoute(
                  path: 'ajukan-jadwal',
                  builder: (context, state) {
                    final patientId = state.pathParameters['id']!;
                    return dokter_ajukan.AjukanJadwalScreen(
                        patientId: patientId);
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: Routes.jadwalMedis,
          builder: (context, state) =>
              const dokter_jadwal.JadwalScreen(),
        ),
        GoRoute(
          path: Routes.profilMedis,
          builder: (context, state) =>
              const dokter_profil.ProfilScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) =>
                  const dokter_edit_profil.EditProfilScreen(),
            ),
          ],
        ),
      ],
    ),
  ],

  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Halaman tidak ditemukan\n${state.error}',
        textAlign: TextAlign.center,
      ),
    ),
  ),
);