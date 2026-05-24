import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart'; // Tambahkan import theme

void main() {
  runApp(const TBCareApp());
}

class TBCareApp extends StatelessWidget {
  const TBCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TBCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A9E8F)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const ProfilScreen(),
    );
  }
}

// ─── ProfilScreen ─────────────────────────────────────────────────────────────

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(), // Gunakan appBar bawaan Scaffold
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 28),
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildInfoPribadiCard(),
              const SizedBox(height: 16),
              _buildInfoAkunCard(),
              const SizedBox(height: 20),
              _buildLogoutButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  // ── Profile Header ─────────────────────────────────────────────────────────

  Widget _buildProfileHeader() {
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
            // Ganti dengan Image.asset/network jika ada foto profil:
            // child: Image.asset('assets/avatar.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'John Doe',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'PID: TBC-2024-8842',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // ── Informasi Pribadi Card ─────────────────────────────────────────────────

  Widget _buildInfoPribadiCard() {
    return _buildSectionCard(
      title: 'Informasi Pribadi',
      children: [
        _buildInfoRow(
          icon: Icons.cake_outlined,
          label: 'Lahir',
          value: '12 Oktober 1990',
        ),
        const SizedBox(height: 4),
        _buildInfoRow(
          icon: Icons.people_outline,
          label: 'Jenis Kelamin',
          value: 'Pria',
        ),
      ],
    );
  }

  // ── Informasi Akun Card ────────────────────────────────────────────────────

  Widget _buildInfoAkunCard() {
    return _buildSectionCard(
      title: 'Informasi Akun',
      children: [
        _buildInfoRow(
          icon: Icons.phone_android_outlined,
          label: 'No HP',
          value: '0812345678',
        ),
        const SizedBox(height: 4),
        _buildInfoRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: 'Johndoe@gmail.com',
        ),
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
            onPressed: () {
              // TODO: Navigasi ke halaman edit profil
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

  // ── Logout Button ──────────────────────────────────────────────────────────

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Implementasi logout
          _showLogoutDialog();
        },
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

  // ── Helpers ────────────────────────────────────────────────────────────────

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
          Column(
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
              Navigator.of(ctx).pop(); // tutup dialog dulu

              // Hapus token & role dari SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              await prefs.remove('role');

              // Navigasi ke login, hapus semua history
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