// features/auth/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/database/database_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // Status pilihan default peran registrasi
  String _selectedRole = 'pasien';

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String _passwordStrength = '';
  Color _strengthColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(_checkStrength);
  }

  void _checkStrength() {
    final pass = _passCtrl.text;
    if (pass.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _strengthColor = Colors.transparent;
      });
      return;
    }
    if (pass.length < 6) {
      setState(() {
        _passwordStrength = 'Sangat Lemah';
        _strengthColor = Colors.red;
      });
    } else if (pass.length < 10 ||
        !pass.contains(RegExp(r'[A-Z]')) ||
        !pass.contains(RegExp(r'[0-9]'))) {
      setState(() {
        _passwordStrength = 'Sedang';
        _strengthColor = Colors.orange;
      });
    } else {
      setState(() {
        _passwordStrength = 'Kuat';
        _strengthColor = Colors.green;
      });
    }
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = await DatabaseHelper().database;
      final emailClean = _emailCtrl.text.trim().toLowerCase();

      // 1. Validasi apakah email sudah terdaftar di sistem
      final List<Map<String, dynamic>> existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [emailClean],
      );

      if (existingUser.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email sudah terdaftar! Gunakan email lain.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // 2. Simpan kredensial utama ke dalam tabel 'users'
      final int newUserId = await db.insert('users', {
        'name': _idCtrl.text.trim(),
        'email': emailClean,
        'password': _passCtrl.text,
        'role':
            _selectedRole, // Menyimpan string pilihan 'pasien' atau 'dokter'
      });

      // 3. Percabangan penyimpanan data profil berdasarkan peran terpilih
      if (_selectedRole == 'pasien') {
        // Insert profil ke tabel 'patients' jika mendaftar sebagai pasien
        await db.insert('patients', {
          'nama': _idCtrl.text.trim(),
          'userId': newUserId,
          'phone': _phoneCtrl.text.trim(),
          'pid': 'P-${_idCtrl.text.trim().hashCode.toString().substring(0, 4)}',
          'kepatuhan': 100.0,
          'terakhir_cek': DateTime.now().toIso8601String().substring(0, 10),
          'risiko': 'PasienRisiko.stabil',
          'tanggal_lahir': '-',
          'jenis_kelamin': '-',
        });
      } else {
        // Insert profil ke tabel 'doctors' jika mendaftar sebagai dokter/medis
        await db.insert('doctors', {
          'userId': newUserId,
          'no_hp': _phoneCtrl.text.trim(),
          'str_number':
              'STR-${_idCtrl.text.trim().hashCode.toString().substring(0, 5)}', // Generate dummy nomor STR awal
          'spesialisasi': 'Dokter Umum / Spesialis Paru',
          'tanggal_lahir': '-',
          'jenis_kelamin': '-',
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun Berhasil Dibuat! Silakan Login.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go(Routes.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registrasi Gagal: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Daftar Akun Baru',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: TBCareTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Silakan isi form di bawah ini untuk membuat akun ${_selectedRole == 'pasien' ? 'pasien' : 'dokter'}.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Dropdown untuk pemilihan Peran Pengguna
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Daftar Sebagai',
                        prefixIcon: Icon(Icons.assignment_ind_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'pasien',
                          child: Text('Pasien'),
                        ),
                        DropdownMenuItem(
                          value: 'dokter',
                          child: Text('Dokter / Tenaga Medis'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedRole = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _idCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Nama lengkap wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email wajib diisi';
                        if (!v.contains('@')) return 'Format email salah';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor HP',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Nomor HP wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscurePass,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                      validator: (v) => v == null || v.length < 6
                          ? 'Password minimal 6 karakter'
                          : null,
                    ),
                    if (_passwordStrength.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Kekuatan Password: $_passwordStrength',
                          style: TextStyle(
                            color: _strengthColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        prefixIcon: const Icon(Icons.lock_clock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          v != _passCtrl.text ? 'Password tidak cocok' : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TBCareTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _selectedRole == 'pasien'
                                        ? 'Buat Akun Pasien'
                                        : 'Buat Akun Dokter',
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah Punya Akun? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(Routes.login),
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: TBCareTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
