import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/sample_data.dart';
import '../../domain/models.dart';
import '../../domain/stats.dart';
import '../../state/providers.dart';
import 'exercise_picker_sheet.dart';
import 'workout_summary_screen.dart';

/// Live logging: sets, reps and weight per exercise, with an elapsed clock and a rest timer.
class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  static const _restLength = 90;
  Timer? _ticker;
  int _elapsed = 0;
  int _rest = 0;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed++;
        if (_rest > 0) _rest--;
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _toggle(int i, bool wasDone) {
    ref.read(activeWorkoutProvider.notifier).toggleSet(i);
    setState(() => _rest = wasDone ? 0 : _restLength);
  }

  void _finish() {
    final notifier = ref.read(activeWorkoutProvider.notifier);
    final session = notifier.finish(Duration(seconds: _elapsed));
    if (session.exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log at least one set to finish')));
      return;
    }
    _ticker?.cancel();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => WorkoutSummaryScreen(session: session)));
  }

  @override
  Widget build(BuildContext context) {
    final w = ref.watch(activeWorkoutProvider);
    if (w == null) return const Scaffold();
    final notifier = ref.read(activeWorkoutProvider.notifier);
    final log = w.current;
    final ex = exerciseById(log.exerciseId);
    final active = notifier.activeSet;
    final next = w.index + 1 < w.logs.length ? w.logs[w.index + 1] : null;

    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 4),
              child: Row(children: [
                RoundIconButton(key: const Key('back'), icon: Icons.close_rounded, tooltip: 'Close', onTap: () => Navigator.of(context).pop()),
                Expanded(
                  child: Column(children: [
                    Text(w.name, style: K.title.copyWith(fontSize: 18)),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: K.accentFill, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(fmtDuration(Duration(seconds: _elapsed)), key: const Key('elapsed'), style: K.caption.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                    ]),
                  ]),
                ),
                Material(
                  color: K.accentTint,
                  shape: const StadiumBorder(side: BorderSide(color: K.border)),
                  child: InkWell(
                    key: const Key('finish'),
                    customBorder: const StadiumBorder(),
                    onTap: _finish,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text('Finish', style: K.label.copyWith(color: K.accentFill, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(K.pad, 8, K.pad, 0),
              child: Column(children: [
                Row(children: [
                  Expanded(child: Text('Exercise ${w.index + 1} of ${w.logs.length}', style: K.label)),
                  Text('${((w.index) / w.logs.length * 100).round()}% complete', style: K.caption),
                ]),
                const SizedBox(height: 8),
                ProgressBar(value: (w.index + (active == -1 ? 1 : 0)) / w.logs.length, height: 6),
              ]),
            ),
            Expanded(
              child: ListView(
                key: const Key('active-list'),
                padding: const EdgeInsets.fromLTRB(K.pad, 16, K.pad, 120),
                children: [
                  KCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      KChip(label: '${ex.equipment}, ${ex.muscle.label}'),
                      const SizedBox(height: 8),
                      Text(ex.name, style: K.display, key: const Key('exercise-name')),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(ex.image, height: 150, width: double.infinity, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 14),
                      const _TableHeader(),
                      for (var i = 0; i < log.sets.length; i++)
                        _SetRow(
                          index: i,
                          set: log.sets[i],
                          previous: log.previous,
                          active: i == active,
                          bodyweight: ex.bodyweight,
                          onCheck: () => _toggle(i, log.sets[i].done),
                          onWeight: (d) => notifier.adjustWeight(i, d),
                          onReps: (d) => notifier.adjustReps(i, d),
                        ),
                      const SizedBox(height: 4),
                      Row(children: [
                        TextButton.icon(
                          key: const Key('add-set'),
                          onPressed: notifier.addSet,
                          icon: const Icon(Icons.add_rounded, color: K.accentFill),
                          label: Text('Add set', style: K.label.copyWith(color: K.accentFill, fontWeight: FontWeight.w600)),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          key: const Key('add-exercise'),
                          onPressed: () => showExercisePicker(context),
                          icon: const Icon(Icons.playlist_add_rounded, color: K.text2),
                          label: Text('Add exercise', style: K.label.copyWith(color: K.text2)),
                        ),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    if (w.index > 0) ...[
                      Expanded(child: SecondaryButton(key: const Key('prev-exercise'), label: 'Previous', onTap: () => notifier.goTo(w.index - 1))),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: next == null
                          ? PrimaryButton(key: const Key('finish-bottom'), label: 'Finish workout', dark: true, onTap: _finish)
                          : PrimaryButton(
                              key: const Key('next-exercise'),
                              label: 'Next exercise',
                              icon: Icons.arrow_forward_rounded,
                              onTap: () {
                                notifier.goTo(w.index + 1);
                                setState(() => _rest = 0);
                              },
                            ),
                    ),
                  ]),
                  if (next != null) ...[
                    const SizedBox(height: 20),
                    Text('NEXT UP', style: K.caption.copyWith(letterSpacing: .8, color: K.text3)),
                    const SizedBox(height: 8),
                    _NextUp(log: next),
                  ],
                ],
              ),
            ),
          ]),
          if (_rest > 0)
            Positioned(
              left: K.pad,
              right: K.pad,
              bottom: 16,
              child: _RestBar(
                seconds: _rest,
                onAdd: () => setState(() => _rest += 15),
                onSkip: () => setState(() => _rest = 0),
              ),
            ),
        ]),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final s = K.caption.copyWith(fontSize: 12, color: K.text3, letterSpacing: .6, fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(children: [
        SizedBox(width: 30, child: Text('SET', style: s)),
        SizedBox(width: 72, child: Text('PREVIOUS', style: s)),
        Expanded(child: Text('KG', style: s, textAlign: TextAlign.center)),
        Expanded(child: Text('REPS', style: s, textAlign: TextAlign.center)),
        SizedBox(width: 44, child: Text('DONE', style: s, textAlign: TextAlign.center)),
      ]),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.index,
    required this.set,
    required this.previous,
    required this.active,
    required this.bodyweight,
    required this.onCheck,
    required this.onWeight,
    required this.onReps,
  });

  final int index;
  final SetLog set;
  final String? previous;
  final bool active;
  final bool bodyweight;
  final VoidCallback onCheck;
  final ValueChanged<double> onWeight;
  final ValueChanged<int> onReps;

  @override
  Widget build(BuildContext context) {
    final value = K.body.copyWith(fontWeight: FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()]);
    final kg = set.weightKg == null ? 'BW' : fmtKg(set.weightKg!);
    return AnimatedContainer(
      key: Key('set-row-$index'),
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: set.done ? K.accentTint : K.surface,
        borderRadius: BorderRadius.circular(K.rControl),
        border: Border.all(color: active ? K.accentFill : K.border, width: active ? 2 : 1),
      ),
      child: Row(children: [
        SizedBox(width: 30, child: Text('${index + 1}', style: value)),
        SizedBox(width: 72, child: Text(previous ?? '-', style: K.caption)),
        Expanded(
          child: active && !bodyweight
              ? _Stepper(value: kg, minusKey: 'weight-minus', plusKey: 'weight-plus', onMinus: () => onWeight(-2.5), onPlus: () => onWeight(2.5))
              : Text(kg, style: value, textAlign: TextAlign.center),
        ),
        Expanded(
          child: active
              ? _Stepper(value: '${set.reps}', minusKey: 'reps-minus', plusKey: 'reps-plus', onMinus: () => onReps(-1), onPlus: () => onReps(1))
              : Text('${set.reps}', style: value, textAlign: TextAlign.center),
        ),
        SizedBox(
          width: 44,
          height: 44,
          child: IconButton(
            key: Key('set-check-$index'),
            tooltip: set.done ? 'Mark set ${index + 1} not done' : 'Mark set ${index + 1} done',
            onPressed: onCheck,
            icon: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: set.done ? K.accentFill : Colors.transparent,
                border: set.done ? null : Border.all(color: active ? K.accentFill : K.borderStrong, width: 1.5),
              ),
              child: Icon(Icons.check_rounded, size: 18, color: set.done ? Colors.white : (active ? K.accentFill : K.borderStrong)),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.minusKey, required this.plusKey, required this.onMinus, required this.onPlus});

  final String value;
  final String minusKey;
  final String plusKey;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _btn(Icons.remove_rounded, minusKey, onMinus),
        Flexible(
          child: Text(value,
              style: K.body.copyWith(fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()]),
              overflow: TextOverflow.visible,
              softWrap: false),
        ),
        _btn(Icons.add_rounded, plusKey, onPlus),
      ]);

  Widget _btn(IconData icon, String key, VoidCallback onTap) => InkResponse(
        key: Key(key),
        onTap: onTap,
        radius: 22,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(color: K.surfaceAlt, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: K.ink),
          ),
        ),
      );
}

class _RestBar extends StatelessWidget {
  const _RestBar({required this.seconds, required this.onAdd, required this.onSkip});

  final int seconds;
  final VoidCallback onAdd;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) => Container(
        key: const Key('rest-bar'),
        padding: const EdgeInsets.fromLTRB(18, 8, 8, 8),
        decoration: BoxDecoration(color: K.ink, borderRadius: BorderRadius.circular(999), boxShadow: K.shadow),
        child: Row(children: [
          const Icon(Icons.timer_outlined, color: K.neon, size: 22),
          const SizedBox(width: 10),
          Text('Rest ', style: K.label.copyWith(color: K.onInkMuted)),
          Text(fmtDuration(Duration(seconds: seconds)),
              style: K.title.copyWith(color: Colors.white, fontFeatures: const [FontFeature.tabularFigures()])),
          const Spacer(),
          OutlinedButton(
            key: const Key('rest-add'),
            onPressed: onAdd,
            style: OutlinedButton.styleFrom(
              foregroundColor: K.neon,
              side: const BorderSide(color: K.neon),
              shape: const StadiumBorder(),
              minimumSize: const Size(56, 44),
            ),
            child: const Text('+15s', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          TextButton(
            key: const Key('rest-skip'),
            onPressed: onSkip,
            style: TextButton.styleFrom(foregroundColor: Colors.white, minimumSize: const Size(56, 44)),
            child: const Text('Skip'),
          ),
        ]),
      );
}

class _NextUp extends StatelessWidget {
  const _NextUp({required this.log});

  final ExerciseLog log;

  @override
  Widget build(BuildContext context) {
    final e = exerciseById(log.exerciseId);
    final s = log.sets.first;
    final load = s.weightKg == null ? 'Bodyweight' : '${fmtKg(s.weightKg!)} kg';
    return KCard(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        PhotoThumb(e.image),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.name, style: K.body.copyWith(fontWeight: FontWeight.w600)),
            Text('${log.sets.length} x ${s.reps}, $load', style: K.caption),
          ]),
        ),
      ]),
    );
  }
}
