import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/sample_data.dart';
import '../../domain/models.dart';
import 'workout_detail_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  RoutineCategory? _category;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final list = routines.where((r) {
      if (_category != null && r.category != _category) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return r.name.toLowerCase().contains(q) || r.items.any((p) => exerciseById(p.exerciseId).name.toLowerCase().contains(q));
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(K.pad, 12, K.pad, 24),
      children: [
        Row(children: [
          const Expanded(child: Text('Workouts', style: K.display)),
          RoundIconButton(icon: Icons.add_rounded, bg: K.ink, fg: K.neon, tooltip: 'New routine', onTap: () => simulated(context, 'Building a custom routine')),
        ]),
        const SizedBox(height: 16),
        TextField(
          key: const Key('workout-search'),
          onChanged: (v) => setState(() => _query = v),
          style: K.body,
          decoration: InputDecoration(
            hintText: 'Search workouts or exercises',
            hintStyle: K.body.copyWith(color: K.text3),
            prefixIcon: const Icon(Icons.search_rounded, color: K.text2),
            filled: true,
            fillColor: K.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(K.rInput), borderSide: const BorderSide(color: K.borderStrong)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(K.rInput), borderSide: const BorderSide(color: K.accentFill, width: 2)),
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            KChip(label: 'All', selected: _category == null, onTap: () => setState(() => _category = null)),
            for (final c in RoutineCategory.values) ...[
              const SizedBox(width: 8),
              KChip(key: Key('cat-${c.name}'), label: c.label, selected: _category == c, onTap: () => setState(() => _category = c)),
            ],
          ]),
        ),
        const SizedBox(height: 18),
        if (_category == null && _query.isEmpty) ...[
          _FeaturedPlan(onTap: () => _open(routineById('upper'))),
          const SizedBox(height: 8),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 12),
          child: Row(children: [
            const Expanded(child: Text('My routines', style: K.title)),
            Text('${list.length} active', style: K.caption),
          ]),
        ),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text('No routine matches "$_query".', style: K.body.copyWith(color: K.text2), textAlign: TextAlign.center),
          ),
        for (final r in list) ...[
          KCard(
            key: Key('routine-${r.id}'),
            padding: const EdgeInsets.all(12),
            onTap: () => _open(r),
            child: Row(children: [
              PhotoThumb(r.image, size: 60),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.name, style: K.body.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    r.items.isEmpty ? '${r.category.label}, ${r.minutes} min' : '${r.items.length} exercises, ${r.minutes} min',
                    style: K.caption,
                  ),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: K.text2),
            ]),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  void _open(Routine r) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WorkoutDetailScreen(routine: r)));
}

class _FeaturedPlan extends StatelessWidget {
  const _FeaturedPlan({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        key: const Key('featured-plan'),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(K.rCard),
          child: SizedBox(
            height: 210,
            child: Stack(fit: StackFit.expand, children: [
              Image.asset(featuredPlan.image, fit: BoxFit.cover, alignment: const Alignment(0, -0.4)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x331C1F0C), Color(0xE61C1F0C)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: K.ink.withValues(alpha: .7), borderRadius: BorderRadius.circular(999)),
                    child: Text('CURRENT PLAN', style: K.caption.copyWith(color: K.neon, fontWeight: FontWeight.w700, letterSpacing: .8)),
                  ),
                  const Spacer(),
                  Text(featuredPlan.name, style: K.title.copyWith(color: Colors.white, fontSize: 22)),
                  Text('Week ${featuredPlan.week} of ${featuredPlan.weeks}', style: K.caption.copyWith(color: Colors.white.withValues(alpha: .85))),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: ProgressBar(value: featuredPlan.progress, onInk: true)),
                    const SizedBox(width: 12),
                    Text('${(featuredPlan.progress * 100).round()}%', style: K.label.copyWith(color: K.neon, fontWeight: FontWeight.w700)),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      );
}
