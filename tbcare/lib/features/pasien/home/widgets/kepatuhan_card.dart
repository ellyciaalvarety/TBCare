import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:tbcare/app/theme.dart';

class KepatuhanCard extends StatelessWidget {
  final int hariKe;
  final int totalHari;
  final double persen; // 0.0 – 1.0

  const KepatuhanCard({
    super.key,
    required this.hariKe,
    required this.totalHari,
    required this.persen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teks kepatuhan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kepatuhan Obat',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: TBCareTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      persen >= 0.8
                          ? 'Anda berada di jalur yang benar!'
                          : persen >= 0.5
                              ? 'Tetap semangat, jangan lupa minum obat!'
                              : 'Yuk tingkatkan kepatuhan minum obat.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B6B6B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Hari ke badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: TBCareTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: TBCareTheme.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'HARI KE $hariKe/$totalHari',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: TBCareTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Ring chart
              _KepatuhanRing(persen: persen),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Ring chart ────────────────────────────────────────────────────
class _KepatuhanRing extends StatelessWidget {
  final double persen;
  const _KepatuhanRing({required this.persen});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: CustomPaint(
        painter: _RingPainter(persen: persen),
        child: Center(
          child: Text(
            '${(persen * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double persen;
  _RingPainter({required this.persen});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width - 10) / 2;
    const strokeWidth = 7.0;

    // Track (background ring)
    final trackPaint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = TBCareTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,          // mulai dari atas
      2 * math.pi * persen,  // sweep sesuai persen
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.persen != persen;
}