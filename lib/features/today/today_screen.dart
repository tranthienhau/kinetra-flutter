import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/charts.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/sample_data.dart';
import '../../domain/models.dart';
import '../../domain/stats.dart';
import '../../state/providers.dart';
import '../workouts/active_workout_screen.dart';
import '../workouts/workout_detail_screen.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final profile = ref.watch(profileProvider);
    final goals = ref.watch(goalsProvider);
    final week = stats.thisWeek;
    final plan = routineById('upper');
    final doneToday = week.any((s) => s.date.day == kToday.day && s.name == plan.name);

    return ListView(
      key: const Key('today-list'),
      padding: const EdgeInsets.fromLTRB(K.pad, 12, K.pad, 24),
      children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(week.isEmpty ? 'Welcome, Alex' : 'Good morning, Alex', style: K.display),
              const SizedBox(height: 2),
              Text(DateFormat('EEE, MMM d').format(kToday), style: K.caption),
            ]),
          ),
          const Avatar(),
        ]),
        const SizedBox(height: 20),
        if (week.isEmpty) ..._empty(context, ref, profile.perWeek) else ...[
          _WeekCard(stats: stats, perWeek: profile.perWeek),
          const SizedBox(height: 16),
          _PlanCard(
            routine: plan,
            done: doneToday,
            onStart: () => startWorkout(context, ref, plan),
            onOpen: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WorkoutDetailScreen(routine: plan))),
          ),
          SectionHeader('Goals', action: 'See all', onAction: () => ref.read(tabProvider.notifier).go(2)),
          for (final g in goals.where((g) => g.type != GoalType.consistency).take(2)) ...[
            _GoalRow(goal: g),
            const SizedBox(height: 10),
          ],
          const SectionHeader('Recent'),
          _RecentRow(session: week.last),
        ],
      ],
    );
  }

  List<Widget> _empty(BuildContext context, WidgetRef ref, int perWeek) => [
        KCard(
          child: Row(children: [
            ActivityRing(
              value: 0,
              size: 92,
              onInk: false,
              center: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('0 of $perWeek', style: K.label.copyWith(fontWeight: FontWeight.w700)),
                Text('workouts', style: K.caption.copyWith(fontSize: 12)),
              ]),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text('Your week starts with the first logged session.', style: K.body.copyWith(color: K.text2))),
          ]),
        ),
        const SizedBox(height: 16),
        KCard(
          key: const Key('empty-state'),
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset('assets/images/empty-bench.jpg', height: 190, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('No workouts yet this week', style: K.title),
                const SizedBox(height: 6),
                Text('Log your first session and your ring, streak and reports start here.', style: K.body.copyWith(color: K.text2)),
                const SizedBox(height: 20),
                PrimaryButton(
                  key: const Key('log-first'),
                  label: 'Log first workout',
                  onTap: () => startWorkout(context, ref, routineById('upper')),
                ),
                const SizedBox(height: 10),
                SecondaryButton(label: 'Browse plans', onTap: () => ref.read(tabProvider.notifier).go(1)),
              ]),
            ),
          ]),
        ),
      ];
}

void startWorkout(BuildContext context, WidgetRef ref, Routine r) {
  ref.read(activeWorkoutProvider.notifier).start(r, ref.read(statsProvider));
  Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const ActiveWorkoutScreen()));
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.stats, required this.perWeek});

  final Stats stats;
  final int perWeek;

  @override
  Widget build(BuildContext context) {
    final week = stats.thisWeek;
    final lifted = stats.volumeOf(week);
    final minutes = stats.minutesOf(week);
    return InkCard(
      key: const Key('week-card'),
      child: Column(children: [
        Row(children: [
          ActivityRing(
            value: week.length / perWeek,
            center: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${week.length} of $perWeek', style: K.title.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              Text('workouts', style: K.caption.copyWith(color: K.neon)),
            ]),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _stat(Icons.local_fire_department_outlined, '${stats.streakDays} day streak'),
              _stat(Icons.timer_outlined, '$minutes active min'),
              _stat(Icons.fitness_center_rounded, '${fmtThousands(lifted)} kg lifted'),
            ]),
          ),
        ]),
        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0x26FFFFFF), height: 1)),
        WeekDots(active: stats.activeDays(stats.thisMonday), today: kToday.weekday - 1),
      ]),
    );
  }

  Widget _stat(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Icon(icon, size: 20, color: K.neon),
          const SizedBox(width: 8),
          Flexible(child: Text(text, style: K.label.copyWith(color: Colors.white, fontSize: 15))),
        ]),
      );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.routine, required this.done, required this.onStart, required this.onOpen});

  final Routine routine;
  final bool done;
  final VoidCallback onStart;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => KCard(
        padding: const EdgeInsets.all(20),
        onTap: onOpen,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text("Today's plan", style: K.label.copyWith(fontWeight: FontWeight.w600))),
            done
                ? const StatusChip(label: 'Done', icon: Icons.check_rounded)
                : const StatusChip(label: 'Ready', fg: K.accentFill, bg: K.accentTint),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            const PhotoThumb('assets/images/barbell-floor.jpg', size: 68, radius: 14),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(routine.name, style: K.title),
                Text('${routine.items.length} exercises, ${routine.minutes} min', style: K.caption),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          PrimaryButton(
            key: const Key('start-today'),
            label: done ? 'Log another session' : 'Start workout',
            icon: Icons.play_arrow_rounded,
            onTap: onStart,
          ),
        ]),
      );
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) => KCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(goal.title, style: K.label.copyWith(fontWeight: FontWeight.w600, fontSize: 15))),
            Text('${(goal.progress * 100).round()}%', style: K.label.copyWith(color: K.accentFill, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 10),
          ProgressBar(value: goal.progress),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text('Current: ${fmtKg(goal.current)} ${goal.unit}', style: K.caption)),
            Text('Target: ${fmtKg(goal.target)} ${goal.unit}', style: K.caption),
          ]),
        ]),
      );
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final detail = session.distanceKm > 0
        ? '${session.distanceKm.toStringAsFixed(1)} km'
        : '${fmtThousands(session.volume)} kg';
    return KCard(
      child: Row(children: [
        const IconCircle(Icons.check_circle_outline_rounded, size: 44),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(session.name, style: K.label.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
            Text('${DateFormat('EEE').format(session.date)}, ${session.duration.inMinutes} min, $detail', style: K.caption),
          ]),
        ),
        const Icon(Icons.chevron_right_rounded, color: K.text2),
      ]),
    );
  }
}
