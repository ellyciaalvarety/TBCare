//features/dokter/profil/edit_profil_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/database/database_helper.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _strController = TextEditingController();

  String _selectedGender = 'Pria';
  bool _isLoading = true;

  // Menggunakan userId hasil relasi sebagai acuan klausa WHERE utama
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  // Memuat data profil gabungan dari tabel users & doctors berdasarkan sesi email login
  Future<void> _loadCurrentProfile() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedEmail =
          prefs.getString('email') ?? prefs.getString('doctor_email');

      if (savedEmail != null) {
        final db = await DatabaseHelper().database;
        final cleanEmail = savedEmail.trim().toLowerCase();

        // Query JOIN untuk menarik data kredensial (users) bersama data spesifik medis (doctors)
        final List<Map<String, dynamic>> result = await db.rawQuery(
          '''
          SELECT u.id AS u_id, u.name, u.email, d.no_hp, d.str_number, d.spesialisasi, d.tanggal_lahir, d.jenis_kelamin
          FROM users u
          LEFT JOIN doctors d ON u.id = d.userId
          WHERE LOWER(TRIM(u.email)) = ?
        ''',
          [cleanEmail],
        );

        if (result.isNotEmpty) {
          final data = result.first;
          _userId = data['u_id'] as int?;
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _birthDateController.text = data['tanggal_lahir'] == '-'
              ? ''
              : (data['tanggal_lahir'] ?? '');
          _phoneController.text = data['no_hp'] == '-'
              ? ''
              : (data['no_hp'] ?? '');
          _strController.text = data['str_number'] == '-'
              ? ''
              : (data['str_number'] ?? '');
          _selectedGender = data['jenis_kelamin'] == 'Wanita'
              ? 'Wanita'
              : 'Pria';

          setState(() {});
          return;
        }
      }

      // Fallback data bawaan jika record tidak ditemukan atau terjadi anomali sesi
      _nameController.text =
          prefs.getString('doctor_name') ?? 'Dr. Budi Santoso';
      _birthDateController.text = '12 Oktober 1990';
      _phoneController.text = '0812345678';
      _emailController.text = savedEmail ?? 'dr.budi@tbcare.com';
      _strController.text = 'STR-2024-8842';
      _selectedGender = 'Pria';
    } catch (e) {
      debugPrint('Gagal memuat data edit profil dokter: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Menyimpan pembaruan data profil ke dalam tabel 'users' dan 'doctors'
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = await DatabaseHelper().database;
      final prefs = await SharedPreferences.getInstance();

      if (_userId == null) {
        throw Exception('User ID tidak valid. Sesi autentikasi kedaluwarsa.');
      }

      final String inputEmail = _emailController.text.trim().toLowerCase();
      final String inputNama = _nameController.text.trim();

      // Menggunakan mekanisme Transaction agar pembaruan data antar-tabel konsisten dan aman
      await db.transaction((txn) async {
        // 1. Perbarui nama dan email di tabel induk 'users'
        await txn.update(
          'users',
          {'name': inputNama, 'email': inputEmail},
          where: 'id = ?',
          whereArgs: [_userId],
        );

        // 2. Perbarui data spesifik dokter di tabel 'doctors'
        await txn.update(
          'doctors',
          {
            'no_hp': _phoneController.text.trim(),
            'str_number': _strController.text.trim(),
            'tanggal_lahir': _birthDateController.text.trim(),
            'jenis_kelamin': _selectedGender,
          },
          where: 'userId = ?',
          whereArgs: [_userId],
        );
      });

      // Sinkronisasi data SharedPreferences agar nama di header utama ikut ter-update tanpa relogin
      await prefs.setString('doctor_name', inputNama);
      await prefs.setString('email', inputEmail);
      await prefs.setString('doctor_email', inputEmail);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil dokter berhasil diperbarui'),
            backgroundColor: TBCareTheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      debugPrint('Gagal menyimpan perubahan profil dokter: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memperbarui data: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _strController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: TBCareTheme.primary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Edit Profil Dokter',
          style: TextStyle(
            color: TBCareTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Simpan',
                style: TextStyle(
                  color: TBCareTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF0F0F0)),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: TBCareTheme.primary),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                children: [
                  _buildInputLabel('Nama Lengkap Dokter'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: _buildInputDecoration(
                      'Masukkan nama lengkap beserta gelar',
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Nama tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel('Tanggal Lahir'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _birthDateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: _buildInputDecoration('Pilih tanggal lahir')
                        .copyWith(
                          suffixIcon: const Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Tanggal lahir belum dipilih'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel('Jenis Kelamin'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: 'Pria',
                              groupValue: _selectedGender,
                              onChanged: (value) {
                                setState(() => _selectedGender = value!);
                              },
                              activeColor: TBCareTheme.primary,
                            ),
                            const Text(
                              'Pria',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: 'Wanita',
                              groupValue: _selectedGender,
                              onChanged: (value) {
                                setState(() => _selectedGender = value!);
                              },
                              activeColor: TBCareTheme.primary,
                            ),
                            const Text(
                              'Wanita',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInputLabel('No. Handphone Medis'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _buildInputDecoration(
                      'Masukkan nomor handphone aktif',
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Nomor HP tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel('Email Akun'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration('Masukkan alamat email'),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!v.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildInputLabel('Nomor STR (Surat Tanda Registrasi)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _strController,
                    decoration: _buildInputDecoration(
                      'Masukkan nomor STR resmi',
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Nomor STR tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4A4A4A),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBBBBBB)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TBCareTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 10, 12),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: TBCareTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            '${picked.day} ${_getMonthName(picked.month)} ${picked.year}';
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }
}
