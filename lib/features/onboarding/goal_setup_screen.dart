import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/providers.dart';

const _goals = [
  ('Build strength', 'assets/images/goal-strength.jpg', 'goal-strength'),
  ('Lose weight', 'assets/images/goal-weight.jpg', 'goal-weight'),
  ('Run further', 'assets/images/goal-run.jpg', 'goal-run'),
  ('Stay active', 'assets/images/goal-active.jpg', 'goal-active'),
];

class GoalSetupScreen extends ConsumerWidget {
  const GoalSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, K.pad, 0),
            child: Row(children: [
              RoundIconButton(key: const Key('back'), icon: Icons.arrow_back_rounded, tooltip: 'Back', onTap: () => Navigator.of(context).pop()),
              const SizedBox(width: 16),
              Text('Step 2 of 3', style: K.caption),
              const SizedBox(width: 12),
              Expanded(
                child: Row(children: [
                  for (var i = 0; i < 3; i++)
                    Expanded(
                      child: Container(
                        height: 6,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: i < 2 ? K.accentFill : K.surfaceAlt,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                ]),
              ),
            ]),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(K.pad, 20, K.pad, 16), children: [
              const Text('What is your main goal?', style: K.display),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .86,
                children: [
                  for (final g in _goals)
                    _GoalCard(
                      key: Key(g.$3),
                      label: g.$1,
                      image: g.$2,
                      selected: profile.mainGoal == g.$1,
                      onTap: () => notifier.setGoal(g.$1),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              const Text('Workouts per week', style: K.title),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: K.surfaceAlt, borderRadius: BorderRadius.circular(999)),
                child: Row(children: [
                  for (final n in [2, 3, 4, 5, 6])
                    Expanded(
                      child: GestureDetector(
                        key: Key('per-week-$n'),
                        onTap: () => notifier.setPerWeek(n),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: profile.perWeek == n ? K.ink : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('$n',
                              style: K.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: profile.perWeek == n ? K.neon : K.text2,
                              )),
                        ),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 10),
              Text('You can change this later', style: K.caption.copyWith(color: K.text3)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 16),
            child: PrimaryButton(
              key: const Key('continue'),
              label: 'Continue',
              icon: Icons.arrow_forward_rounded,
              onTap: () {
                notifier.finishOnboarding();
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({super.key, required this.label, required this.image, required this.selected, required this.onTap});

  final String label;
  final String image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? K.accentTint : K.surface,
            borderRadius: BorderRadius.circular(K.rCard),
            border: Border.all(color: selected ? K.accentFill : K.border, width: selected ? 2 : 1),
            boxShadow: K.shadow,
          ),
          padding: const EdgeInsets.all(8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Stack(children: [
                Positioned.fill(
                  child: ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.asset(image, fit: BoxFit.cover)),
                ),
                if (selected)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(radius: 13, backgroundColor: K.neon, child: Icon(Icons.check_rounded, size: 16, color: K.ink)),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 4),
              child: Text(label, style: K.label.copyWith(fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      );
}
