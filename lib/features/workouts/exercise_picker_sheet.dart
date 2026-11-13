import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/sample_data.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';

Future<void> showExercisePicker(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: K.bg,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const FractionallySizedBox(heightFactor: .92, child: ExercisePickerSheet()),
    );

/// Search the exercise library by name and muscle group, multi-select, add to the live workout.
class ExercisePickerSheet extends ConsumerStatefulWidget {
  const ExercisePickerSheet({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<ExercisePickerSheet> {
  late final _search = TextEditingController(text: widget.initialQuery);
  Muscle? _muscle;
  final _picked = <String>{};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();
    final results = exercises
        .where((e) => (_muscle == null || e.muscle == _muscle) && (q.isEmpty || e.name.toLowerCase().contains(q)))
        .toList();

    return Column(children: [
      const SizedBox(height: 10),
      Container(width: 40, height: 5, decoration: BoxDecoration(color: K.border, borderRadius: BorderRadius.circular(999))),
      Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 8, 8, 8),
        child: Row(children: [
          const Expanded(child: Text('Add exercise', style: K.title)),
          IconButton(tooltip: 'Close', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded, color: K.ink)),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: K.pad),
        child: TextField(
          key: const Key('picker-search'),
          controller: _search,
          onChanged: (_) => setState(() {}),
          style: K.body,
          decoration: InputDecoration(
            hintText: 'Search exercises',
            hintStyle: K.body.copyWith(color: K.text3),
            prefixIcon: const Icon(Icons.search_rounded, color: K.accentFill),
            filled: true,
            fillColor: K.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(K.rInput), borderSide: const BorderSide(color: K.borderStrong)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(K.rInput), borderSide: const BorderSide(color: K.accentFill, width: 2)),
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: K.pad),
          children: [
            KChip(label: 'All', selected: _muscle == null, onTap: () => setState(() => _muscle = null)),
            for (final m in Muscle.values.where((m) => m != Muscle.cardio)) ...[
              const SizedBox(width: 8),
              KChip(key: Key('muscle-${m.name}'), label: m.label, selected: _muscle == m, onTap: () => setState(() => _muscle = m)),
            ],
          ],
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: results.isEmpty
            ? Center(child: Text('No exercise matches.', style: K.body.copyWith(color: K.text2)))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(K.pad, 8, K.pad, 16),
                itemCount: results.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final e = results[i];
                  final on = _picked.contains(e.id);
                  return KCard(
                    key: Key('pick-${e.id}'),
                    padding: const EdgeInsets.all(10),
                    onTap: () => setState(() => on ? _picked.remove(e.id) : _picked.add(e.id)),
                    child: Row(children: [
                      PhotoThumb(e.image),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(e.name, style: K.body.copyWith(fontWeight: FontWeight.w600)),
                          Text('${e.muscle.label}, ${e.equipment}', style: K.caption),
                        ]),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: on ? K.neon : Colors.transparent,
                          border: on ? null : Border.all(color: K.borderStrong, width: 1.5),
                        ),
                        child: on ? const Icon(Icons.check_rounded, size: 18, color: K.ink) : null,
                      ),
                    ]),
                  );
                },
              ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(K.pad, 8, K.pad, 12 + MediaQuery.paddingOf(context).bottom),
        child: PrimaryButton(
          key: const Key('picker-add'),
          label: _picked.isEmpty ? 'Select exercises' : 'Add ${_picked.length} exercise${_picked.length == 1 ? '' : 's'}',
          onTap: _picked.isEmpty
              ? null
              : () {
                  ref.read(activeWorkoutProvider.notifier).addExercises([for (final id in _picked) exerciseById(id)]);
                  Navigator.of(context).pop();
                },
        ),
      ),
    ]);
  }
}
