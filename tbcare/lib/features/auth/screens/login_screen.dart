// features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/database/database_helper.dart'; // Import DatabaseHelper Anda

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 1. Ambil instance database SQLite
      final db = await DatabaseHelper().database; //

      // Ambil input email yang bersih dari spasi dan jadikan huruf kecil
      final cleanEmailInput = _emailCtrl.text.trim().toLowerCase();

      // 2. Query user berdasarkan email yang diinputkan
      final List<Map<String, dynamic>> userResult = await db.query(
        'users',
        where:
            'LOWER(TRIM(email)) = ?', // Menggunakan pencarian yang aman (case-insensitive)
        whereArgs: [cleanEmailInput],
      ); //

      // 3. Validasi jika user tidak ditemukan
      if (userResult.isEmpty) {
        if (!mounted) return;
        _showErrorSnackBar(
          'Email belum terdaftar. Silakan daftar terlebih dahulu.',
        ); //
        setState(() => _isLoading = false);
        return;
      }

      final userData = userResult.first; //

      // 4. Validasi password
      if (userData['password'] != _passCtrl.text) {
        //
        if (!mounted) return;
        _showErrorSnackBar('Password yang Anda masukkan salah.'); //
        setState(() => _isLoading = false);
        return;
      }

      // 5. Simpan sesi login ke SharedPreferences berdasarkan data dari SQLite
      final prefs = await SharedPreferences.getInstance(); //
      await prefs.setString('token', 'dummy_token_for_id_${userData['id']}'); //
      await prefs.setString('role', userData['role'] ?? 'pasien'); //
      await prefs.setString('name', userData['name'] ?? ''); //

      // ===== PERBAIKAN: MENYIMPAN EMAIL AGAR PROFIL TIDAK NULL / GAGAL MEMUAT =====
      await prefs.setString('email', userData['email'] ?? cleanEmailInput);
      // ============================================================================

      if (!mounted) return;
      setState(() => _isLoading = false);

      // 6. Arahkan halaman sesuai dengan role user dari database
      final role = userData['role']; //
      if (role == 'pasien') {
        context.go(Routes.pasienHome); //
      } else {
        context.go(Routes.patients); //
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Terjadi kesalahan pada database: $e'); //
      setState(() => _isLoading = false);
    }
  }

  // Helper untuk menampilkan pesan error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    ); //
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24), //
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, //
            children: [
              const SizedBox(height: 48), //
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: TBCareTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ), //
                      child: const Icon(
                        Icons.health_and_safety_rounded,
                        size: 38,
                        color: TBCareTheme.primary,
                      ), //
                    ),
                    const SizedBox(height: 16), //
                    const Text(
                      'TBCare',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: TBCareTheme.primary,
                      ), //
                    ),
                    const SizedBox(height: 4), //
                    Text(
                      'Portal Monitoring Pasien TBC',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ), //
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40), //

              const Text(
                'Selamat Datang',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ), //
              ),
              const SizedBox(height: 4), //
              Text(
                'Log in untuk mengetahui perkembangan anda.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500), //
              ),

              const SizedBox(height: 32), //
              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'name@example.com',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                      ), //
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Email wajib diisi'; //
                        if (!v.contains('@'))
                          return 'Format email tidak valid'; //
                        return null;
                      },
                    ),
                    const SizedBox(height: 16), //
                    // Password
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscurePass,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20), //
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ), //
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass), //
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password wajib diisi'; //
                        }
                        if (v.length < 6)
                          return 'Password minimal 6 karakter'; //
                        return null;
                      },
                    ),
                    const SizedBox(height: 28), //
                    // Tombol login
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login, //
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ), //
                              )
                            : const Text('Log In'), //
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20), //
              // Link register
              Row(
                mainAxisAlignment: MainAxisAlignment.center, //
                children: [
                  Text(
                    'Pasien baru? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ), //
                  ),
                  GestureDetector(
                    onTap: () => context.go(Routes.register), //
                    child: const Text(
                      'Daftar sekarang',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TBCareTheme.primary,
                      ), //
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
