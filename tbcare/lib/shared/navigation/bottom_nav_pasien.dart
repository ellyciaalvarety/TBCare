import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tbcare/app/routes.dart';
import 'package:tbcare/app/theme.dart';

class BottomNavPasien extends StatelessWidget {
  final Widget child;
  const BottomNavPasien({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith(Routes.jadwalPasien)) return 1;
    if (location.startsWith(Routes.riwayat)) return 2;
    if (location.startsWith(Routes.profilPasien)) return 3;
    return 0; // beranda
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.pasienHome);
        break;
      case 1:
        context.go(Routes.jadwalPasien);
        break;
      case 2:
        context.go(Routes.riwayat);
        break;
      case 3:
        context.go(Routes.profilPasien);
        break;
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
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
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