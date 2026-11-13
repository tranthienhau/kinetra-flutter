# Kinetra - Source Brief

## Title
Kinetra - workout logging, goal tracking and progress reports

## Description
Kinetra is a mobile fitness tracker for people who train with weights, run, or both. You start a routine and log each set with weight and reps, a rest timer runs between sets, and a summary at the end shows total volume, load compared with last time and any new personal record. Goals (strength, distance, body weight, consistency) move on their own when a workout is saved. Progress charts and a weekly report turn the history into clear trends.

## Store links
Not yet published. Source and demo: https://github.com/tranthienhau/kinetra-flutter

## Platform
Android demo, iOS-ready codebase (Flutter).

## Category
Health and Fitness

## Features
- Onboarding with a main goal and a weekly workout target
- Today dashboard: weekly activity ring, streak, active minutes, kilograms lifted, today's plan, recent session, first-run empty state
- Workout library with categories, search and a featured multi-week plan
- Routine detail with exercises, sets x reps, load and last session's volume
- Live set logging: weight and rep steppers, done ticks that carry values into the next set, automatic rest timer (+15 s, skip), add set, previous/next exercise
- Exercise picker with search, muscle-group filter and multi-select
- Workout summary: volume, duration, sets, reps, estimated calories, load per rep vs last time, new personal records, goal progress, effort rating
- Goals: hero goal, active and completed lists, create goal with live preview, weekly pace and validation
- Progress: weekly volume bars (4 weeks, 3 or 6 months), workouts per week and body weight trends, personal records
- Weekly report: workouts, active time, volume, distance, comparison with the week before, highlights, next-week tip
- Profile with stats and settings, and a "start fresh" switch to show the first-run screens

## Tech stack
- Flutter 3.35 (Dart 3.9), Riverpod 3 (`Notifier`), intl
- Custom painters for the activity ring, bar chart and sparklines
- Unit tests (stats) and widget tests (every key screen at phone size, real fonts)
- Android capture on GitHub Actions (emulator, `integration_test` + `flutter drive`)
- Stack reason: the job does not name a stack, so the owner's default (Flutter + Riverpod) applies; a single codebase covers Android and iOS.

## Industry
Fitness and wellness (consumer)

## Metrics
Unpublished proof of concept: no users or store metrics. The job states no numeric target.

## Research notes
- Verified: every number on Today, Goals, Progress and the weekly report is computed from the in-app history (26 weeks of sample sessions plus whatever is logged in the demo).
- Mocked: sample history, body weight series, the distance goal's running total, the featured plan's progress.
- Simplified: summary duration uses an estimate (2.5 min per set incl. rest) when a session is logged in under 5 minutes, so a quick demo still shows a realistic duration; calories are an estimate from duration (no heart-rate data).
- Simulated behind a tap: sign-in, custom routine builder, GPS run tracking, wearables, export, sharing, reminders.
- Data is in memory and resets on restart.
- Next steps: persistence (local database with cloud sync), accounts, routine builder, rest-timer notifications, wearable and health-platform import, CSV export, coach view for trainers.
