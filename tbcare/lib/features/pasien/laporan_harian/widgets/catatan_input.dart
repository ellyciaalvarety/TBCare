import 'package:flutter/material.dart';
import 'package:tbcare/app/theme.dart';

class CatatanInput extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? initialValue;

  const CatatanInput({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

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
      setState(() => _charCount = _ctrl.text.length);
      widget.onChanged(_ctrl.text);
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _ctrl,
            maxLines: 4,
            maxLength: _maxChar,
            buildCounter: (_, {required currentLength, maxLength, required isFocused}) =>
                null, // sembunyikan counter default
            decoration: InputDecoration(
              hintText: 'Tulis catatan tambahan di sini...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFFBBBBBB),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: TBCareTheme.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Opsional — dokter akan membaca ini',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFBBBBBB),
                  ),
                ),
                Text(
                  '$_charCount/$_maxChar',
                  style: TextStyle(
                    fontSize: 11,
                    color: _charCount > _maxChar * 0.9
                        ? TBCareTheme.perlaPantauan
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