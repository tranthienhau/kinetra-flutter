import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinetra/app.dart';

/// Real fonts, so text widths (and overflow) match the device.
Future<void> loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
    }
    await loader.load();
  }

  await load('Inter', [for (final w in [400, 500, 600, 700]) 'assets/fonts/Inter-$w.ttf']);
  await load('InstrumentSerif', ['assets/fonts/InstrumentSerif-Regular.ttf']);
}

Future<void> pumpApp(WidgetTester t) async {
  t.view.physicalSize = const Size(393 * 3, 852 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(const ProviderScope(child: KinetraApp()));
  await t.pump(const Duration(milliseconds: 300));
}

Future<void> tap(WidgetTester t, String key) async {
  final f = find.byKey(Key(key));
  if (f.evaluate().isEmpty) {
    // Lazily built list rows: scroll the visible vertical list until the target exists.
    await t.dragUntilVisible(f, find.byWidgetPredicate((w) => w is ListView && w.scrollDirection == Axis.vertical).last, const Offset(0, -250));
  }
  await t.ensureVisible(f.last);
  await t.pump(const Duration(milliseconds: 100));
  await t.tap(f.last);
  await t.pump(const Duration(milliseconds: 400));
  await t.pump(const Duration(milliseconds: 400));
}

void main() {
  setUpAll(loadFonts);

  testWidgets('welcome and goal setup lead to Today', (t) async {
    await pumpApp(t);
    expect(find.text('Get started'), findsOneWidget);
    await tap(t, 'get-started');
    expect(find.text('What is your main goal?'), findsOneWidget);
    await tap(t, 'goal-run');
    await tap(t, 'per-week-5');
    await tap(t, 'continue');
    expect(find.text('Good morning, Alex'), findsOneWidget);
    expect(find.text('3 of 5'), findsOneWidget);
  });

  testWidgets('log a workout with a heavier bench set: summary, PR and goal update', (t) async {
    await pumpApp(t);
    await tap(t, 'have-account');
    await tap(t, 'start-today');
    expect(find.byKey(const Key('exercise-name')), findsOneWidget);
    expect(find.text('Bench Press'), findsWidgets);
    await tap(t, 'weight-plus'); // 72.5 -> 75
    for (var i = 0; i < 4; i++) {
      await tap(t, 'set-check-$i');
    }
    expect(find.byKey(const Key('rest-bar')), findsOneWidget);
    await tap(t, 'rest-skip');
    await tap(t, 'next-exercise');
    expect(find.text('Pull-up'), findsWidgets);
    await tap(t, 'set-check-0');
    await tap(t, 'add-exercise');
    expect(find.text('Add exercise'), findsWidgets);
    await tap(t, 'muscle-chest');
    await tap(t, 'pick-incline');
    await tap(t, 'picker-add');
    expect(find.text('Incline Dumbbell Press'), findsWidgets);
    await tap(t, 'finish');
    expect(find.text('Workout complete'), findsOneWidget);
    expect(find.text('1,800 kg'), findsOneWidget);
    expect(find.byKey(const Key('new-pr')), findsOneWidget);
    await tap(t, 'feel-hard');
    await tap(t, 'save-workout');
    expect(find.text('4 of 4'), findsOneWidget);
    await tap(t, 'tab-goals');
    expect(find.text('94%'), findsWidgets);
  });

  testWidgets('workouts library filters and detail', (t) async {
    await pumpApp(t);
    await tap(t, 'have-account');
    await tap(t, 'tab-workouts');
    expect(find.text('4-Week Strength Builder'), findsOneWidget);
    await tap(t, 'cat-cardio');
    expect(find.text('Easy 5K Run'), findsOneWidget);
    expect(find.text('Leg Day'), findsNothing);
    await tap(t, 'routine-run');
    expect(find.text('LAST TIME'), findsOneWidget);
    await tap(t, 'back');
    await t.enterText(find.byKey(const Key('workout-search')), 'squat');
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('No routine matches "squat".'), findsOneWidget);
  });

  testWidgets('create a goal', (t) async {
    await pumpApp(t);
    await tap(t, 'have-account');
    await tap(t, 'tab-goals');
    expect(find.byKey(const Key('hero-goal')), findsOneWidget);
    await tap(t, 'new-goal');
    expect(find.text('Squat 120 kg by Feb 28'), findsOneWidget);
    await t.enterText(find.byKey(const Key('goal-target')), '90');
    await t.pump();
    expect(find.text('Target must be beyond your current value'), findsOneWidget);
    await t.enterText(find.byKey(const Key('goal-target')), '130');
    await t.pump();
    await tap(t, 'create-goal');
    expect(find.text('Squat 130 kg'), findsOneWidget);
    await tap(t, 'seg-completed');
    expect(find.text('Deadlift 120 kg'), findsOneWidget);
  });

  testWidgets('progress, weekly report and profile start fresh', (t) async {
    await pumpApp(t);
    await tap(t, 'have-account');
    await tap(t, 'tab-progress');
    expect(find.text('Weekly volume'), findsOneWidget);
    expect(find.text('Personal records'), findsOneWidget);
    await tap(t, 'range-6M');
    await tap(t, 'weekly-report');
    expect(find.text('Strong week'), findsOneWidget);
    expect(find.text('Nov 2 - Nov 8'), findsOneWidget);
    await tap(t, 'back');
    await tap(t, 'tab-profile');
    expect(find.text('Alex Morgan'), findsOneWidget);
    await tap(t, 'start-fresh');
    expect(find.byKey(const Key('empty-state')), findsOneWidget);
    expect(find.text('No workouts yet this week'), findsOneWidget);
  });
}
