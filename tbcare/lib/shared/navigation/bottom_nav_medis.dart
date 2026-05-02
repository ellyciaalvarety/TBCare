import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbcare/app/routes.dart';

class BottomNavMedis extends StatelessWidget {
  final Widget child;
  const BottomNavMedis({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith(Routes.jadwalMedis)) return 1;
    if (location.startsWith(Routes.profilMedis)) return 2;
    return 0; // patients
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go(Routes.patients); break;
      case 1: context.go(Routes.jadwalMedis); break;
      case 2: context.go(Routes.profilMedis); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _locationToIndex(location),
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Pasien',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}