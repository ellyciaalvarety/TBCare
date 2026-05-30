import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbcare/app/theme.dart';

class AjukanJadwalScreen extends StatefulWidget {
  final String patientId;
  const AjukanJadwalScreen({super.key, required this.patientId});

  @override
  State<AjukanJadwalScreen> createState() => _AjukanJadwalScreenState();
}

class _AjukanJadwalScreenState extends State<AjukanJadwalScreen> {
  final _agendaCtrl = TextEditingController();
  final _ruanganCtrl = TextEditingController();

  DateTime _focusedMonth = DateTime(2023, 10);
  DateTime? _selectedDate = DateTime(2023, 10, 24);
  String _selectedTime = '08:00';
  bool _isLoading = false;

  static const _timeSlots = [
    '08:00', '09:00', '10:00',
    '11:00', '12:00', '13:00',
    '14:00', '15:00', '16:00',
  ];

  static const _unavailableTimes = ['12:00'];

  static const _dayNames = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];

  static const _monthNames = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  List<DateTime?> _buildCalendarDays() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    // weekday: 1=Sen, 7=Min — kita skip Minggu (7)
    int startOffset = firstDay.weekday - 1; // 0=Sen
    final days = <DateTime?>[];
    for (int i = 0; i < startOffset; i++) {
      final d = firstDay.subtract(Duration(days: startOffset - i));
      days.add(d);
    }
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, i));
    }
    // isi baris terakhir
    while (days.length % 6 != 0) {
      final last = days.last!;
      days.add(last.add(const Duration(days: 1)));
    }
    return days;
  }

  Future<void> _konfirmasi() async {
    if (_agendaCtrl.text.isEmpty || _ruanganCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agenda dan ruangan wajib diisi'),
          backgroundColor: TBCareTheme.perlaPantauan,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Jadwal berhasil ditambahkan'),
        backgroundColor: TBCareTheme.primary,
      ),
    );
    context.go('/medis/patients/${widget.patientId}');
  }

  @override
  void dispose() {
    _agendaCtrl.dispose();
    _ruanganCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calDays = _buildCalendarDays();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F7F6),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: TBCareTheme.primary, size: 20),
          onPressed: () =>
              context.go('/medis/patients/${widget.patientId}'),
        ),
        title: const Text(
          'Ajukan Jadwal',
          style: TextStyle(
            color: TBCareTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // Agenda
          _FieldLabel(label: 'Agenda'),
          const SizedBox(height: 6),
          _InputField(
            controller: _agendaCtrl,
            hint: 'Preview test',
          ),
          const SizedBox(height: 16),

          // Ruangan
          _FieldLabel(label: 'Ruangan'),
          const SizedBox(height: 6),
          _InputField(
            controller: _ruanganCtrl,
            hint: 'A 3.06',
          ),
          const SizedBox(height: 16),

          // Pilih Tanggal
          _FieldLabel(label: 'Pilih Tanggal'),
          const SizedBox(height: 10),

          // Kalender inline
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Header bulan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_monthNames[_focusedMonth.month]} ${_focusedMonth.year}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: TBCareTheme.primary,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _focusedMonth =
                              DateTime(_focusedMonth.year,
                                  _focusedMonth.month - 1)),
                          child: const Icon(Icons.chevron_left_rounded,
                              color: Color(0xFF9E9E9E)),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _focusedMonth =
                              DateTime(_focusedMonth.year,
                                  _focusedMonth.month + 1)),
                          child: const Icon(Icons.chevron_right_rounded,
                              color: Color(0xFF9E9E9E)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Header hari
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _dayNames
                      .map((d) => SizedBox(
                            width: 36,
                            child: Text(d,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF9E9E9E))),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),

                // Grid tanggal
                GridView.count(
                  crossAxisCount: 6,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 0,
                  childAspectRatio: 1,
                  children: calDays.map((d) {
                    if (d == null) return const SizedBox();
                    final isCurrentMonth =
                        d.month == _focusedMonth.month;
                    final isSelected = _selectedDate != null &&
                        d.day == _selectedDate!.day &&
                        d.month == _selectedDate!.month &&
                        d.year == _selectedDate!.year;

                    return GestureDetector(
                      onTap: isCurrentMonth
                          ? () => setState(() => _selectedDate = d)
                          : null,
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? TBCareTheme.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${d.day}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : isCurrentMonth
                                      ? const Color(0xFF1A1A1A)
                                      : const Color(0xFFCCCCCC),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Pilih Waktu
          _FieldLabel(label: 'Pilih Waktu'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
            children: _timeSlots.map((t) {
              final isSelected = _selectedTime == t;
              final isUnavailable = _unavailableTimes.contains(t);

              return GestureDetector(
                onTap: isUnavailable
                    ? null
                    : () => setState(() => _selectedTime = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TBCareTheme.primary.withOpacity(0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? TBCareTheme.primary
                          : const Color(0xFFE0E0E0),
                      width: isSelected ? 1.5 : 0.8,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isUnavailable
                            ? const Color(0xFFE53935)
                            : isSelected
                                ? TBCareTheme.primary
                                : const Color(0xFF3D3D3D),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),

      // Tombol konfirmasi fixed bawah
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        color: const Color(0xFFF0F7F6),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _konfirmasi,
            style: ElevatedButton.styleFrom(
              backgroundColor: TBCareTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_circle_rounded, size: 20),
            label: const Text('Konfirmasi Jadwal',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3D3D3D)));
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _InputField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 14, color: Color(0xFFBBBBBB)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
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
          borderSide:
              const BorderSide(color: TBCareTheme.primary, width: 1.5),
        ),
      ),
    );
  }
}