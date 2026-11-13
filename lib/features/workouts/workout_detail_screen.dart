import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/sample_data.dart';
import '../../domain/models.dart';
import '../../domain/stats.dart';
import '../../state/providers.dart';
import '../today/today_screen.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({super.key, required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last = ref.watch(statsProvider).lastOf(routine.name);
    return Scaffold(
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            SizedBox(
              height: 260,
              child: Stack(fit: StackFit.expand, children: [
                Image.asset(routine.image, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, .35, 1],
                      colors: [Color(0x801C1F0C), Color(0x001C1F0C), Color(0x00FAFCF4)],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: RoundIconButton(
                        key: const Key('back'),
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Back',
                        bg: K.ink.withValues(alpha: .6),
                        fg: Colors.white,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(K.pad, 16, K.pad, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(routine.name, style: K.display),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  KChip(label: '${routine.minutes} min', icon: Icons.timer_outlined),
                  if (routine.items.isNotEmpty) KChip(label: '${routine.items.length} exercises', icon: Icons.fitness_center_rounded),
                  KChip(label: routine.level, icon: Icons.bolt_rounded),
                ]),
                const SizedBox(height: 18),
                if (last != null)
                  InkCard(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('LAST TIME', style: K.caption.copyWith(color: K.onInkMuted, letterSpacing: .8, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            last.distanceKm > 0 ? '${last.distanceKm.toStringAsFixed(1)} km' : '${fmtThousands(last.volume)} kg',
                            style: K.stat.copyWith(color: K.neon, fontSize: 28),
                          ),
                          Text(
                            last.distanceKm > 0 ? 'in ${fmtDuration(last.duration)}' : 'total volume, ${last.duration.inMinutes} min',
                            style: K.caption.copyWith(color: K.onInkMuted),
                          ),
                        ]),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .1), borderRadius: BorderRadius.circular(999)),
                        child: Text(DateFormat('MMM d').format(last.date), style: K.label.copyWith(color: Colors.white)),
                      ),
                    ]),
                  ),
                if (routine.items.isNotEmpty) ...[
                  const SectionHeader('Exercises'),
                  KCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Column(children: [
                      for (var i = 0; i < routine.items.length; i++) ...[
                        if (i > 0) const Divider(height: 1, color: K.border),
                        _ExerciseRow(item: routine.items[i]),
                      ],
                    ]),
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text('Easy pace, 5 km. Distance and time are logged at the end of the run.', style: K.body.copyWith(color: K.text2)),
                  ),
              ]),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(K.pad, 16, K.pad, 16 + MediaQuery.paddingOf(context).bottom),
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00FAFCF4), K.bg]),
            ),
            child: PrimaryButton(
              key: const Key('start-workout'),
              label: 'Start workout',
              icon: Icons.play_arrow_rounded,
              onTap: routine.items.isEmpty ? () => simulated(context, 'GPS run tracking') : () => startWorkout(context, ref, routine),
            ),
          ),
        ),
      ]),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.item});

  final PlannedExercise item;

  @override
  Widget build(BuildContext context) {
    final e = exerciseById(item.exerciseId);
    final load = item.weightKg == null ? 'Bodyweight' : '${fmtKg(item.weightKg!)} kg';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        PhotoThumb(e.image),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.name, style: K.body.copyWith(fontWeight: FontWeight.w600)),
            Text('${item.sets} x ${item.reps}, $load', style: K.caption),
          ]),
        ),
        Text(e.muscle.label, style: K.caption.copyWith(color: K.accentFill)),
      ]),
    );
  }
}
