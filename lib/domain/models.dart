/// Domain models for Kinetra. Plain immutable classes; state lives in Riverpod notifiers.
library;

enum Muscle { chest, back, legs, shoulders, arms, core, cardio }

extension MuscleLabel on Muscle {
  String get label => switch (this) {
        Muscle.chest => 'Chest',
        Muscle.back => 'Back',
        Muscle.legs => 'Legs',
        Muscle.shoulders => 'Shoulders',
        Muscle.arms => 'Arms',
        Muscle.core => 'Core',
        Muscle.cardio => 'Cardio',
      };
}

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscle,
    required this.equipment,
    required this.image,
    this.bodyweight = false,
  });

  final String id;
  final String name;
  final Muscle muscle;
  final String equipment;
  final String image;

  /// Bodyweight moves log reps only (weight shows as "BW").
  final bool bodyweight;
}

class PlannedExercise {
  const PlannedExercise(this.exerciseId, {required this.sets, required this.reps, this.weightKg});

  final String exerciseId;
  final int sets;
  final int reps;
  final double? weightKg;
}

enum RoutineCategory { strength, cardio, mobility, hiit }

extension RoutineCategoryLabel on RoutineCategory {
  String get label => switch (this) {
        RoutineCategory.strength => 'Strength',
        RoutineCategory.cardio => 'Cardio',
        RoutineCategory.mobility => 'Mobility',
        RoutineCategory.hiit => 'HIIT',
      };
}

class Routine {
  const Routine({
    required this.id,
    required this.name,
    required this.category,
    required this.minutes,
    required this.level,
    required this.image,
    required this.items,
  });

  final String id;
  final String name;
  final RoutineCategory category;
  final int minutes;
  final String level;
  final String image;
  final List<PlannedExercise> items;
}

class SetLog {
  const SetLog({this.weightKg, required this.reps, this.done = false});

  final double? weightKg;
  final int reps;
  final bool done;

  double get volume => done ? (weightKg ?? 0) * reps : 0;

  SetLog copyWith({double? weightKg, int? reps, bool? done}) =>
      SetLog(weightKg: weightKg ?? this.weightKg, reps: reps ?? this.reps, done: done ?? this.done);
}

class ExerciseLog {
  const ExerciseLog({required this.exerciseId, required this.sets, this.previous});

  final String exerciseId;
  final List<SetLog> sets;

  /// Last session's top set for this exercise, shown in the "Previous" column.
  final String? previous;

  ExerciseLog copyWith({List<SetLog>? sets}) =>
      ExerciseLog(exerciseId: exerciseId, sets: sets ?? this.sets, previous: previous);

  Iterable<SetLog> get doneSets => sets.where((s) => s.done);
  double get volume => sets.fold(0, (a, s) => a + s.volume);

  /// Heaviest completed set, or null when nothing is done or the move is bodyweight.
  SetLog? get topSet {
    SetLog? best;
    for (final s in doneSets) {
      if (s.weightKg == null) continue;
      if (best == null || s.weightKg! > best.weightKg! || (s.weightKg == best.weightKg && s.reps > best.reps)) {
        best = s;
      }
    }
    return best;
  }
}

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.name,
    required this.date,
    required this.duration,
    required this.exercises,
    this.distanceKm = 0,
    this.feeling,
  });

  final String id;
  final String name;
  final DateTime date;
  final Duration duration;
  final List<ExerciseLog> exercises;
  final double distanceKm;
  final String? feeling;

  double get volume => exercises.fold(0, (a, e) => a + e.volume);
  int get setCount => exercises.fold(0, (a, e) => a + e.doneSets.length);
  int get repCount => exercises.fold(0, (a, e) => a + e.doneSets.fold(0, (b, s) => b + s.reps));

  /// Rough estimate for the summary card (no heart-rate data in the POC).
  int get calories => (duration.inMinutes * 8.7).round();
}

enum GoalType { strength, distance, bodyWeight, consistency }

extension GoalTypeLabel on GoalType {
  String get label => switch (this) {
        GoalType.strength => 'Strength',
        GoalType.distance => 'Distance',
        GoalType.bodyWeight => 'Body weight',
        GoalType.consistency => 'Consistency',
      };
}

class Goal {
  const Goal({
    required this.id,
    required this.type,
    required this.title,
    required this.unit,
    required this.start,
    required this.current,
    required this.target,
    required this.deadline,
    this.exerciseId,
    this.reminder = false,
    this.completedOn,
  });

  final String id;
  final GoalType type;
  final String title;
  final String unit;
  final double start;
  final double current;
  final double target;
  final DateTime deadline;

  /// Strength goals follow the best logged set of this exercise.
  final String? exerciseId;
  final bool reminder;
  final DateTime? completedOn;

  /// 0..1. Strength, distance and consistency count toward the target from zero;
  /// body weight counts kilograms lost from the starting weight.
  double get progress {
    final p = switch (type) {
      GoalType.bodyWeight => (start - current) / (start - target),
      _ => current / target,
    };
    return p.isNaN ? 0 : p.clamp(0, 1).toDouble();
  }

  Goal copyWith({double? current, DateTime? completedOn}) => Goal(
        id: id,
        type: type,
        title: title,
        unit: unit,
        start: start,
        current: current ?? this.current,
        target: target,
        deadline: deadline,
        exerciseId: exerciseId,
        reminder: reminder,
        completedOn: completedOn ?? this.completedOn,
      );
}

class PersonalRecord {
  const PersonalRecord({required this.label, required this.value, required this.date, this.isNew = false});

  final String label;
  final String value;
  final DateTime date;
  final bool isNew;
}
