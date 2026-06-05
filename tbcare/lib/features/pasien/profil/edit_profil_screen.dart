// features/pasien/profil/edit_profil_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbcare/shared/database/database_helper.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  static const Color _primaryColor = Color(0xFF1A9E8F);
  static const Color _bgColor = Color(0xFFF5F7F7);
  static const Color _errorColor = Color(0xFFD94F4F);

  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _oldPassCtrl = TextEditingController();

  bool _isLoading = true;
  bool _showNewPass = false;
  bool _showConfirmPass = false;
  bool _showOldPass = false;

  int _passStrength = 0;
  bool _confirmMismatch = false;

  String? _currentEmailSession;
  String? _currentPasswordDB;
  int? _userId;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
    _newPassCtrl.addListener(_evaluatePassword);
    _confirmPassCtrl.addListener(_checkConfirm);
  }

  // Memperbaiki logika query JOIN menggunakan userId secara dinamis berdasarkan role
  Future<void> _loadCurrentUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentEmailSession = prefs.getString('email');

      if (_currentEmailSession != null) {
        final db = await DatabaseHelper().database;
        final cleanEmail = _currentEmailSession!.trim().toLowerCase();

        // 1. Ambil data user awal untuk tahu role-nya
        final List<Map<String, dynamic>> userCheck = await db.query(
          'users',
          where: 'LOWER(email) = ?',
          whereArgs: [cleanEmail],
        );

        if (userCheck.isNotEmpty) {
          final userInit = userCheck.first;
          _userRole = userInit['role'] ?? 'patient';

          // 2. Ambil data gabungan profil sesuai tabel role-nya
          List<Map<String, dynamic>> maps = [];
          if (_userRole == 'doctor') {
            maps = await db.rawQuery('''
              SELECT u.id, u.name, u.email, u.password, u.role, d.no_hp AS phone 
              FROM users u
              LEFT JOIN doctors d ON d.userId = u.id
              WHERE LOWER(u.email) = ?
            ''', [cleanEmail]);
          } else {
            maps = await db.rawQuery('''
              SELECT u.id, u.name, u.email, u.password, u.role, p.phone 
              FROM users u
              LEFT JOIN patients p ON p.userId = u.id
              WHERE LOWER(u.email) = ?
            ''', [cleanEmail]);
          }

          if (maps.isNotEmpty) {
            final user = maps.first;
            _userId = user['id'];
            _currentPasswordDB = user['password'];

            _nameCtrl.text = user['name'] ?? '';
            _emailCtrl.text = user['email'] ?? '';

            String phoneRaw = user['phone'] ?? '';
            if (phoneRaw.startsWith('+62')) {
              phoneRaw = phoneRaw.replaceFirst('+62', '').trim();
            } else if (phoneRaw.startsWith('62')) {
              phoneRaw = phoneRaw.replaceFirst('62', '').trim();
            }
            _phoneCtrl.text = phoneRaw;
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading profile data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _evaluatePassword() {
    final p = _newPassCtrl.text;
    int strength = 0;
    if (p.isEmpty) {
      strength = 0;
    } else if (p.length < 6) {
      strength = 1;
    } else if (p.length < 10 || (!p.contains(RegExp(r'[A-Z]')) || !p.contains(RegExp(r'[0-9]')))) {
      strength = 2;
    } else {
      strength = 3;
    }
    setState(() => _passStrength = strength);
    _checkConfirm();
  }

  void _checkConfirm() {
    setState(() {
      _confirmMismatch = _confirmPassCtrl.text.isNotEmpty && _confirmPassCtrl.text != _newPassCtrl.text;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    _oldPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSimpan() async {
    if (_userId == null) return;
    _checkConfirm();

    if (_formKey.currentState!.validate() && !_confirmMismatch) {
      if (_newPassCtrl.text.isNotEmpty && _oldPassCtrl.text != _currentPasswordDB) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password lama salah!'), backgroundColor: _errorColor),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final db = await DatabaseHelper().database;

        // 1. Update Tabel Users
        final Map<String, dynamic> updatedUserData = {
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim().toLowerCase(),
        };

        if (_newPassCtrl.text.isNotEmpty) {
          updatedUserData['password'] = _newPassCtrl.text;
        }

        await db.update('users', updatedUserData, where: 'id = ?', whereArgs: [_userId]);

        // 2. Update/Insert Tabel berdasarkan Role secara tepat
        if (_userRole == 'doctor') {
          final List<Map<String, dynamic>> doctorCheck = await db.query(
            'doctors',
            where: 'userId = ?',
            whereArgs: [_userId],
          );

          if (doctorCheck.isNotEmpty) {
            await db.update(
              'doctors',
              {'no_hp': _phoneCtrl.text.trim()},
              where: 'userId = ?',
              whereArgs: [_userId],
            );
          } else {
            await db.insert('doctors', {
              'userId': _userId,
              'no_hp': _phoneCtrl.text.trim(),
              'spesialisasi': 'Umum',
              'str_number': '-',
            });
          }
        } else {
          final List<Map<String, dynamic>> patientCheck = await db.query(
            'patients',
            where: 'userId = ?',
            whereArgs: [_userId],
          );

          if (patientCheck.isNotEmpty) {
            await db.update(
              'patients',
              {'nama': _nameCtrl.text.trim(), 'phone': _phoneCtrl.text.trim()},
              where: 'userId = ?',
              whereArgs: [_userId],
            );
          } else {
            await db.insert('patients', {
              'userId': _userId,
              'nama': _nameCtrl.text.trim(),
              'phone': _phoneCtrl.text.trim(),
              'pid': 'P-${_nameCtrl.text.trim().hashCode.abs().toString().substring(0, 4)}',
              'kepatuhan': 100.0,
              'terakhir_cek': DateTime.now().toIso8601String().substring(0, 10),
              'risiko': 'PasienRisiko.stabil',
            });
          }
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', _emailCtrl.text.trim().toLowerCase());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profil berhasil diperbarui'),
              backgroundColor: _primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data: $e'), backgroundColor: _errorColor),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildAvatarSection(),
              const SizedBox(height: 32),
              _buildNameField(),
              const SizedBox(height: 20),
              _buildEmailField(),
              const SizedBox(height: 20),
              _buildPhoneField(),
              const SizedBox(height: 20),
              _buildPasswordBaru(),
              const SizedBox(height: 20),
              _buildKonfirmasiPassword(),
              const SizedBox(height: 20),
              _buildPasswordLama(),
              const SizedBox(height: 32),
              _buildSimpanButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 40,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.of(context).maybePop(),
        padding: const EdgeInsets.only(left: 12),
      ),
      title: const Text('Edit Profil', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: ClipOval(child: Icon(Icons.person, size: 60, color: Colors.grey.shade500)),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Nama Lengkap'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameCtrl,
          keyboardType: TextInputType.name,
          decoration: _inputDecoration(hint: 'Masukkan nama lengkap'),
          validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Email'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(hint: 'johndoe@gmail.com'),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
            if (!v.contains('@')) return 'Format email tidak valid';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('No HP'),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              alignment: Alignment.center,
              child: const Text('+62', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration(hint: '812345678'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'No HP tidak boleh kosong';
                  if (v.length < 8) return 'No HP tidak valid';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordBaru() {
    final strengthLabels = ['', 'WEAK', 'MEDIUM', 'STRONG'];
    final strengthColors = [Colors.grey.shade300, _errorColor, const Color(0xFFF0A500), _primaryColor];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Password Baru (Opsional)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _newPassCtrl,
          obscureText: !_showNewPass,
          decoration: _inputDecoration(
            hint: 'Kosongkan jika tidak ingin diubah',
            suffix: IconButton(
              icon: Icon(_showNewPass ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
              onPressed: () => setState(() => _showNewPass = !_showNewPass),
            ),
          ),
        ),
        if (_passStrength > 0) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _passStrength / 3,
              minHeight: 4,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(strengthColors[_passStrength]),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'STRENGTH: ${strengthLabels[_passStrength]}',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: strengthColors[_passStrength], letterSpacing: 0.8),
          ),
        ],
      ],
    );
  }

  Widget _buildKonfirmasiPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Konfirmasi Password Baru'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPassCtrl,
          obscureText: !_showConfirmPass,
          onChanged: (_) => _checkConfirm(),
          decoration: _inputDecoration(
            hint: 'Ulangi password baru',
            hasError: _confirmMismatch,
            suffix: _confirmMismatch
                ? const Icon(Icons.error, color: _errorColor)
                : IconButton(
              icon: Icon(_showConfirmPass ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
              onPressed: () => setState(() => _showConfirmPass = !_showConfirmPass),
            ),
          ),
        ),
        if (_confirmMismatch) ...[
          const SizedBox(height: 6),
          const Text('Password tidak cocok', style: TextStyle(fontSize: 12, color: _errorColor, fontWeight: FontWeight.w500)),
        ],
      ],
    );
  }

  Widget _buildPasswordLama() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Password Lama'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _oldPassCtrl,
          obscureText: !_showOldPass,
          decoration: _inputDecoration(
            hint: 'Wajib diisi jika mengganti password',
            suffix: IconButton(
              icon: Icon(_showOldPass ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
              onPressed: () => setState(() => _showOldPass = !_showOldPass),
            ),
          ),
          validator: (v) {
            if (_newPassCtrl.text.isNotEmpty && (v == null || v.isEmpty)) {
              return 'Masukkan password lama untuk konfirmasi perubahan';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSimpanButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _onSimpan,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87));

  InputDecoration _inputDecoration({required String hint, Widget? suffix, bool hasError = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade100,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: hasError ? _errorColor : Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: hasError ? _errorColor : Colors.grey.shade200, width: hasError ? 1.5 : 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: hasError ? _errorColor : _primaryColor, width: 1.5)),
    );
  }
}