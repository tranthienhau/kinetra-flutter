import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/charts.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/stats.dart';
import '../../state/providers.dart';

/// Report for the last full week (Monday to Sunday), built from the logged history.
class WeeklyReportScreen extends ConsumerWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final perWeek = ref.watch(profileProvider).perWeek;
    final monday = stats.thisMonday.subtract(const Duration(days: 7));
    final sunday = monday.add(const Duration(days: 6));
    final week = stats.inWeek(monday);
    final before = stats.inWeek(monday.subtract(const Duration(days: 7)));
    final vol = stats.volumeOf(week);
    final volBefore = stats.volumeOf(before);
    final verdict = week.length >= perWeek ? 'Strong week' : week.length >= perWeek - 1 ? 'Solid week' : 'Light week';
    final upTo = Stats(stats.history.where((s) => !s.date.isAfter(sunday.add(const Duration(days: 1)))).toList(), today: sunday);
    final weekRecords = [
      for (final e in upTo.bestSets().entries)
        if (!e.value.date.isBefore(monday)) e,
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          DetailHeader(
            title: 'Weekly report',
            trailing: RoundIconButton(icon: Icons.ios_share_rounded, tooltip: 'Share', onTap: () => simulated(context, 'Sharing the report')),
          ),
          Expanded(
            child: ListView(
              key: const Key('report-list'),
              padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 24),
              children: [
                Text('${DateFormat('MMM d').format(monday)} - ${DateFormat('MMM d').format(sunday)}', style: K.label.copyWith(color: K.text2)),
                const SizedBox(height: 12),
                InkCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(verdict, style: K.display.copyWith(color: K.neon, fontSize: 40)),
                    const SizedBox(height: 4),
                    Text('${week.length} of $perWeek workouts done', style: K.body.copyWith(color: Colors.white)),
                    const SizedBox(height: 18),
                    WeekDots(active: stats.activeDays(monday)),
                  ]),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.7,
                  children: [
                    _Stat('Workouts', '${week.length}', Icons.fitness_center_rounded),
                    _Stat('Active time', fmtHoursMinutes(stats.minutesOf(week)), Icons.timer_outlined),
                    _Stat('Volume', '${fmtThousands(vol)} kg', Icons.trending_up_rounded),
                    _Stat('Distance', '${stats.kmOf(week).toStringAsFixed(1)} km', Icons.directions_run_rounded),
                  ],
                ),
                const SectionHeader('Compared with the week before'),
                KCard(
                  child: Column(children: [
                    _Compare('Volume', vol, volBefore, (v) => '${fmtThousands(v)} kg'),
                    const Divider(height: 20, color: K.border),
                    _Compare('Workouts', week.length.toDouble(), before.length.toDouble(), (v) => v.round().toString()),
                    const Divider(height: 20, color: K.border),
                    _Compare('Active minutes', stats.minutesOf(week).toDouble(), stats.minutesOf(before).toDouble(), (v) => '${v.round()} min'),
                  ]),
                ),
                const SectionHeader('Highlights'),
                KCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Column(children: [
                    for (final r in weekRecords)
                      _Highlight(Icons.emoji_events_outlined, 'New PR: ${exerciseName(r.key)} ${fmtKg(r.value.set.weightKg!)} kg'),
                    _Highlight(Icons.flag_outlined, 'Longest run: ${week.fold(0.0, (a, s) => s.distanceKm > a ? s.distanceKm : a).toStringAsFixed(1)} km'),
                    _Highlight(Icons.local_fire_department_outlined, 'Streak: ${upTo.streakDays} days'),
                  ]),
                ),
                const SizedBox(height: 12),
                KCard(
                  color: K.accentTint,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.lightbulb_outline_rounded, color: K.accentFill),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Next week', style: K.label.copyWith(color: K.accentFill, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Add one mobility session to recover between leg days.', style: K.body),
                      ]),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

String exerciseName(String id) => switch (id) {
      'bench' => 'Bench Press',
      'deadlift' => 'Deadlift',
      'squat' => 'Back Squat',
      'ohp' => 'Overhead Press',
      'row' => 'Barbell Row',
      'legpress' => 'Leg Press',
      'curl' => 'Dumbbell Curl',
      _ => id,
    };

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => KCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(label, style: K.caption)), Icon(icon, size: 18, color: K.accentFill)]),
          const Spacer(),
          FittedBox(child: Text(value, style: K.stat.copyWith(fontSize: 22))),
        ]),
      );
}

class _Compare extends StatelessWidget {
  const _Compare(this.label, this.now, this.before, this.fmt);

  final String label;
  final double now;
  final double before;
  final String Function(double) fmt;

  @override
  Widget build(BuildContext context) {
    final pct = before == 0 ? 0 : ((now - before) / before * 100).round();
    final up = pct >= 0;
    return Row(children: [
      Expanded(child: Text(label, style: K.label)),
      Text(fmt(now), style: K.label.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(width: 10),
      StatusChip(
        label: '${up ? '+' : ''}$pct%',
        fg: up ? K.success : K.warning,
        bg: up ? K.successTint : K.warningTint,
      ),
    ]);
  }
}

class _Highlight extends StatelessWidget {
  const _Highlight(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          IconCircle(icon, size: 36),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: K.label)),
        ]),
      );
}
