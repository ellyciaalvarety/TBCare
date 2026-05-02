import 'package:flutter/material.dart';
import 'package:tbcare/app/theme.dart';

class KepatuhanChart extends StatefulWidget {
  final List<double>? data; // 0.0 – 1.0 per hari
  const KepatuhanChart({super.key, this.data});

  @override
  State<KepatuhanChart> createState() => _KepatuhanChartState();
}

class _KepatuhanChartState extends State<KepatuhanChart> {
  int? _hoveredIndex;

  // Data dummy — nanti dari API
  late final List<double> _data;

  @override
  void initState() {
    super.initState();
    _data = widget.data ??
        [
          0.9, 1.0, 0.8, 1.0, 0.7, 0.9, 1.0,
          0.6, 0.8, 1.0, 0.9, 0.85, 0.7, 1.0,
          1.0, 0.9, 0.8, 0.75, 0.9, 1.0, 0.95,
          0.88, 0.7, 0.9, 1.0, 0.85, 0.9, 0.8,
          1.0, 0.88,
        ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bulan navigasi
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.chevron_left_rounded,
                color: Color(0xFF9E9E9E)),
            const Text(
              'November',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3D3D3D),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF9E9E9E)),
          ],
        ),
        const SizedBox(height: 16),

        // Chart area
        SizedBox(
          height: 120,
          child: CustomPaint(
            painter: _LinePainter(
              data: _data,
              hoveredIndex: _hoveredIndex,
              lineColor: TBCareTheme.primary,
            ),
            child: GestureDetector(
              onPanUpdate: (details) {
                final box = context.findRenderObject() as RenderBox;
                final localX = details.localPosition.dx;
                final width = box.size.width;
                final index =
                    ((localX / width) * _data.length).clamp(0, _data.length - 1).toInt();
                setState(() => _hoveredIndex = index);
              },
              onPanEnd: (_) => setState(() => _hoveredIndex = null),
              onTapDown: (details) {
                final box = context.findRenderObject() as RenderBox;
                final localX = details.localPosition.dx;
                final width = box.size.width;
                final index =
                    ((localX / width) * _data.length).clamp(0, _data.length - 1).toInt();
                setState(() => _hoveredIndex = index);
              },
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Label hari
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Day 1',
                style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
            Text('Today',
                style: TextStyle(
                    fontSize: 10,
                    color: TBCareTheme.primary,
                    fontWeight: FontWeight.w600)),
            Text('Day 30',
                style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
          ],
        ),

        // Tooltip
        if (_hoveredIndex != null) ...[
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: TBCareTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Hari ${_hoveredIndex! + 1}: ${(_data[_hoveredIndex!] * 100).toInt()}%',
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> data;
  final int? hoveredIndex;
  final Color lineColor;

  _LinePainter({
    required this.data,
    required this.hoveredIndex,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final w = size.width;
    final h = size.height;
    final stepX = w / (data.length - 1);

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..strokeWidth = 0.8;

    for (int i = 0; i <= 4; i++) {
      final y = h - (i / 4) * h;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Area fill
    final areaPath = Path();
    areaPath.moveTo(0, h);
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = h - data[i] * h * 0.85;
      if (i == 0) {
        areaPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = h - data[i - 1] * h * 0.85;
        final cpX = (prevX + x) / 2;
        areaPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }
    areaPath.lineTo(w, h);
    areaPath.close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withOpacity(0.15),
            lineColor.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = h - data[i] * h * 0.85;
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = h - data[i - 1] * h * 0.85;
        final cpX = (prevX + x) / 2;
        linePath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }
    canvas.drawPath(linePath, linePaint);

    // Titik merah (drop)
    for (int i = 0; i < data.length; i++) {
      if (data[i] < 0.75) {
        final x = i * stepX;
        final y = h - data[i] * h * 0.85;
        canvas.drawCircle(
          Offset(x, y),
          3.5,
          Paint()..color = TBCareTheme.risikoTinggi,
        );
      }
    }

    // Hover dot
    if (hoveredIndex != null && hoveredIndex! < data.length) {
      final x = hoveredIndex! * stepX;
      final y = h - data[hoveredIndex!] * h * 0.85;
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()..color = lineColor,
      );
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()..color = Colors.white,
      );
      // Vertical guide line
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, h),
        Paint()
          ..color = lineColor.withOpacity(0.2)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.hoveredIndex != hoveredIndex || old.data != data;
}