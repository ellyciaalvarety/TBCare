import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';
import 'package:tbcare/shared/widgets/tbcare_app_bar.dart';

class PasienListItem {
  final String id;
  final String pid;
  final String nama;
  final double kepatuhan;
  final String terakhirCek;
  final PasienRisiko risiko;

  const PasienListItem({
    required this.id,
    required this.pid,
    required this.nama,
    required this.kepatuhan,
    required this.terakhirCek,
    required this.risiko,
  });
}

enum PasienRisiko { stabil, perlaPantauan, risikoTinggi }

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  PasienRisiko? _filterRisiko;

  final List<PasienListItem> _allPasien = const [
    PasienListItem(
      id: '1',
      pid: 'TBC-2023-0891',
      nama: 'Budi Santoso',
      kepatuhan: 0.65,
      terakhirCek: '2 jam lalu',
      risiko: PasienRisiko.risikoTinggi,
    ),
    PasienListItem(
      id: '2',
      pid: 'TBC-2023-0942',
      nama: 'Siti Aminah',
      kepatuhan: 0.82,
      terakhirCek: '5 jam lalu',
      risiko: PasienRisiko.perlaPantauan,
    ),
    PasienListItem(
      id: '3',
      pid: 'TBC-2023-1005',
      nama: 'Agus Wijaya',
      kepatuhan: 0.98,
      terakhirCek: 'Kemarin',
      risiko: PasienRisiko.stabil,
    ),
    PasienListItem(
      id: '4',
      pid: 'TBC-2023-1120',
      nama: 'Dewi Lestari',
      kepatuhan: 0.95,
      terakhirCek: '1 hari lalu',
      risiko: PasienRisiko.stabil,
    ),
    PasienListItem(
      id: '5',
      pid: 'TBC-2023-1205',
      nama: 'Rudi Hartono',
      kepatuhan: 0.71,
      terakhirCek: '3 jam lalu',
      risiko: PasienRisiko.perlaPantauan,
    ),
  ];

  List<PasienListItem> get _filtered {
    return _allPasien.where((p) {
      final matchQuery = _query.isEmpty ||
          p.nama.toLowerCase().contains(_query.toLowerCase()) ||
          p.pid.toLowerCase().contains(_query.toLowerCase());
      final matchFilter =
          _filterRisiko == null || p.risiko == _filterRisiko;
      return matchQuery && matchFilter;
    }).toList()
      ..sort((a, b) {
        const order = {
          PasienRisiko.risikoTinggi: 0,
          PasienRisiko.perlaPantauan: 1,
          PasienRisiko.stabil: 2,
        };
        return order[a.risiko]!.compareTo(order[b.risiko]!);
      });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const TBCareAppBar(),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau ID pasien...',
                    hintStyle: const TextStyle(
                        fontSize: 13, color: Color(0xFFBBBBBB)),
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 18, color: Color(0xFF9E9E9E)),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                size: 16, color: Color(0xFF9E9E9E)),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: TBCareTheme.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Semua',
                        isSelected: _filterRisiko == null,
                        color: const Color(0xFF6B6B6B),
                        onTap: () => setState(() => _filterRisiko = null),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Risiko Tinggi',
                        isSelected:
                            _filterRisiko == PasienRisiko.risikoTinggi,
                        color: TBCareTheme.risikoTinggi,
                        onTap: () => setState(() =>
                            _filterRisiko = PasienRisiko.risikoTinggi),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Perlu Pantauan',
                        isSelected:
                            _filterRisiko == PasienRisiko.perlaPantauan,
                        color: TBCareTheme.perlaPantauan,
                        onTap: () => setState(() =>
                            _filterRisiko = PasienRisiko.perlaPantauan),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Stabil',
                        isSelected: _filterRisiko == PasienRisiko.stabil,
                        color: TBCareTheme.stabil,
                        onTap: () => setState(
                            () => _filterRisiko = PasienRisiko.stabil),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _SummaryBar(pasienList: _allPasien),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: Color(0xFFDDDDDD)),
                        SizedBox(height: 12),
                        Text(
                          'Tidak ada pasien ditemukan',
                          style: TextStyle(
                              fontSize: 14, color: Color(0xFFAAAAAA)),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: TBCareTheme.primary,
                    onRefresh: () async => Future.delayed(
                        const Duration(milliseconds: 800)),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) => _PasienCard(
                        item: filtered[i],
                        onTap: () => context
                            .go('/medis/patients/${filtered[i].id}'),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE0E0E0),
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? color : const Color(0xFF6B6B6B),
          ),
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final List<PasienListItem> pasienList;
  const _SummaryBar({required this.pasienList});

  @override
  Widget build(BuildContext context) {
    final total = pasienList.length;
    final tinggi = pasienList
        .where((p) => p.risiko == PasienRisiko.risikoTinggi)
        .length;
    final pantau = pasienList
        .where((p) => p.risiko == PasienRisiko.perlaPantauan)
        .length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
                label: 'Total',
                value: '$total',
                color: const Color(0xFF6B6B6B)),
            _DividerLine(),
            _SummaryItem(
                label: 'Risiko Tinggi',
                value: '$tinggi',
                color: TBCareTheme.risikoTinggi),
            _DividerLine(),
            _SummaryItem(
                label: 'Perlu Pantauan',
                value: '$pantau',
                color: TBCareTheme.perlaPantauan),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF9E9E9E))),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 0.8, height: 32, color: const Color(0xFFE0E0E0));
  }
}

class _PasienCard extends StatelessWidget {
  final PasienListItem item;
  final VoidCallback onTap;

  const _PasienCard({required this.item, required this.onTap});

  Color get _risikoColor {
    switch (item.risiko) {
      case PasienRisiko.stabil:
        return TBCareTheme.stabil;
      case PasienRisiko.perlaPantauan:
        return TBCareTheme.perlaPantauan;
      case PasienRisiko.risikoTinggi:
        return TBCareTheme.risikoTinggi;
    }
  }

  String get _risikoLabel {
    switch (item.risiko) {
      case PasienRisiko.stabil:
        return 'STABIL';
      case PasienRisiko.perlaPantauan:
        return 'PERLU PANTAUAN';
      case PasienRisiko.risikoTinggi:
        return 'RISIKO TINGGI';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.risiko == PasienRisiko.risikoTinggi
                ? TBCareTheme.risikoTinggi.withOpacity(0.3)
                : const Color(0xFFE8E8E8),
            width: 0.8,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.nama,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A))),
                      const SizedBox(height: 2),
                      Text('ID: ${item.pid}',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _risikoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _risikoColor.withOpacity(0.4),
                        width: 0.8),
                  ),
                  child: Text(_risikoLabel,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _risikoColor)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kepatuhan Obat',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF6B6B6B))),
                    Text('${(item.kepatuhan * 100).toInt()}%',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _risikoColor)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.kepatuhan,
                    backgroundColor: const Color(0xFFF0F0F0),
                    color: _risikoColor,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 11, color: Color(0xFFBBBBBB)),
                    const SizedBox(width: 4),
                    Text('Terakhir cek: ${item.terakhirCek}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFFAAAAAA))),
                  ],
                ),
                const Row(
                  children: [
                    Text('Detail',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: TBCareTheme.primary)),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 10, color: TBCareTheme.primary),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}