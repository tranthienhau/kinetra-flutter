import 'package:flutter_test/flutter_test.dart';
import 'package:kinetra/data/sample_data.dart';
import 'package:kinetra/domain/models.dart';
import 'package:kinetra/domain/stats.dart';

void main() {
  final stats = Stats(buildHistory());

  test('this week has three sessions before today', () {
    expect(stats.thisWeek.length, 3);
    expect(stats.activeDays(stats.thisMonday), {0, 1, 2});
  });

  test('bench best is the planned 72.5 kg top set', () {
    expect(stats.bestSets()['bench']!.set.weightKg, 72.5);
  });

  test('a heavier set in a new session is a PR', () {
    final s = WorkoutSession(
      id: 'x',
      name: 'Upper Body Power',
      date: kToday,
      duration: const Duration(minutes: 40),
      exercises: const [
        ExerciseLog(exerciseId: 'bench', sets: [SetLog(weightKg: 75, reps: 6, done: true)]),
      ],
    );
    final records = Stats([...buildHistory(), s]).newRecordsIn(s);
    expect(records.single.label, 'Bench Press');
    expect(s.volume, 450);
  });

  test('goal progress', () {
    final goals = buildGoals();
    expect(goals.firstWhere((g) => g.id == 'g-weight').progress, closeTo(0.65, 0.001));
    expect(goals.firstWhere((g) => g.id == 'g-week').progress, 0.75);
  });

  test('formatting', () {
    expect(fmtThousands(24350), '24,350');
    expect(fmtDuration(const Duration(minutes: 24, seconds: 18)), '24:18');
    expect(fmtKg(72.5), '72.5');
  });
}
