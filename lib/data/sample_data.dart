import '../domain/models.dart';

/// The demo runs on a fixed clock so screenshots and tests are deterministic.
final DateTime kToday = DateTime(2026, 11, 13, 7, 30);

String img(String name) => 'assets/images/$name.jpg';

const exercises = <Exercise>[
  Exercise(id: 'bench', name: 'Bench Press', muscle: Muscle.chest, equipment: 'Barbell', image: 'assets/images/ex-bench-press.jpg'),
  Exercise(id: 'incline', name: 'Incline Dumbbell Press', muscle: Muscle.chest, equipment: 'Dumbbell', image: 'assets/images/ex-incline-press.jpg'),
  Exercise(id: 'pullup', name: 'Pull-up', muscle: Muscle.back, equipment: 'Bodyweight', image: 'assets/images/ex-pullup.jpg', bodyweight: true),
  Exercise(id: 'row', name: 'Barbell Row', muscle: Muscle.back, equipment: 'Barbell', image: 'assets/images/barbell-floor.jpg'),
  Exercise(id: 'deadlift', name: 'Deadlift', muscle: Muscle.back, equipment: 'Barbell', image: 'assets/images/goal-strength.jpg'),
  Exercise(id: 'ohp', name: 'Overhead Press', muscle: Muscle.shoulders, equipment: 'Barbell', image: 'assets/images/ex-overhead-press.jpg'),
  Exercise(id: 'pushpress', name: 'Push Press', muscle: Muscle.shoulders, equipment: 'Barbell', image: 'assets/images/ex-push-press.jpg'),
  Exercise(id: 'curl', name: 'Dumbbell Curl', muscle: Muscle.arms, equipment: 'Dumbbell', image: 'assets/images/routine-upper.jpg'),
  Exercise(id: 'dip', name: 'Triceps Dip', muscle: Muscle.arms, equipment: 'Bodyweight', image: 'assets/images/plan-pullups.jpg', bodyweight: true),
  Exercise(id: 'squat', name: 'Back Squat', muscle: Muscle.legs, equipment: 'Barbell', image: 'assets/images/routine-legs.jpg'),
  Exercise(id: 'legpress', name: 'Leg Press', muscle: Muscle.legs, equipment: 'Machine', image: 'assets/images/ex-leg-press.jpg'),
  Exercise(id: 'plank', name: 'Plank Reach', muscle: Muscle.core, equipment: 'Bodyweight', image: 'assets/images/ex-plank.jpg', bodyweight: true),
  Exercise(id: 'rollout', name: 'Ab Wheel Rollout', muscle: Muscle.core, equipment: 'Ab wheel', image: 'assets/images/routine-core.jpg', bodyweight: true),
];

Exercise exerciseById(String id) => exercises.firstWhere((e) => e.id == id);

const routines = <Routine>[
  Routine(
    id: 'upper',
    name: 'Upper Body Power',
    category: RoutineCategory.strength,
    minutes: 45,
    level: 'Intermediate',
    image: 'assets/images/detail-bench-press.jpg',
    items: [
      PlannedExercise('bench', sets: 4, reps: 6, weightKg: 72.5),
      PlannedExercise('pullup', sets: 4, reps: 8),
      PlannedExercise('ohp', sets: 3, reps: 8, weightKg: 40),
      PlannedExercise('row', sets: 3, reps: 10, weightKg: 60),
      PlannedExercise('curl', sets: 3, reps: 12, weightKg: 14),
      PlannedExercise('dip', sets: 3, reps: 12),
    ],
  ),
  Routine(
    id: 'legs',
    name: 'Leg Day',
    category: RoutineCategory.strength,
    minutes: 50,
    level: 'Intermediate',
    image: 'assets/images/routine-legs.jpg',
    items: [
      PlannedExercise('squat', sets: 5, reps: 5, weightKg: 110),
      PlannedExercise('deadlift', sets: 3, reps: 3, weightKg: 140),
      PlannedExercise('legpress', sets: 4, reps: 10, weightKg: 110),
    ],
  ),
  Routine(
    id: 'core',
    name: 'Core Blast',
    category: RoutineCategory.hiit,
    minutes: 20,
    level: 'All levels',
    image: 'assets/images/routine-core.jpg',
    items: [
      PlannedExercise('plank', sets: 3, reps: 12),
      PlannedExercise('rollout', sets: 3, reps: 10),
    ],
  ),
  Routine(
    id: 'run',
    name: 'Easy 5K Run',
    category: RoutineCategory.cardio,
    minutes: 30,
    level: 'Beginner',
    image: 'assets/images/goal-run.jpg',
    items: [],
  ),
];

Routine routineById(String id) => routines.firstWhere((r) => r.id == id);

/// Featured multi-week plan shown on the Workouts tab.
const featuredPlan = (name: '4-Week Strength Builder', week: 2, weeks: 4, progress: 0.45, image: 'assets/images/plan-pullups.jpg');

double _round25(double kg) => (kg / 2.5).round() * 2.5;

ExerciseLog _log(PlannedExercise p, double factor) => ExerciseLog(
      exerciseId: p.exerciseId,
      sets: List.generate(
        p.sets,
        (_) => SetLog(weightKg: p.weightKg == null ? null : _round25(p.weightKg! * factor), reps: p.reps, done: true),
      ),
    );

WorkoutSession _session(String routineId, DateTime day, int index, double factor, {Duration? duration, double km = 0}) {
  final r = routineById(routineId);
  return WorkoutSession(
    id: '$routineId-${day.toIso8601String()}',
    name: r.name,
    date: DateTime(day.year, day.month, day.day, 7, 10),
    duration: duration ?? Duration(minutes: r.minutes + (index % 3) * 3 - 2),
    exercises: [for (final p in r.items) _log(p, factor)],
    distanceKm: km,
    feeling: 'Good',
  );
}

DateTime mondayOf(DateTime d) => DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

/// 26 weeks of history: Mon legs, Tue core, Thu upper, Sat run, with weights
/// climbing to today's numbers. This week so far: Mon core, Tue run, Wed legs.
List<WorkoutSession> buildHistory() {
  final out = <WorkoutSession>[];
  final thisMonday = mondayOf(kToday);
  const weeks = 26;
  for (var w = weeks; w >= 1; w--) {
    final monday = thisMonday.subtract(Duration(days: 7 * w));
    final k = weeks - w; // 0 oldest .. 25 last week
    final factor = 0.82 + 0.18 * k / (weeks - 1);
    // A few lighter weeks so the volume chart is not a straight line.
    final skipCore = k % 5 == 2;
    final runKm = k == 22 ? 8.1 : 5.0;
    final runTime = k == 23 ? const Duration(minutes: 24, seconds: 18) : Duration(minutes: runKm > 5 ? 44 : 27 - (k ~/ 8), seconds: 40 - k);
    out.add(_session('legs', monday, k, factor));
    if (!skipCore) out.add(_session('core', monday.add(const Duration(days: 1)), k, factor));
    out.add(_session('upper', monday.add(const Duration(days: 3)), k, factor));
    out.add(_session('run', monday.add(const Duration(days: 5)), k, factor, duration: runTime, km: runKm));
  }
  out.add(_session('core', thisMonday, 26, 1));
  out.add(_session('run', thisMonday.add(const Duration(days: 1)), 26, 1, duration: const Duration(minutes: 26, seconds: 2), km: 5.2));
  out.add(_session('legs', thisMonday.add(const Duration(days: 2)), 26, 1, duration: const Duration(minutes: 52)));
  out.sort((a, b) => a.date.compareTo(b.date));
  return out;
}

List<Goal> buildGoals() => [
      Goal(
        id: 'g-bench',
        type: GoalType.strength,
        title: 'Bench press 80 kg',
        unit: 'kg',
        start: 0,
        current: 72.5,
        target: 80,
        deadline: DateTime(2026, 12, 31),
        exerciseId: 'bench',
        reminder: true,
      ),
      Goal(
        id: 'g-run',
        type: GoalType.distance,
        title: 'Run 50 km in November',
        unit: 'km',
        start: 0,
        current: 31.4,
        target: 50,
        deadline: DateTime(2026, 11, 30),
      ),
      Goal(
        id: 'g-weight',
        type: GoalType.bodyWeight,
        title: 'Lose 4 kg',
        unit: 'kg',
        start: 81.0,
        current: 78.4,
        target: 77.0,
        deadline: DateTime(2027, 1, 15),
      ),
      Goal(
        id: 'g-week',
        type: GoalType.consistency,
        title: 'Train 4x per week',
        unit: 'workouts',
        start: 0,
        current: 3,
        target: 4,
        deadline: DateTime(2026, 12, 31),
      ),
    ];

final completedGoals = [
  (title: 'Deadlift 120 kg', date: DateTime(2026, 10, 28)),
  (title: 'Run 5K under 25 min', date: DateTime(2026, 10, 24)),
];

/// Weekly weigh-ins, oldest first (13 weeks, 81.0 to 78.4 kg).
const bodyWeights = <double>[81.0, 80.8, 80.9, 80.4, 80.1, 80.2, 79.7, 79.5, 79.4, 79.0, 78.9, 78.6, 78.4];
