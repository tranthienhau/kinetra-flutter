import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final profile = ref.watch(profileProvider);
    final rows = [
      (Icons.flag_outlined, 'Main goal', '${profile.mainGoal}, ${profile.perWeek}x per week', 'row-goal'),
      (Icons.straighten_rounded, 'Units', 'kg and km', 'row-units'),
      (Icons.notifications_none_rounded, 'Workout reminders', 'Mon Wed Fri 7:00 AM', 'row-reminders'),
      (Icons.insights_rounded, 'Weekly report', 'Sunday evening', 'row-report'),
      (Icons.monitor_heart_outlined, 'Connected devices', 'Heart rate strap', 'row-devices'),
      (Icons.file_download_outlined, 'Export data', 'CSV', 'row-export'),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(K.pad, 12, K.pad, 24),
      children: [
        const Text('Profile', style: K.display),
        const SizedBox(height: 18),
        Row(children: [
          const Avatar(size: 80),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Alex Morgan', style: K.title),
              Text('Member since Mar 2025', style: K.caption),
            ]),
          ),
        ]),
        const SizedBox(height: 18),
        InkCard(
          child: Row(children: [
            _stat('${stats.history.length}', 'Workouts'),
            _stat('${stats.prCount}', 'PRs'),
            _stat('${stats.streakDays}', 'Day streak'),
          ]),
        ),
        const SizedBox(height: 18),
        KCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Column(children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: K.border),
              InkWell(
                key: Key(rows[i].$4),
                onTap: () => i == 0 ? ref.read(tabProvider.notifier).go(2) : simulated(context, rows[i].$2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(children: [
                    IconCircle(rows[i].$1, size: 38),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(rows[i].$2, style: K.body.copyWith(fontWeight: FontWeight.w500)),
                        Text(rows[i].$3, style: K.caption.copyWith(color: K.text3)),
                      ]),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: K.text2),
                  ]),
                ),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 12),
        KCard(
          key: const Key('start-fresh'),
          onTap: () {
            ref.read(historyProvider.notifier).clear();
            ref.read(goalsProvider.notifier).resetProgress();
            ref.read(tabProvider.notifier).go(0);
          },
          child: Row(children: [
            const IconCircle(Icons.restart_alt_rounded, size: 38, bg: K.surfaceAlt, fg: K.text2),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Start fresh (demo)', style: K.body.copyWith(fontWeight: FontWeight.w500)),
                Text('Clear the sample history to see the first-run screens', style: K.caption.copyWith(color: K.text3)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => simulated(context, 'Sign out'),
            style: TextButton.styleFrom(foregroundColor: K.text2, minimumSize: const Size(44, 48)),
            child: Text('Sign out', style: K.label.copyWith(color: K.text2, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _stat(String value, String label) => Expanded(
        child: Column(children: [
          Text(value, style: K.stat.copyWith(color: K.neon, fontSize: 28)),
          const SizedBox(height: 2),
          Text(label, style: K.caption.copyWith(color: Colors.white.withValues(alpha: .85))),
        ]),
      );
}
