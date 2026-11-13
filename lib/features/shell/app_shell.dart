import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../state/providers.dart';
import '../goals/goals_screen.dart';
import '../profile/profile_screen.dart';
import '../progress/progress_screen.dart';
import '../today/today_screen.dart';
import '../workouts/workouts_screen.dart';

const _tabs = [
  ('Today', Icons.wb_sunny_outlined, 'tab-today'),
  ('Workouts', Icons.fitness_center_rounded, 'tab-workouts'),
  ('Goals', Icons.track_changes_rounded, 'tab-goals'),
  ('Progress', Icons.bar_chart_rounded, 'tab-progress'),
  ('Profile', Icons.person_outline_rounded, 'tab-profile'),
];

/// The five-tab shell shared by every tab screen (same tabs, order and styling as the design).
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(tabProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: tab, children: const [
          TodayScreen(),
          WorkoutsScreen(),
          GoalsScreen(),
          ProgressScreen(),
          ProfileScreen(),
        ]),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(color: K.surface, border: Border(top: BorderSide(color: K.border))),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: Semantics(
                    selected: i == tab,
                    button: true,
                    child: InkWell(
                      key: Key(_tabs[i].$3),
                      onTap: () => ref.read(tabProvider.notifier).go(i),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(color: i == tab ? K.neon : Colors.transparent, borderRadius: BorderRadius.circular(999)),
                          child: Icon(_tabs[i].$2, size: 22, color: i == tab ? K.ink : K.text2),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _tabs[i].$1,
                          style: K.caption.copyWith(
                            fontSize: 12,
                            color: i == tab ? K.ink : K.text2,
                            fontWeight: i == tab ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
