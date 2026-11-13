import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kinetra/app.dart';

import 'harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture key screens', (t) async {
    await t.pumpWidget(const ProviderScope(child: KinetraApp()));
    await binding.convertFlutterSurfaceToImage();
    await waitFor(t, find.byKey(const Key('get-started')), timeoutMs: 60000);
    await pumpFor(t, 1500);

    Future<void> shot(String name) async {
      await pumpFor(t, 1200);
      await binding.takeScreenshot(name);
    }

    await shot('01-welcome');
    await tapKey(t, 'get-started');
    await shot('02-goal-setup');
    await tapKey(t, 'continue');
    await shot('03-today');
    await tapKey(t, 'tab-workouts');
    await shot('04-workouts');
    await tapKey(t, 'routine-upper');
    await shot('05-workout-detail');
    await tapKey(t, 'start-workout');
    await tapKey(t, 'weight-plus', settleMs: 300);
    await tapKey(t, 'set-check-0', settleMs: 300);
    await tapKey(t, 'set-check-1', settleMs: 300);
    await tapKey(t, 'set-check-2', settleMs: 300);
    await tapKey(t, 'set-check-3', settleMs: 300);
    // Stills are taken at the top of the screen: scroll the set table back down out of view.
    await t.drag(find.byKey(const Key('active-list')), const Offset(0, 1500));
    await shot('06-active-workout');
    await tapKey(t, 'add-exercise');
    await tapKey(t, 'muscle-chest', settleMs: 500);
    await tapKey(t, 'pick-incline', settleMs: 500);
    await shot('07-exercise-picker');
    await tapKey(t, 'picker-add');
    await tapKey(t, 'finish');
    await shot('08-workout-summary');
    await tapKey(t, 'save-workout', settleMs: 1500);
    await tapKey(t, 'tab-goals');
    await shot('09-goals');
    await tapKey(t, 'new-goal');
    await shot('10-new-goal');
    await tapKey(t, 'back');
    await tapKey(t, 'tab-progress');
    await shot('11-progress');
    await tapKey(t, 'weekly-report');
    await shot('12-weekly-report');
    await tapKey(t, 'back');
    await tapKey(t, 'tab-profile');
    await shot('13-profile');
    await tapKey(t, 'start-fresh', settleMs: 1200);
    await shot('14-today-empty');
  });
}
