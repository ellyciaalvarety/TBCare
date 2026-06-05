import 'package:flutter/material.dart';
import 'package:tbcare/app/theme.dart';

class TBCareAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  const TBCareAppBar({super.key, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Row(
        children: [
          Icon(
            Icons.health_and_safety_rounded,
            color: TBCareTheme.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'TBCare',
            style: TextStyle(
              color: TBCareTheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: const Color(0xFFF0F0F0),
        ),
      ),
    );
  }
}