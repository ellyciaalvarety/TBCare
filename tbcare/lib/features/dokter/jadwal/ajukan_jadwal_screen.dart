import 'package:flutter/material.dart';

class AjukanJadwalScreen extends StatefulWidget {
  const AjukanJadwalScreen({super.key});

  @override
  State<AjukanJadwalScreen> createState() => _AjukanJadwalScreenState();
}

class _AjukanJadwalScreenState extends State<AjukanJadwalScreen> {
  static const Color _primaryColor = Color(0xFF1A7A6E);
  static const Color _lightBg = Color(0xFFF2F7F6);
  static const Color _unavailableColor = Color(0xFFE53935);

  // Calendar state
  DateTime _focusedMonth = DateTime(2023, 10);
  int? _selectedDay = 24;

  // Time slots
  final List<String> _timeSlots = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
  ];
  String _selectedTime = '08:00';
  final Set<String> _unavailableTimes = {'12:00'};

  // Bottom nav
  int _currentNavIndex = 0;

  // Days in month helpers
  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  int _firstWeekdayOfMonth(int year, int month) {
    // 1=Mon ... 7=Sun, we want 0-indexed Mon=0
    int wd = DateTime(year, month, 1).weekday; // 1=Mon, 7=Sun
    return wd - 1; // 0=Mon, 6=Sun
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      _selectedDay = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      _selectedDay = null;
    });
  }

  String _monthName(int month) {
    const names = [
      '',
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
    return names[month];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryColor),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Ajukan Jadwal',
          style: TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Agenda'),
                  const SizedBox(height: 8),
                  _buildReadOnlyField('Preview test'),
                  const SizedBox(height: 20),
                  _buildLabel('Ruangan'),
                  const SizedBox(height: 8),
                  _buildReadOnlyField('A 3.06'),
                  const SizedBox(height: 20),
                  _buildLabel('Pilih Tanggal'),
                  const SizedBox(height: 8),
                  _buildCalendar(),
                  const SizedBox(height: 20),
                  _buildLabel('Pilih Waktu'),
                  const SizedBox(height: 12),
                  _buildTimeGrid(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildConfirmButton(),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildReadOnlyField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _lightBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
      ),
    );
  }

  Widget _buildCalendar() {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final daysInMonth = _daysInMonth(year, month);
    final firstWeekday = _firstWeekdayOfMonth(year, month); // 0=Mon

    // Previous month trailing days
    final prevMonthDays = _daysInMonth(year, month - 1 == 0 ? 12 : month - 1);

    // Build grid cells
    List<_CalendarCell> cells = [];

    // Leading cells from prev month
    for (int i = firstWeekday - 1; i >= 0; i--) {
      cells.add(_CalendarCell(day: prevMonthDays - i, isCurrentMonth: false));
    }

    // Current month
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(_CalendarCell(day: d, isCurrentMonth: true));
    }

    // Trailing cells for next month
    int trailing = 7 - (cells.length % 7);
    if (trailing == 7) trailing = 0;
    for (int d = 1; d <= trailing; d++) {
      cells.add(_CalendarCell(day: d, isCurrentMonth: false));
    }

    const dayLabels = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Month header
          Row(
            children: [
              Text(
                '${_monthName(month)} $year',
                style: const TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _prevMonth,
                child: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF888888),
                  size: 22,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _nextMonth,
                child: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF888888),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Day of week labels
          Row(
            children: dayLabels.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          // Calendar grid
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 2,
            crossAxisSpacing: 0,
            childAspectRatio: 1,
            children: cells.map((cell) {
              final isSelected =
                  cell.isCurrentMonth && cell.day == _selectedDay;
              return GestureDetector(
                onTap: cell.isCurrentMonth
                    ? () => setState(() => _selectedDay = cell.day)
                    : null,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: isSelected
                      ? const BoxDecoration(
                          color: _primaryColor,
                          shape: BoxShape.circle,
                        )
                      : null,
                  child: Center(
                    child: Text(
                      '${cell.day}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : cell.isCurrentMonth
                            ? const Color(0xFF333333)
                            : const Color(0xFFBBBBBB),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.8,
      ),
      itemCount: _timeSlots.length,
      itemBuilder: (context, index) {
        final time = _timeSlots[index];
        final isSelected = _selectedTime == time;
        final isUnavailable = _unavailableTimes.contains(time);

        return GestureDetector(
          onTap: isUnavailable
              ? null
              : () => setState(() => _selectedTime = time),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isSelected ? _primaryColor : const Color(0xFFDDDDDD),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isUnavailable
                    ? _unavailableColor
                    : isSelected
                    ? _primaryColor
                    : const Color(0xFF444444),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          onPressed: () {
            // TODO: handle confirmation
          },
          icon: const Icon(Icons.check_circle, color: Colors.white, size: 20),
          label: const Text(
            'Konfirmasi Jadwal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        color: Colors.white,
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (i) => setState(() => _currentNavIndex = i),
        selectedItemColor: _primaryColor,
        unselectedItemColor: const Color(0xFFAAAAAA),
        backgroundColor: Colors.white,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _CalendarCell {
  final int day;
  final bool isCurrentMonth;
  const _CalendarCell({required this.day, required this.isCurrentMonth});
}
