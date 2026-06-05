//features/dokter/profil/profil_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/widgets/tbcare_app_bar.dart';
import 'package:tbcare/shared/database/database_helper.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  bool _isLoading = true;

  // State Informasi Profil Dokter
  String _namaDokter = 'Memuat...';
  String _spesialisasi = '-';
  String _tanggalLahir = '-';
  String _jenisKelamin = '-';
  String _noHp = '-';
  String _email = '-';
  String _strNumber = '-';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Menarik data dokter secara berkala dari database
  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedEmail =
          prefs.getString('email') ?? prefs.getString('doctor_email');

      if (savedEmail != null) {
        final db = await DatabaseHelper().database;
        final cleanEmail = savedEmail.trim().toLowerCase();

        // Menggunakan SQL JOIN untuk mengambil 'name' dari tabel users dan relasi sisa kolom dari tabel doctors
        final List<Map<String, dynamic>> result = await db.rawQuery(
          '''
          SELECT u.name, u.email, d.no_hp, d.str_number, d.spesialisasi, d.tanggal_lahir, d.jenis_kelamin
          FROM users u
          LEFT JOIN doctors d ON u.id = d.userId
          WHERE LOWER(TRIM(u.email)) = ?
        ''',
          [cleanEmail],
        );

        if (result.isNotEmpty) {
          final data = result.first;
          setState(() {
            _namaDokter = data['name'] ?? 'Dr. Tanpa Nama';
            _spesialisasi =
                (data['spesialisasi'] == null || data['spesialisasi'] == '-')
                ? 'Dokter Spesialis Paru'
                : data['spesialisasi'];
            _tanggalLahir = data['tanggal_lahir'] ?? '-';
            _jenisKelamin = data['jenis_kelamin'] ?? '-';
            _noHp = data['no_hp'] ?? '-';
            _email = data['email'] ?? '-';
            _strNumber = data['str_number'] ?? '-';
          });
          return;
        }
      }

      // Fallback cadangan eksternal
      setState(() {
        _namaDokter = prefs.getString('doctor_name') ?? 'Dr. Budi Santoso';
        _spesialisasi = 'Dokter Spesialis Paru';
        _tanggalLahir = '12 Oktober 1990';
        _jenisKelamin = 'Pria';
        _noHp = '0812345678';
        _email = savedEmail ?? 'dr.budi@tbcare.com';
        _strNumber = 'STR-2024-8842';
      });
    } catch (e) {
      debugPrint('Gagal memuat data profil dokter dari SQLite: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      appBar: const TBCareAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: TBCareTheme.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Avatar Lingkaran
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: TBCareTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 54,
                      color: TBCareTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    _namaDokter,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _spesialisasi,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  // Card Informasi Pribadi
                  _buildCard(
                    title: 'Informasi Pribadi',
                    children: [
                      _buildInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Tanggal Lahir',
                        value: _tanggalLahir,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.people_outline,
                        label: 'Jenis Kelamin',
                        value: _jenisKelamin,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Card Informasi Akun Medis
                  _buildCard(
                    title: 'Informasi Akun',
                    children: [
                      _buildInfoRow(
                        icon: Icons.phone_android_outlined,
                        label: 'No HP',
                        value: _noHp,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: _email,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.medical_information_outlined,
                        label: 'STR Number',
                        value: _strNumber,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Menunggu pemicu edit selesai, lalu memuat ulang data terbaru
                            await context.push(Routes.profilMedisEdit);
                            _loadProfileData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TBCareTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Edit Profil',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tombol Keluar Sistem
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: Color(0xFFD9534F)),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Color(0xFFD9534F),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFFDE8E8),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: TBCareTheme.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Logout'),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi TBCare?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                context.go(Routes.login);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
