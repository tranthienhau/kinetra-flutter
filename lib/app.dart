import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/shell/app_shell.dart';
import 'state/providers.dart';

class KinetraApp extends ConsumerWidget {
  const KinetraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarded = ref.watch(profileProvider.select((p) => p.onboarded));
    return MaterialApp(
      title: 'Kinetra',
      debugShowCheckedModeBanner: false,
      theme: K.theme(),
      // Let the tinted background run under the status bar instead of Android's grey scrim.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: child!,
      ),
      home: onboarded ? const AppShell() : const WelcomeScreen(),
    );
  }
}
