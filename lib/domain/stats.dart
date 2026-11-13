import '../data/sample_data.dart';
import 'models.dart';

/// Pure functions that turn the workout history into the numbers the screens show.
class Stats {
  Stats(this.history, {DateTime? today}) : today = today ?? kToday;

  final List<WorkoutSession> history;
  final DateTime today;

  DateTime get thisMonday => mondayOf(today);

  List<WorkoutSession> inWeek(DateTime monday) {
    final end = monday.add(const Duration(days: 7));
    return history.where((s) => !s.date.isBefore(monday) && s.date.isBefore(end)).toList();
  }

  List<WorkoutSession> get thisWeek => inWeek(thisMonday);

  /// Weekday indexes (0 = Monday) with at least one session in the week of [monday].
  Set<int> activeDays(DateTime monday) => {for (final s in inWeek(monday)) s.date.weekday - 1};

  double volumeOf(Iterable<WorkoutSession> s) => s.fold(0, (a, b) => a + b.volume);
  int minutesOf(Iterable<WorkoutSession> s) => s.fold(0, (a, b) => a + b.duration.inMinutes);
  double kmOf(Iterable<WorkoutSession> s) => s.fold(0, (a, b) => a + b.distanceKm);

  /// Volume per week, oldest first, ending with the current week.
  List<double> weeklyVolume(int weeks) => [
        for (var i = weeks - 1; i >= 0; i--) volumeOf(inWeek(thisMonday.subtract(Duration(days: 7 * i)))),
      ];

  List<int> weeklyCount(int weeks) => [
        for (var i = weeks - 1; i >= 0; i--) inWeek(thisMonday.subtract(Duration(days: 7 * i))).length,
      ];

  /// Consecutive days up to today (or yesterday) with a session, allowing one rest day in between.
  int get streakDays {
    final days = {for (final s in history) DateTime(s.date.year, s.date.month, s.date.day)};
    if (days.isEmpty) return 0;
    var d = DateTime(today.year, today.month, today.day);
    if (!days.contains(d)) d = d.subtract(const Duration(days: 1));
    var streak = 0;
    var gap = 0;
    while (true) {
      if (days.contains(d)) {
        streak += 1 + gap;
        gap = 0;
      } else {
        gap++;
        if (gap > 1) break;
      }
      d = d.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Best top set per weighted exercise, with the first date it was reached.
  Map<String, ({SetLog set, DateTime date})> bestSets() {
    final out = <String, ({SetLog set, DateTime date})>{};
    for (final s in history) {
      for (final e in s.exercises) {
        final top = e.topSet;
        if (top == null) continue;
        final prev = out[e.exerciseId];
        if (prev == null || _better(top, prev.set)) out[e.exerciseId] = (set: top, date: s.date);
      }
    }
    return out;
  }

  static bool _better(SetLog a, SetLog b) =>
      a.weightKg! > b.weightKg! || (a.weightKg == b.weightKg && a.reps > b.reps);

  Duration? get best5k {
    Duration? best;
    for (final s in history) {
      if (s.distanceKm >= 5 && s.distanceKm < 5.5) {
        final per5 = s.duration * (5 / s.distanceKm);
        if (best == null || per5 < best) best = per5;
      }
    }
    return best;
  }

  double get longestRunKm => history.fold(0, (a, s) => s.distanceKm > a ? s.distanceKm : a);

  List<PersonalRecord> personalRecords({int limit = 4}) {
    final best = bestSets();
    final list = [
      for (final id in ['bench', 'deadlift', 'squat', 'ohp'])
        if (best[id] != null)
          PersonalRecord(
            label: exerciseById(id).name,
            value: '${fmtKg(best[id]!.set.weightKg!)} kg x ${best[id]!.set.reps}',
            date: best[id]!.date,
            isNew: !best[id]!.date.isBefore(thisMonday),
          ),
    ];
    final run = best5k;
    if (run != null) {
      final d = history.where((s) => s.distanceKm >= 5 && s.distanceKm < 5.5).reduce((a, b) => a.duration * (5 / a.distanceKm) <= b.duration * (5 / b.distanceKm) ? a : b);
      list.add(PersonalRecord(label: '5K Run', value: fmtDuration(run), date: d.date));
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list.take(limit).toList();
  }

  int get prCount => bestSets().length + (best5k == null ? 0 : 1);

  /// PRs reached by [session] compared with everything logged before it.
  List<PersonalRecord> newRecordsIn(WorkoutSession session) {
    final before = Stats(history.where((s) => s.date.isBefore(session.date)).toList(), today: today).bestSets();
    return [
      for (final e in session.exercises)
        if (e.topSet != null && (before[e.exerciseId] == null || _better(e.topSet!, before[e.exerciseId]!.set)))
          PersonalRecord(
            label: exerciseById(e.exerciseId).name,
            value: '${fmtKg(e.topSet!.weightKg!)} kg x ${e.topSet!.reps}',
            date: session.date,
            isNew: true,
          ),
    ];
  }

  WorkoutSession? lastOf(String routineName) {
    for (final s in history.reversed) {
      if (s.name == routineName) return s;
    }
    return null;
  }
}

String fmtKg(double kg) => kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : kg.toStringAsFixed(1);

String fmtThousands(num v) {
  final s = v.round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

String fmtDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(h > 0 ? 2 : 1, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

String fmtHoursMinutes(int minutes) => minutes >= 60 ? '${minutes ~/ 60}h ${minutes % 60}m' : '${minutes}m';
