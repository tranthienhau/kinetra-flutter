import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixed-time pumps instead of pumpAndSettle: the live workout clock ticks every second
/// and never settles.
Future<void> pumpFor(WidgetTester t, [int ms = 600]) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (DateTime.now().isBefore(end)) {
    await t.pump(const Duration(milliseconds: 50));
  }
}

Future<void> waitFor(WidgetTester t, Finder f, {int timeoutMs = 30000}) async {
  final end = DateTime.now().add(Duration(milliseconds: timeoutMs));
  while (f.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) throw StateError('Timed out waiting for $f');
    await t.pump(const Duration(milliseconds: 100));
  }
}

final _verticalList = find.byWidgetPredicate((w) => w is ListView && w.scrollDirection == Axis.vertical);

/// Taps the widget with [key], scrolling the visible list first when the row is not built yet.
Future<void> tapKey(WidgetTester t, String key, {int settleMs = 900}) async {
  final f = find.byKey(Key(key));
  if (f.evaluate().isEmpty && _verticalList.evaluate().isNotEmpty) {
    await t.dragUntilVisible(f, _verticalList.last, const Offset(0, -250));
  }
  await waitFor(t, f);
  await t.ensureVisible(f.last);
  await pumpFor(t, 250);
  await t.tap(f.last);
  await pumpFor(t, settleMs);
}
