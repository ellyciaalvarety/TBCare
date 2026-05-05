import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      home: const EditProfilScreen(),
    );
  }
}

// ─── EditProfilScreen ─────────────────────────────────────────────────────────

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

  final _emailCtrl = TextEditingController(text: 'johndoe@gmail.com');
  final _phoneCtrl = TextEditingController(text: '812345678');
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _oldPassCtrl = TextEditingController();

  bool _showNewPass = false;
  bool _showConfirmPass = false;
  bool _showOldPass = false;

  // Password strength: 0=empty, 1=weak, 2=medium, 3=strong
  int _passStrength = 0;
  bool _confirmMismatch = false;

  @override
  void initState() {
    super.initState();
    _newPassCtrl.addListener(_evaluatePassword);
    _confirmPassCtrl.addListener(_checkConfirm);
  }

  void _evaluatePassword() {
    final p = _newPassCtrl.text;
    int strength = 0;
    if (p.isEmpty) {
      strength = 0;
    } else if (p.length < 6) {
      strength = 1;
    } else if (p.length < 10 ||
        (!p.contains(RegExp(r'[A-Z]')) || !p.contains(RegExp(r'[0-9]')))) {
      strength = 2;
    } else {
      strength = 3;
    }
    setState(() => _passStrength = strength);
    _checkConfirm();
  }

  void _checkConfirm() {
    setState(() {
      _confirmMismatch =
          _confirmPassCtrl.text.isNotEmpty &&
          _confirmPassCtrl.text != _newPassCtrl.text;
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    _oldPassCtrl.dispose();
    super.dispose();
  }

  void _onSimpan() {
    _checkConfirm();
    if (_formKey.currentState!.validate() && !_confirmMismatch) {
      // TODO: Proses simpan perubahan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil berhasil diperbarui'),
          backgroundColor: _primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildAvatarSection(),
              const SizedBox(height: 32),
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

  // ── App Bar ────────────────────────────────────────────────────────────────

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
      title: const Text(
        'Edit Akun',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Avatar ─────────────────────────────────────────────────────────────────

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
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Icon(Icons.person, size: 60, color: Colors.grey.shade500),
              // Ganti dengan foto profil jika tersedia:
              // child: Image.asset('assets/avatar.png', fit: BoxFit.cover),
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: GestureDetector(
              onTap: () {
                // TODO: Buka image picker
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primaryColor,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Email ──────────────────────────────────────────────────────────────────

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

  // ── Phone ──────────────────────────────────────────────────────────────────

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
              child: const Text(
                '+62',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
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

  // ── Password Baru ──────────────────────────────────────────────────────────

  Widget _buildPasswordBaru() {
    final strengthLabels = ['', 'WEAK', 'MEDIUM', 'STRONG'];
    final strengthColors = [
      Colors.grey.shade300,
      _errorColor,
      const Color(0xFFF0A500),
      _primaryColor,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Password Baru'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _newPassCtrl,
          obscureText: !_showNewPass,
          decoration: _inputDecoration(
            hint: '',
            suffix: IconButton(
              icon: Icon(
                _showNewPass
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey,
              ),
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
              valueColor: AlwaysStoppedAnimation<Color>(
                strengthColors[_passStrength],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'STRENGTH: ${strengthLabels[_passStrength]}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: strengthColors[_passStrength],
              letterSpacing: 0.8,
            ),
          ),
        ],
      ],
    );
  }

  // ── Konfirmasi Password ────────────────────────────────────────────────────

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
            hint: '',
            hasError: _confirmMismatch,
            suffix: _confirmMismatch
                ? const Icon(Icons.error, color: _errorColor)
                : IconButton(
                    icon: const Icon(
                      Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _showConfirmPass = !_showConfirmPass),
                  ),
          ),
        ),
        if (_confirmMismatch) ...[
          const SizedBox(height: 6),
          const Text(
            'Passwords do not match',
            style: TextStyle(
              fontSize: 12,
              color: _errorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  // ── Password Lama ──────────────────────────────────────────────────────────

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
            hint: '',
            suffix: IconButton(
              icon: const Icon(
                Icons.visibility_off_outlined,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _showOldPass = !_showOldPass),
            ),
          ),
          validator: (v) {
            if (_newPassCtrl.text.isNotEmpty && (v == null || v.isEmpty)) {
              return 'Masukkan password lama untuk konfirmasi';
            }
            return null;
          },
        ),
      ],
    );
  }

  // ── Simpan Button ──────────────────────────────────────────────────────────

  Widget _buildSimpanButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _onSimpan,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Simpan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    Widget? suffix,
    bool hasError = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade100,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? _errorColor : Colors.grey.shade200,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? _errorColor : Colors.grey.shade200,
          width: hasError ? 1.5 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? _errorColor : _primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 1.5),
      ),
    );
  }
}
