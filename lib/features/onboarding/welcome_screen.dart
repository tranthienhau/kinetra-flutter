import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/providers.dart';
import 'goal_setup_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: K.ink,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/welcome-hero.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0.2, -0.3),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, .25, .5, .78],
                  colors: [
                    Color(0x991C1F0C),
                    Color(0x001C1F0C),
                    Color(0x661C1F0C),
                    Color(0xF21C1F0C),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(K.pad, 12, K.pad, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/logo/icon.png',
                            width: 44,
                            height: 44,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Kinetra',
                          style: K.display.copyWith(
                            color: Colors.white,
                            fontSize: 32,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'Train with intent.\nSee every rep add up.',
                      style: K.display.copyWith(
                        color: Colors.white,
                        fontSize: 40,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Log workouts, set goals and watch your progress grow',
                      style: K.body.copyWith(
                        color: Colors.white.withValues(alpha: .88),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _DarkChip(Icons.bolt_rounded, 'Log in 3 taps'),
                        _DarkChip(Icons.track_changes_rounded, 'Goal tracking'),
                        _DarkChip(Icons.insights_rounded, 'Weekly reports'),
                      ],
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      key: const Key('get-started'),
                      label: 'Get started',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GoalSetupScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        key: const Key('have-account'),
                        onPressed: () => ref
                            .read(profileProvider.notifier)
                            .finishOnboarding(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          minimumSize: const Size(44, 48),
                        ),
                        child: Text(
                          'I already have an account',
                          style: K.body.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkChip extends StatelessWidget {
  const _DarkChip(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: K.ink.withValues(alpha: .6),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.white.withValues(alpha: .18)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: K.neon),
        const SizedBox(width: 6),
        Text(label, style: K.caption.copyWith(color: Colors.white)),
      ],
    ),
  );
}
