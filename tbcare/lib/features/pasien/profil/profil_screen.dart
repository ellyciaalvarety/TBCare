// features/pasien/profil/profil_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/database/database_helper.dart';
import 'edit_profil_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  static const Color _primaryColor = Color(0xFF1A9E8F);
  static const Color _bgColor = Color(0xFFF0F5F4);
  static const Color _cardColor = Colors.white;
  static const Color _logoutBg = Color(0xFFFDECEC);
  static const Color _logoutText = Color(0xFFD94F4F);

  Future<Map<String, dynamic>?> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');

      debugPrint("DEBUG PROFIL: Email dari SharedPreferences adalah '$email'");

      if (email == null || email.trim().isEmpty) {
        return null;
      }

      final db = await DatabaseHelper().database;
      final cleanEmail = email.trim().toLowerCase();

      final List<Map<String, dynamic>> userCheck = await db.query(
        'users',
        where: 'LOWER(TRIM(email)) = ?',
        whereArgs: [cleanEmail],
      );

      if (userCheck.isEmpty) {
        return null;
      }

      final user = userCheck.first;
      final String role = user['role'] ?? 'patient';
      final int userId = user['id'];

      List<Map<String, dynamic>> maps = [];
      if (role == 'doctor') {
        maps = await db.rawQuery(
          '''
          SELECT u.id, u.name, u.email, u.role, 
                 d.no_hp AS phone, d.tanggal_lahir, d.jenis_kelamin
          FROM users u
          LEFT JOIN doctors d ON d.userId = u.id
          WHERE u.id = ?
        ''',
          [userId],
        );
      } else {
        maps = await db.rawQuery(
          '''
          SELECT u.id, u.name, u.email, u.role, 
                 p.phone, p.tanggal_lahir, p.jenis_kelamin
          FROM users u
          LEFT JOIN patients p ON p.userId = u.id
          WHERE u.id = ?
        ''',
          [userId],
        );
      }

      if (maps.isNotEmpty) {
        return maps.first;
      } else {
        return {
          'id': user['id'],
          'name': user['name'],
          'email': user['email'],
          'role': user['role'],
          'phone': '',
          'tanggal_lahir': 'Belum diatur',
          'jenis_kelamin': 'Belum diatur',
        };
      }
    } catch (e) {
      debugPrint("Error fetching user data di profil: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: _primaryColor),
              );
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Gagal memuat data profil akun.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center, // <-- PERBAIKAN DI SINI
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pastikan Anda sudah login dengan benar atau coba muat ulang halaman.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center, // <-- PERBAIKAN DI SINI
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Coba Lagi',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final userData = snapshot.data!;
            final name = userData['name'] ?? '-';
            final email = userData['email'] ?? '-';
            final role = userData['role'] ?? '-';
            final phone = userData['phone'] ?? '';
            final tglLahir = userData['tanggal_lahir'] ?? 'Belum diatur';
            final jenisKelamin = userData['jenis_kelamin'] ?? 'Belum diatur';

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    _buildProfileHeader(name, role),
                    const SizedBox(height: 24),
                    _buildInfoPribadiCard(tglLahir, jenisKelamin),
                    const SizedBox(height: 16),
                    _buildInfoAkunCard(email, phone),
                    const SizedBox(height: 20),
                    _buildLogoutButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 20,
      title: const Row(
        children: [
          Icon(
            Icons.health_and_safety_rounded,
            color: TBCareTheme.primary,
            size: 22,
          ),
          SizedBox(
            width: 8,
          ), // <-- PERBAIKAN: Mengganti SHeavyBox menjadi SizedBox bawaan Flutter
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
    );
  }

  Widget _buildProfileHeader(String name, String role) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade300,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Icon(Icons.person, size: 60, color: Colors.grey.shade500),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Role: ${role.toUpperCase()}',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildInfoPribadiCard(String tglLahir, String jenisKelamin) {
    return _buildSectionCard(
      title: 'Informasi Pribadi',
      children: [
        _buildInfoRow(
          icon: Icons.cake_outlined,
          label: 'Lahir',
          value: tglLahir,
        ),
        const SizedBox(height: 4),
        _buildInfoRow(
          icon: Icons.people_outline,
          label: 'Jenis Kelamin',
          value: jenisKelamin,
        ),
      ],
    );
  }

  Widget _buildInfoAkunCard(String email, String phone) {
    final formattedPhone = phone.isNotEmpty
        ? (phone.startsWith('+62') || phone.startsWith('62')
              ? phone
              : '+62 $phone')
        : '-';

    return _buildSectionCard(
      title: 'Informasi Akun',
      children: [
        _buildInfoRow(
          icon: Icons.phone_android_outlined,
          label: 'No HP',
          value: formattedPhone,
        ),
        const SizedBox(height: 4),
        _buildInfoRow(icon: Icons.email_outlined, label: 'Email', value: email),
        const SizedBox(height: 4),
        _buildInfoRow(
          icon: Icons.lock_outline,
          label: 'Password',
          value: '••••••••',
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilScreen(),
                ),
              );
              if (result == true) {
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Edit',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _showLogoutDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: _logoutBg,
          foregroundColor: _logoutText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.logout, size: 20),
        label: const Text(
          'Logout',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
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
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              await prefs.remove('role');
              await prefs.remove('email');
              if (mounted) context.go(Routes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _logoutText,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
