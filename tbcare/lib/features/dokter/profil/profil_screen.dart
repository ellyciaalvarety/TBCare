import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/widgets/tbcare_app_bar.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      appBar: const TBCareAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: TBCareTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded,
                  size: 54, color: TBCareTheme.primary),
            ),
            const SizedBox(height: 12),

            const Text(
              'Dr. Budi Santoso',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 4),
            const Text(
              'Dokter Spesialis Paru',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // Informasi Pribadi
            _buildCard(
              title: 'Informasi Pribadi',
              children: [
                _buildInfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Tanggal Lahir',
                    value: '12 Oktober 1990'),
                const SizedBox(height: 12),
                _buildInfoRow(
                    icon: Icons.people_outline,
                    label: 'Jenis Kelamin',
                    value: 'Pria'),
              ],
            ),
            const SizedBox(height: 16),

            // Informasi Akun
            _buildCard(
              title: 'Informasi Akun',
              children: [
                _buildInfoRow(
                    icon: Icons.phone_android_outlined,
                    label: 'No HP',
                    value: '0812345678'),
                const SizedBox(height: 12),
                _buildInfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: 'dr.budi@tbcare.com'),
                const SizedBox(height: 12),
                _buildInfoRow(
                    icon: Icons.medical_information_outlined,
                    label: 'STR Number',
                    value: 'STR-2024-8842'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.go(Routes.profilMedisEdit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TBCareTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Edit Profil',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout,
                    color: Color(0xFFD9534F)),
                label: const Text('Logout',
                    style: TextStyle(
                        color: Color(0xFFD9534F),
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFFFDE8E8),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      {required String title, required List<Widget> children}) {
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
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
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
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500)),
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
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
              if (context.mounted) context.go(Routes.login);
            },
            style:
                TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}