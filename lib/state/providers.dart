import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sample_data.dart';
import '../domain/models.dart';
import '../domain/stats.dart';

/// Onboarding choices (main goal + weekly target) and whether the user is past the welcome flow.
class Profile {
  const Profile({this.onboarded = false, this.mainGoal = 'Build strength', this.perWeek = 4});

  final bool onboarded;
  final String mainGoal;
  final int perWeek;

  Profile copyWith({bool? onboarded, String? mainGoal, int? perWeek}) => Profile(
        onboarded: onboarded ?? this.onboarded,
        mainGoal: mainGoal ?? this.mainGoal,
        perWeek: perWeek ?? this.perWeek,
      );
}

class ProfileNotifier extends Notifier<Profile> {
  @override
  Profile build() => const Profile();

  void setGoal(String g) => state = state.copyWith(mainGoal: g);
  void setPerWeek(int n) => state = state.copyWith(perWeek: n);
  void finishOnboarding() => state = state.copyWith(onboarded: true);
}

final profileProvider = NotifierProvider<ProfileNotifier, Profile>(ProfileNotifier.new);

/// Selected bottom tab (0 Today .. 4 Profile), so any screen can switch tabs.
class TabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void go(int i) => state = i;
}

final tabProvider = NotifierProvider<TabNotifier, int>(TabNotifier.new);

class HistoryNotifier extends Notifier<List<WorkoutSession>> {
  @override
  List<WorkoutSession> build() => buildHistory();

  void add(WorkoutSession s) => state = [...state, s]..sort((a, b) => a.date.compareTo(b.date));

  /// Demo helper: wipe everything to show the first-run state.
  void clear() => state = const [];
}

final historyProvider = NotifierProvider<HistoryNotifier, List<WorkoutSession>>(HistoryNotifier.new);

final statsProvider = Provider<Stats>((ref) => Stats(ref.watch(historyProvider)));

class GoalsNotifier extends Notifier<List<Goal>> {
  @override
  List<Goal> build() => buildGoals();

  void add(Goal g) => state = [g, ...state];

  /// After a saved workout: strength goals follow the best set, consistency counts this week.
  void applySession(WorkoutSession s, Stats stats) {
    state = [
      for (final g in state)
        switch (g.type) {
          GoalType.strength when g.exerciseId != null => _strength(g, s),
          GoalType.consistency => g.copyWith(current: stats.thisWeek.length.toDouble()),
          _ => g,
        },
    ];
  }

  Goal _strength(Goal g, WorkoutSession s) {
    var best = g.current;
    for (final e in s.exercises.where((e) => e.exerciseId == g.exerciseId)) {
      final top = e.topSet;
      if (top?.weightKg != null && top!.weightKg! > best) best = top.weightKg!;
    }
    return g.copyWith(current: best, completedOn: best >= g.target ? s.date : null);
  }

  void resetProgress() => state = [for (final g in state) g.copyWith(current: g.type == GoalType.bodyWeight ? g.start : 0)];
}

final goalsProvider = NotifierProvider<GoalsNotifier, List<Goal>>(GoalsNotifier.new);

/// The workout being logged right now.
class ActiveWorkout {
  const ActiveWorkout({required this.name, required this.logs, required this.index, required this.startedAt});

  final String name;
  final List<ExerciseLog> logs;
  final int index;
  final DateTime startedAt;

  ExerciseLog get current => logs[index];

  ActiveWorkout copyWith({List<ExerciseLog>? logs, int? index}) =>
      ActiveWorkout(name: name, logs: logs ?? this.logs, index: index ?? this.index, startedAt: startedAt);
}

class ActiveWorkoutNotifier extends Notifier<ActiveWorkout?> {
  @override
  ActiveWorkout? build() => null;

  void start(Routine r, Stats stats) {
    final last = stats.lastOf(r.name);
    state = ActiveWorkout(
      name: r.name,
      startedAt: DateTime.now(),
      index: 0,
      logs: [
        for (final p in r.items)
          ExerciseLog(
            exerciseId: p.exerciseId,
            previous: _previous(last, p.exerciseId),
            sets: List.generate(p.sets, (_) => SetLog(weightKg: p.weightKg, reps: p.reps)),
          ),
      ],
    );
  }

  String? _previous(WorkoutSession? last, String id) {
    final e = last?.exercises.where((e) => e.exerciseId == id).firstOrNull;
    if (e == null || e.sets.isEmpty) return null;
    final s = e.topSet ?? e.sets.first;
    return s.weightKg == null ? 'BW x ${s.reps}' : '${fmtKg(s.weightKg!)} x ${s.reps}';
  }

  /// Index of the first set not done yet in the current exercise, or -1.
  int get activeSet => state?.current.sets.indexWhere((s) => !s.done) ?? -1;

  void _updateCurrent(List<SetLog> Function(List<SetLog>) f) {
    final w = state;
    if (w == null) return;
    final logs = [...w.logs];
    logs[w.index] = w.current.copyWith(sets: f([...w.current.sets]));
    state = w.copyWith(logs: logs);
  }

  void toggleSet(int i) => _updateCurrent((sets) {
        final done = !sets[i].done;
        sets[i] = sets[i].copyWith(done: done);
        // Carry the logged weight and reps into the next open set.
        if (done && i + 1 < sets.length && !sets[i + 1].done) {
          sets[i + 1] = sets[i + 1].copyWith(weightKg: sets[i].weightKg, reps: sets[i].reps);
        }
        return sets;
      });

  void adjustWeight(int i, double delta) => _updateCurrent((sets) {
        final w = sets[i].weightKg;
        if (w != null) sets[i] = sets[i].copyWith(weightKg: (w + delta).clamp(0, 500).toDouble());
        return sets;
      });

  void adjustReps(int i, int delta) => _updateCurrent((sets) {
        sets[i] = sets[i].copyWith(reps: (sets[i].reps + delta).clamp(1, 100));
        return sets;
      });

  void addSet() => _updateCurrent((sets) {
        final last = sets.isEmpty ? const SetLog(reps: 8) : sets.last;
        return sets..add(SetLog(weightKg: last.weightKg, reps: last.reps));
      });

  void goTo(int i) {
    final w = state;
    if (w == null || i < 0 || i >= w.logs.length) return;
    state = w.copyWith(index: i);
  }

  void addExercises(List<Exercise> list) {
    final w = state;
    if (w == null || list.isEmpty) return;
    final logs = [
      ...w.logs,
      for (final e in list)
        ExerciseLog(exerciseId: e.id, sets: List.generate(3, (_) => SetLog(weightKg: e.bodyweight ? null : 20, reps: 10))),
    ];
    state = w.copyWith(logs: logs, index: w.logs.length);
  }

  WorkoutSession finish(Duration elapsed) {
    final w = state!;
    final done = [for (final l in w.logs) if (l.doneSets.isNotEmpty) l];
    // A demo run logs sets in seconds; below 5 minutes, estimate 2.5 min per set incl. rest.
    final sets = done.fold(0, (a, l) => a + l.doneSets.length);
    final duration = elapsed.inMinutes >= 5 ? elapsed : Duration(seconds: sets * 150 + elapsed.inSeconds % 60);
    return WorkoutSession(
      id: 'session-${DateTime.now().microsecondsSinceEpoch}',
      name: w.name,
      date: DateTime(kToday.year, kToday.month, kToday.day, 8, 20),
      duration: duration,
      exercises: done,
    );
  }

  void clear() => state = null;
}

final activeWorkoutProvider = NotifierProvider<ActiveWorkoutNotifier, ActiveWorkout?>(ActiveWorkoutNotifier.new);
