import 'package:flutter/material.dart';

class DetailHarianScreen extends StatelessWidget {
  const DetailHarianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF9),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      icon: Icons.local_pharmacy_rounded,
                      title: 'Laporan Minum Obat',
                    ),
                    const SizedBox(height: 10),
                    _buildObatCard(),
                    const SizedBox(height: 20),
                    _buildSectionHeader(
                      icon: Icons.assignment_rounded,
                      title: 'Laporan Kondisi & Gejala',
                    ),
                    const SizedBox(height: 10),
                    _buildGejalaCard(),
                    const SizedBox(height: 20),
                    _buildCatatanCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0D9E8A),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '21 Mei 2026',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D9E8A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0D9E8A), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A2E2B),
          ),
        ),
      ],
    );
  }

  Widget _buildObatCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.access_time_rounded,
                color: Color(0xFF0D9E8A),
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                'Obat jam 18:00',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A2E2B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildObatItem(
            name: 'Isoniazid',
            dose: '300mg • 1 Tablet • Sebelum Makan',
            isChecked: true,
          ),
          const SizedBox(height: 8),
          _buildObatItem(
            name: 'Rifampicin',
            dose: '300mg • 1 Tablet • Sebelum Makan',
            isChecked: false,
          ),
        ],
      ),
    );
  }

  Widget _buildObatItem({
    required String name,
    required String dose,
    required bool isChecked,
  }) {
    final Color bgColor = isChecked
        ? const Color(0xFFF0FAF8)
        : const Color(0xFFFFF0F0);
    final Color iconColor = isChecked
        ? const Color(0xFF0D9E8A)
        : const Color(0xFFE05555);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.medication_rounded, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2E2B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dose,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Icon(
            isChecked
                ? Icons.check_circle_outline_rounded
                : Icons.cancel_outlined,
            color: iconColor,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildGejalaCard() {
    final List<Map<String, dynamic>> gejalaList = [
      {'icon': Icons.air_rounded, 'label': 'Batuk'},
      {'icon': Icons.thermostat_rounded, 'label': 'Demam'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: gejalaList
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildGejalaItem(
                  icon: item['icon'] as IconData,
                  label: item['label'] as String,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildGejalaItem({required IconData icon, required String label}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAF9),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0D9E8A), size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A2E2B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatatanCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF0D9E8A).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan Pasien',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D9E8A),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF5FAF9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const TextField(
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10),
                hintText: 'Tulis catatan di sini...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
