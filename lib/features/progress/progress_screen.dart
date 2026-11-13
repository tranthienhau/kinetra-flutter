import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/charts.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/sample_data.dart';
import '../../domain/stats.dart';
import '../../state/providers.dart';
import 'weekly_report_screen.dart';

const _ranges = {'4W': 4, '3M': 13, '6M': 26};

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  String _range = '3M';

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final weeks = _ranges[_range]!;
    final volume = stats.weeklyVolume(weeks);
    final counts = stats.weeklyCount(weeks);
    final thisWeek = volume.last;
    final past = volume.take(volume.length - 1).toList();
    final avg = past.isEmpty ? 0.0 : past.reduce((a, b) => a + b) / past.length;
    final avgCount = counts.isEmpty ? 0.0 : counts.reduce((a, b) => a + b) / counts.length;
    final firstWeek = stats.thisMonday.subtract(Duration(days: 7 * (weeks - 1)));
    final mid = stats.thisMonday.subtract(Duration(days: 7 * (weeks ~/ 2)));
    final weights = bodyWeights.sublist(bodyWeights.length - (weeks.clamp(2, bodyWeights.length)));
    final records = stats.personalRecords();

    return ListView(
      padding: const EdgeInsets.fromLTRB(K.pad, 12, K.pad, 24),
      children: [
        const Row(children: [Expanded(child: Text('Progress', style: K.display)), Avatar()]),
        const SizedBox(height: 14),
        Row(children: [
          for (final r in _ranges.keys) ...[
            KChip(key: Key('range-$r'), label: r, selected: _range == r, onTap: () => setState(() => _range = r)),
            const SizedBox(width: 8),
          ],
        ]),
        const SizedBox(height: 16),
        KCard(
          key: const Key('volume-card'),
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('Weekly volume', style: K.label.copyWith(color: K.text2))),
              if (avg > 0) StatusChip(label: 'Avg ${fmtThousands(avg)} kg / wk', fg: K.text2, bg: K.surfaceAlt),
            ]),
            Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
              Text(fmtThousands(thisWeek), style: K.stat),
              const SizedBox(width: 6),
              Text('kg this week so far', style: K.caption),
            ]),
            const SizedBox(height: 16),
            BarChart(
              values: volume,
              labels: [DateFormat('MMM d').format(firstWeek), DateFormat('MMM d').format(mid), 'This week'],
            ),
          ]),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
              child: KCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Workouts / week', style: K.caption),
                  const SizedBox(height: 4),
                  Text(avgCount.toStringAsFixed(1), style: K.stat.copyWith(fontSize: 26)),
                  const SizedBox(height: 8),
                  MiniBars(values: [for (final c in counts) c.toDouble()], color: K.pinkStrong),
                  const SizedBox(height: 6),
                  Text('Goal: ${ref.watch(profileProvider).perWeek} / wk', style: K.caption.copyWith(fontSize: 12)),
                ]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Body weight', style: K.caption),
                  const SizedBox(height: 4),
                  Text('${weights.last} kg', style: K.stat.copyWith(fontSize: 26)),
                  const SizedBox(height: 8),
                  Sparkline(values: weights, color: K.accentFill),
                  const SizedBox(height: 6),
                  Text('${(weights.last - weights.first).toStringAsFixed(1)} kg in ${weights.length} wk',
                      style: K.caption.copyWith(fontSize: 12, color: K.success)),
                ]),
              ),
            ),
          ]),
        ),
        const SectionHeader('Personal records'),
        KCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Column(children: [
            if (records.isEmpty)
              Padding(padding: const EdgeInsets.all(16), child: Text('Log a workout to set your first record.', style: K.body.copyWith(color: K.text2))),
            for (var i = 0; i < records.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: K.border),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(children: [
                  const IconCircle(Icons.emoji_events_outlined, size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(records[i].label, style: K.label.copyWith(fontWeight: FontWeight.w600)),
                        if (records[i].isNew) ...[
                          const SizedBox(width: 6),
                          const StatusChip(label: 'NEW PR', fg: K.accentFill, bg: K.accentTint),
                        ],
                      ]),
                      Text(DateFormat('MMM d').format(records[i].date), style: K.caption),
                    ]),
                  ),
                  Text(records[i].value, style: K.label.copyWith(fontWeight: FontWeight.w700)),
                ]),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 16),
        SecondaryButton(
          key: const Key('weekly-report'),
          label: 'View weekly report',
          icon: Icons.arrow_forward_rounded,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WeeklyReportScreen())),
        ),
      ],
    );
  }
}
