import 'package:flutter/material.dart';
import 'package:tbcare/app/theme.dart';

class GejalaSelector extends StatefulWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const GejalaSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<GejalaSelector> createState() => _GejalaSelectorState();
}

class _GejalaSelectorState extends State<GejalaSelector> {
  static const _gejalaList = [
    {'label': 'Batuk', 'icon': Icons.air},
    {'label': 'Demam', 'icon': Icons.thermostat},
    {'label': 'Nafsu Makan Berkurang', 'icon': Icons.no_food},
    {'label': 'Sesak Nafas', 'icon': Icons.masks},
    {'label': 'Berkeringat Malam', 'icon': Icons.nightlight_round},
    {'label': 'Lemas', 'icon': Icons.battery_1_bar},
    {'label': 'Nyeri Dada', 'icon': Icons.favorite_border},
    {'label': 'Mual', 'icon': Icons.sick},
  ];

  void _toggle(String label) {
    final list = List<String>.from(widget.selected);
    if (list.contains(label)) {
      list.remove(label);
    } else {
      list.add(label);
    }
    widget.onChanged(list);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.8),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _gejalaList.map((g) {
          final label = g['label'] as String;
          final icon = g['icon'] as IconData;
          final isSelected = widget.selected.contains(label);

          return GestureDetector(
            onTap: () => _toggle(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? TBCareTheme.primary.withOpacity(0.1)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? TBCareTheme.primary
                      : const Color(0xFFE0E0E0),
                  width: isSelected ? 1.5 : 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isSelected
                        ? TBCareTheme.primary
                        : const Color(0xFF9E9E9E),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? TBCareTheme.primary
                          : const Color(0xFF3D3D3D),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: TBCareTheme.primary,
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}