import 'package:flutter/material.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController(text: 'johndoe@gmail.com');
  final _phoneController = TextEditingController(text: '812345678');
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _oldPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscureOldPassword = true;
  bool _passwordMismatch = false;

  static const Color _primaryColor = Color(0xFF2D8C7E);
  static const Color _errorColor = Color(0xFFE53935);
  static const Color _labelColor = Color(0xFF333333);
  static const Color _fieldBackground = Color(0xFFF2F2F2);
  static const Color _borderError = Color(0xFFE53935);

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _oldPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswords() {
    setState(() {
      _passwordMismatch =
          _confirmPasswordController.text.isNotEmpty &&
          _newPasswordController.text != _confirmPasswordController.text;
    });
  }

  void _onSave() {
    _validatePasswords();
    if (_formKey.currentState!.validate() && !_passwordMismatch) {
      // TODO: Implementasi logika simpan
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profil berhasil disimpan')));
    }
  }

  InputDecoration _fieldDecoration({
    bool hasError = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: _fieldBackground,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: hasError
            ? const BorderSide(color: _borderError, width: 1.5)
            : BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: hasError
            ? const BorderSide(color: _borderError, width: 1.5)
            : const BorderSide(color: _primaryColor, width: 1.5),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _labelColor,
        ),
      ),
    );
  }

  Widget _buildPasswordToggleIcon(bool obscure, VoidCallback onTap) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: Colors.grey,
      ),
      onPressed: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: _primaryColor),
        title: const Text(
          'Edit Akun',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFB0D4D0),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/4202/4202843.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Pilih foto profil
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: _primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Email
              _buildLabel('Email'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _fieldDecoration(),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // No HP
              _buildLabel('No HP'),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _fieldBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '+62',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _fieldDecoration(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Password Baru
              _buildLabel('Password Baru'),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                onChanged: (_) => _validatePasswords(),
                decoration: _fieldDecoration(
                  suffixIcon: _buildPasswordToggleIcon(
                    _obscureNewPassword,
                    () => setState(
                      () => _obscureNewPassword = !_obscureNewPassword,
                    ),
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Konfirmasi Password Baru
              _buildLabel('Konfirmasi Password Baru'),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                onChanged: (_) => _validatePasswords(),
                decoration: _fieldDecoration(
                  hasError: _passwordMismatch,
                  suffixIcon: _passwordMismatch
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.error, color: _errorColor),
                        )
                      : _buildPasswordToggleIcon(
                          _obscureConfirmPassword,
                          () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              if (_passwordMismatch)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Passwords do not match',
                    style: TextStyle(color: _errorColor, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),

              // Password Lama
              _buildLabel('Password Lama'),
              TextFormField(
                controller: _oldPasswordController,
                obscureText: _obscureOldPassword,
                decoration: _fieldDecoration(
                  suffixIcon: _buildPasswordToggleIcon(
                    _obscureOldPassword,
                    () => setState(
                      () => _obscureOldPassword = !_obscureOldPassword,
                    ),
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
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
