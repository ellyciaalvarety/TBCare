//features/pasien/laporan_harian/widgets/catatan_input.dart

import 'package:flutter/material.dart';
import 'package:tbcare/app/theme.dart';

class CatatanInput extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? initialValue;

  const CatatanInput({super.key, required this.onChanged, this.initialValue});

  @override
  State<CatatanInput> createState() => _CatatanInputState();
}

class _CatatanInputState extends State<CatatanInput> {
  late final TextEditingController _ctrl;
  int _charCount = 0;
  static const int _maxChar = 300;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue ?? '');
    _charCount = _ctrl.text.length;
    _ctrl.addListener(() {
      if (mounted) {
        setState(() => _charCount = _ctrl.text.length);
        widget.onChanged(_ctrl.text);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 0.8),
      ),
      child: Column(
        children: [
          TextField(
            controller: _ctrl,
            maxLines: 4,
            maxLength: _maxChar,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              hintText:
                  'Tulis gejala lain atau keluhan efek samping obat di sini...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFFBBBBBB),
              ),
              counterText:
                  '', // Sembunyikan counter bawaan TextField bawaan di pojok kanan bawah
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: TBCareTheme.primary,
                  width: 1.2,
                ),
              ),
              contentPadding: const EdgeInsets.all(12),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Opsional — dokter akan membaca keluhan ini',
                  style: TextStyle(fontSize: 11, color: Color(0xFFBBBBBB)),
                ),
                Text(
                  '$_charCount/$_maxChar',
                  style: TextStyle(
                    fontSize: 11,
                    color: _charCount > _maxChar * 0.9
                        ? Colors.orange
                        : const Color(0xFFBBBBBB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

