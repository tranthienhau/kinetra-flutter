import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kinetra/app.dart';

import 'harness.dart';

/// Paced walkthrough for the demo GIF (about 30 s): onboarding, start today's workout,
/// log a heavier bench set, finish with a PR, goals update, progress and the weekly report.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo walkthrough', (t) async {
    await t.pumpWidget(const ProviderScope(child: KinetraApp()));
    await waitFor(t, find.byKey(const Key('get-started')), timeoutMs: 60000);
    await pumpFor(t, 1200);
    debugPrint('POC_DEMO_START');
    await pumpFor(t, 1200);
    await tapKey(t, 'get-started', settleMs: 1300);
    await tapKey(t, 'per-week-4', settleMs: 600);
    await tapKey(t, 'continue', settleMs: 2000);
    await tapKey(t, 'start-today', settleMs: 1500);
    await tapKey(t, 'weight-plus', settleMs: 700);
    await tapKey(t, 'set-check-0', settleMs: 700);
    await tapKey(t, 'set-check-1', settleMs: 700);
    await tapKey(t, 'set-check-2', settleMs: 700);
    await tapKey(t, 'set-check-3', settleMs: 1200);
    await tapKey(t, 'finish', settleMs: 2200);
    await tapKey(t, 'save-workout', settleMs: 2000);
    await tapKey(t, 'tab-goals', settleMs: 1800);
    await tapKey(t, 'tab-progress', settleMs: 1800);
    await tapKey(t, 'weekly-report', settleMs: 2200);
    debugPrint('POC_DEMO_END');
    await pumpFor(t, 500);
  });
}
