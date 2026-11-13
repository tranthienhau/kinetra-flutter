import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Thick activity ring (neon arc on a faint track) with a centered label.
class ActivityRing extends StatelessWidget {
  const ActivityRing({super.key, required this.value, required this.center, this.size = 128, this.onInk = true});

  final double value;
  final Widget center;
  final double size;
  final bool onInk;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(value.clamp(0, 1), onInk),
          child: Center(child: center),
        ),
      );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.onInk);

  final double value;
  final bool onInk;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = onInk ? Colors.white.withValues(alpha: .15) : K.surfaceAlt;
    canvas.drawArc(r, 0, math.pi * 2, false, track);
    if (value > 0) {
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = onInk ? K.neon : K.accentFill;
      canvas.drawArc(r, -math.pi / 2, math.pi * 2 * value, false, arc);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.onInk != onInk;
}

/// Weekly bar chart: olive bars, the latest one neon with an ink outline.
class BarChart extends StatelessWidget {
  const BarChart({super.key, required this.values, required this.labels, this.height = 140});

  final List<double> values;

  /// Shown under evenly spaced bars (first, middle, last).
  final List<String> labels;
  final double height;

  @override
  Widget build(BuildContext context) => Column(children: [
        SizedBox(height: height, width: double.infinity, child: CustomPaint(painter: _BarPainter(values))),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [for (final l in labels) Text(l, style: K.caption.copyWith(fontSize: 12, color: K.text3))],
        ),
      ]);
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.reduce(math.max);
    final n = values.length;
    final gap = n > 14 ? 3.0 : 6.0;
    final w = (size.width - gap * (n - 1)) / n;
    for (var i = 0; i < n; i++) {
      final h = maxV == 0 ? 2.0 : math.max(2.0, size.height * values[i] / maxV);
      final r = RRect.fromRectAndCorners(
        Rect.fromLTWH(i * (w + gap), size.height - h, w, h),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      final last = i == n - 1;
      canvas.drawRRect(r, Paint()..color = last ? K.neon : K.accentFill);
      if (last) {
        canvas.drawRRect(r, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = K.ink);
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.values != values;
}

/// Small line chart for sparklines (workouts per week, body weight).
class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.values, required this.color, this.height = 48});

  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: height, width: double.infinity, child: CustomPaint(painter: _LinePainter(values, color)));
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final span = (maxV - minV) == 0 ? 1 : maxV - minV;
    Offset p(int i) => Offset(
          size.width * i / (values.length - 1),
          4 + (size.height - 8) * (1 - (values[i] - minV) / span),
        );
    final path = Path()..moveTo(p(0).dx, p(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(p(i).dx, p(i).dy);
    }
    canvas.drawPath(path, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = color);
    canvas.drawCircle(p(values.length - 1), 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.values != values || old.color != color;
}

/// M T W T F S S dots, filled for active days.
class WeekDots extends StatelessWidget {
  const WeekDots({super.key, required this.active, this.today, this.onInk = true});

  final Set<int> active;
  final int? today;
  final bool onInk;

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dim = onInk ? K.onInkMuted : K.text3;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < 7; i++)
          Column(children: [
            Text(days[i],
                style: K.caption.copyWith(
                  fontSize: 12,
                  color: i == today ? (onInk ? K.neon : K.accentFill) : dim,
                  fontWeight: i == today ? FontWeight.w700 : FontWeight.w500,
                )),
            const SizedBox(height: 8),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active.contains(i) ? (onInk ? K.neon : K.accentFill) : Colors.transparent,
                border: active.contains(i) ? null : Border.all(color: onInk ? Colors.white.withValues(alpha: .35) : K.borderStrong, width: 1.5),
              ),
              child: active.contains(i) ? Icon(Icons.check_rounded, size: 14, color: onInk ? K.ink : Colors.white) : null,
            ),
          ]),
      ],
    );
  }
}

/// Small bar strip for counts (workouts per week), where a line would read as noise.
class MiniBars extends StatelessWidget {
  const MiniBars({super.key, required this.values, required this.color, this.height = 48});

  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxV = values.isEmpty ? 1.0 : values.reduce(math.max).clamp(1, double.infinity);
    return SizedBox(
      height: height,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (var i = 0; i < values.length; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          Expanded(
            child: Container(
              height: math.max(3, height * values[i] / maxV),
              decoration: BoxDecoration(
                color: i == values.length - 1 ? color : color.withValues(alpha: .45),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}
