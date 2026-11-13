import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/sample_data.dart';
import '../../domain/models.dart';
import '../../domain/stats.dart';
import '../../state/providers.dart';
import 'new_goal_screen.dart';

IconData goalIcon(GoalType t) => switch (t) {
      GoalType.strength => Icons.fitness_center_rounded,
      GoalType.distance => Icons.directions_run_rounded,
      GoalType.bodyWeight => Icons.monitor_weight_outlined,
      GoalType.consistency => Icons.event_repeat_rounded,
    };

String goalDetail(Goal g) => switch (g.type) {
      GoalType.strength => '${fmtKg(g.current)} of ${fmtKg(g.target)} kg',
      GoalType.distance => '${g.current.toStringAsFixed(1)} of ${fmtKg(g.target)} km',
      GoalType.bodyWeight => '${(g.start - g.current).toStringAsFixed(1)} kg lost',
      GoalType.consistency => '${g.current.round()} of ${g.target.round()} this week',
    };

String goalDue(Goal g) {
  final days = g.deadline.difference(kToday).inDays;
  return days <= 31 ? '$days days left' : 'Due ${DateFormat('MMM d').format(g.deadline)}';
}

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsProvider);
    final active = goals.where((g) => g.completedOn == null).toList();
    final done = goals.where((g) => g.completedOn != null).toList();
    final hero = active.isEmpty ? null : active.reduce((a, b) => a.progress >= b.progress ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(K.pad, 12, K.pad, 24),
      children: [
        Row(children: [
          const Expanded(child: Text('Goals', style: K.display)),
          RoundIconButton(
            key: const Key('new-goal'),
            icon: Icons.add_rounded,
            bg: K.neon,
            tooltip: 'New goal',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewGoalScreen())),
          ),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: K.surfaceAlt, borderRadius: BorderRadius.circular(999)),
          child: Row(children: [
            _seg('Active (${active.length})', !_completed, () => setState(() => _completed = false)),
            _seg('Completed (${done.length + completedGoals.length})', _completed, () => setState(() => _completed = true), key: 'seg-completed'),
          ]),
        ),
        const SizedBox(height: 18),
        if (_completed) ...[
          for (final g in done) _CompletedRow(title: g.title, date: g.completedOn!),
          for (final c in completedGoals) _CompletedRow(title: c.title, date: c.date),
        ] else ...[
          if (hero != null) _HeroGoal(goal: hero),
          for (final g in active.where((g) => g != hero)) ...[
            const SizedBox(height: 12),
            _GoalCard(goal: g),
          ],
          const SizedBox(height: 16),
          _CompletedRow(title: 'Last completed: ${completedGoals.first.title}', date: completedGoals.first.date),
        ],
      ],
    );
  }

  Widget _seg(String label, bool on, VoidCallback onTap, {String? key}) => Expanded(
        child: GestureDetector(
          key: key == null ? null : Key(key),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: on ? K.ink : Colors.transparent, borderRadius: BorderRadius.circular(999)),
            child: Text(label, style: K.label.copyWith(color: on ? K.neon : K.text2, fontWeight: FontWeight.w600)),
          ),
        ),
      );
}

class _HeroGoal extends StatelessWidget {
  const _HeroGoal({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) => InkCard(
        key: const Key('hero-goal'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconCircle(goalIcon(goal.type), size: 40, bg: Colors.white.withValues(alpha: .1), fg: K.neon),
            const SizedBox(width: 12),
            Expanded(child: Text(goal.title, style: K.title.copyWith(color: Colors.white))),
          ]),
          const SizedBox(height: 16),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${(goal.progress * 100).round()}%', style: K.stat.copyWith(color: K.neon, fontSize: 48, height: 1)),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(goalDetail(goal), style: K.label.copyWith(color: Colors.white)),
              Text(goalDue(goal), style: K.caption.copyWith(color: K.onInkMuted)),
            ]),
          ]),
          const SizedBox(height: 14),
          ProgressBar(value: goal.progress, onInk: true),
        ]),
      );
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) => KCard(
        key: Key('goal-${goal.id}'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconCircle(goalIcon(goal.type)),
            const SizedBox(width: 12),
            Expanded(child: Text(goal.title, style: K.body.copyWith(fontWeight: FontWeight.w600))),
            Text('${(goal.progress * 100).round()}%', style: K.label.copyWith(color: K.accentFill, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          ProgressBar(value: goal.progress),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Text(goalDetail(goal), style: K.caption)),
            StatusChip(label: goalDue(goal), fg: K.text2, bg: K.surfaceAlt),
          ]),
        ]),
      );
}

class _CompletedRow extends StatelessWidget {
  const _CompletedRow({required this.title, required this.date});

  final String title;
  final DateTime date;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: KCard(
          child: Row(children: [
            const IconCircle(Icons.check_rounded, size: 36, bg: K.successTint, fg: K.success),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: K.label.copyWith(fontWeight: FontWeight.w600))),
            Text(DateFormat('MMM d').format(date), style: K.caption),
          ]),
        ),
      );
}
