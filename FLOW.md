# Regenerating the screenshots and demo GIF

The media in `screenshots/` comes from the real app running on an Android emulator.

## On GitHub Actions (default)

```sh
gh workflow run capture.yml -R tranthienhau/kinetra-flutter --ref main
gh run list -R tranthienhau/kinetra-flutter --workflow capture.yml -L 1
gh run download <run-id> -R tranthienhau/kinetra-flutter -n capture -D screenshots
```

How it works:

1. `.github/workflows/capture.yml` (manual dispatch only) sets up Java 17 and Flutter 3.35.0, then builds two debug APKs before the emulator boots: one for `integration_test/screenshot_test.dart`, one for `integration_test/demo_test.dart`.
2. `reactivecircus/android-emulator-runner` boots a Pixel 6 emulator (API 34, x86_64, KVM) and runs `.github/scripts/capture-emulator.sh flutter` as one command.
3. Stills: `flutter drive` runs the screenshot test. It walks the key screens and calls `binding.takeScreenshot('NN-name')`; `test_driver/integration_test.dart` writes each PNG to `screenshots/`.
4. Demo: `adb shell screenrecord --time-limit 180` records while `flutter drive` runs the paced walkthrough. The test prints `POC_DEMO_START` / `POC_DEMO_END`; the script cuts the video to that window using logcat times, then ffmpeg makes the GIF (palette pass, 12 fps, 300 px wide).
5. The run fails if there are fewer than 3 PNGs or no `demo.gif`. Media is uploaded as the `capture` artifact; the workflow never commits.

The tests use fixed-time pumps instead of `pumpAndSettle`, because the workout clock ticks every second.

## With a local emulator

```sh
emulator -avd <avd> -no-window -gpu swiftshader_indirect &
adb wait-for-device
flutter pub get
bash .github/scripts/capture-emulator.sh flutter
```

Or only the stills:

```sh
flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/screenshot_test.dart -d emulator-5554
```
