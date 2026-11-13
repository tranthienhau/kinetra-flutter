import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/models.dart';
import '../../domain/stats.dart';
import '../../state/providers.dart';

/// Shown after Finish: totals, PRs reached, goal progress, effort. Save writes it to history.
class WorkoutSummaryScreen extends ConsumerStatefulWidget {
  const WorkoutSummaryScreen({super.key, required this.session});

  final WorkoutSession session;

  @override
  ConsumerState<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends ConsumerState<WorkoutSummaryScreen> {
  String _feeling = 'Good';

  WorkoutSession get s => widget.session;

  void _save() {
    final saved = WorkoutSession(
      id: s.id,
      name: s.name,
      date: s.date,
      duration: s.duration,
      exercises: s.exercises,
      feeling: _feeling,
    );
    ref.read(historyProvider.notifier).add(saved);
    ref.read(goalsProvider.notifier).applySession(saved, ref.read(statsProvider));
    ref.read(activeWorkoutProvider.notifier).clear();
    ref.read(tabProvider.notifier).go(0);
    Navigator.of(context).popUntil((r) => r.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${s.name} saved')));
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final previous = stats.lastOf(s.name);
    final records = Stats([...stats.history, s]).newRecordsIn(s);
    final change = previous == null || previous.volume == 0 ? null : (s.volume - previous.volume) / previous.volume * 100;
    final goals = ref.watch(goalsProvider).where((g) => g.exerciseId != null && s.exercises.any((e) => e.exerciseId == g.exerciseId));

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              key: const Key('summary-list'),
              padding: const EdgeInsets.fromLTRB(K.pad, 12, K.pad, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(color: K.neon, borderRadius: BorderRadius.circular(K.rCard + 4)),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Workout complete', style: K.display),
                        const SizedBox(height: 4),
                        Text('${s.name}, ${DateFormat('EEE MMM d').format(s.date)}', style: K.label),
                      ]),
                    ),
                    const CircleAvatar(radius: 26, backgroundColor: K.ink, child: Icon(Icons.check_rounded, color: K.neon, size: 28)),
                  ]),
                ),
                const SizedBox(height: 24),
                Center(child: Text('Total volume', style: K.body.copyWith(color: K.text2))),
                Center(child: Text('${fmtThousands(s.volume)} kg', key: const Key('summary-volume'), style: K.stat.copyWith(fontSize: 44))),
                if (change != null) ...[
                  const SizedBox(height: 6),
                  Center(
                    child: StatusChip(
                      label: '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% vs last time',
                      icon: change >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      fg: change >= 0 ? K.success : K.warning,
                      bg: change >= 0 ? K.successTint : K.warningTint,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _Tile('Duration', fmtDuration(s.duration), Icons.timer_outlined),
                    _Tile('Sets', '${s.setCount}', Icons.layers_outlined),
                    _Tile('Reps', '${s.repCount}', Icons.repeat_rounded),
                    _Tile('Calories', '${s.calories}', Icons.local_fire_department_outlined, unit: 'kcal'),
                  ],
                ),
                for (final r in records) ...[
                  const SizedBox(height: 12),
                  KCard(
                    key: const Key('new-pr'),
                    child: Row(children: [
                      const IconCircle(Icons.emoji_events_outlined, size: 48),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('NEW PERSONAL RECORD', style: K.caption.copyWith(color: K.accentFill, letterSpacing: .8, fontWeight: FontWeight.w700)),
                          Text('${r.label} ${r.value}', style: K.title),
                        ]),
                      ),
                    ]),
                  ),
                ],
                for (final g in goals) ...[
                  const SizedBox(height: 12),
                  Builder(builder: (_) {
                    final top = s.exercises.firstWhere((e) => e.exerciseId == g.exerciseId).topSet?.weightKg ?? 0;
                    final current = top > g.current ? top : g.current;
                    final p = (current / g.target).clamp(0, 1).toDouble();
                    return KCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Goal progress', style: K.caption),
                        const SizedBox(height: 4),
                        Row(children: [
                          Expanded(child: Text(g.title, style: K.label.copyWith(fontWeight: FontWeight.w600))),
                          Text('${(p * 100).round()}%', style: K.label.copyWith(color: K.accentFill, fontWeight: FontWeight.w700)),
                        ]),
                        const SizedBox(height: 10),
                        ProgressBar(value: p),
                        const SizedBox(height: 8),
                        Text(
                          current >= g.target ? 'Goal reached' : '${fmtKg(g.target - current)} kg to go',
                          style: K.caption,
                        ),
                      ]),
                    );
                  }),
                ],
                const SectionHeader('How did it feel?'),
                Row(children: [
                  for (final f in ['Easy', 'Good', 'Hard']) ...[
                    KChip(key: Key('feel-${f.toLowerCase()}'), label: f, selected: _feeling == f, onTap: () => setState(() => _feeling = f)),
                    const SizedBox(width: 8),
                  ],
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(K.pad, 8, K.pad, 16),
            child: PrimaryButton(key: const Key('save-workout'), label: 'Save workout', dark: true, onTap: _save),
          ),
        ]),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.label, this.value, this.icon, {this.unit});

  final String label;
  final String value;
  final IconData icon;
  final String? unit;

  @override
  Widget build(BuildContext context) => KCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(label, style: K.label.copyWith(color: K.text2))), Icon(icon, size: 20, color: K.text2)]),
          const Spacer(),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text(value, style: K.stat.copyWith(fontSize: 24)),
            if (unit != null) ...[const SizedBox(width: 4), Text(unit!, style: K.caption)],
          ]),
        ]),
      );
}
