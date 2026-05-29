import 'package:flutter/material.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/widgets/tbcare_app_bar.dart';

class Appointment {
  final String id;
  final String patientName;
  final String patientId;
  final String type;
  final String time;
  final String room;
  bool isCompleted;

  Appointment({
    required this.id,
    required this.patientName,
    required this.patientId,
    required this.type,
    required this.time,
    required this.room,
    this.isCompleted = false,
  });
}

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  final List<Appointment> _appointments = [
    Appointment(
      id: '1',
      patientName: 'Siti Aminah',
      patientId: 'TBC-2023-0422',
      type: 'Konsultasi',
      time: '08:30 — 09:00',
      room: 'A 3.05',
      isCompleted: true,
    ),
    Appointment(
      id: '2',
      patientName: 'John Doe',
      patientId: 'TBC-2023-0422',
      type: 'Konsultasi',
      time: '09:00 — 10:00',
      room: 'A 3.05',
      isCompleted: false,
    ),
    Appointment(
      id: '3',
      patientName: 'Windah',
      patientId: 'TBC-2023-0422',
      type: 'Konsultasi',
      time: '10:00 — 11:00',
      room: 'A 3.05',
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      appBar: const TBCareAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Jadwal Hari Ini',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _appointments.length,
              itemBuilder: (_, i) =>
                  _buildAppointmentCard(_appointments[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PID: ${appointment.patientId}',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              if (appointment.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F7F3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      color: TBCareTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            appointment.type,
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time,
                  size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(appointment.time,
                  style: TextStyle(
                      fontSize: 16, color: Colors.grey.shade700)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(appointment.room,
                  style: TextStyle(
                      fontSize: 16, color: Colors.grey.shade700)),
            ],
          ),
          const SizedBox(height: 22),
          if (!appointment.isCompleted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _markAsCompleted(appointment.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TBCareTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Selesai',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text('Selesai',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade600)),
              ),
            ),
        ],
      ),
    );
  }

  void _markAsCompleted(String id) {
    setState(() {
      final index = _appointments.indexWhere((a) => a.id == id);
      if (index != -1) _appointments[index].isCompleted = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Konsultasi telah selesai'),
        backgroundColor: TBCareTheme.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }
}