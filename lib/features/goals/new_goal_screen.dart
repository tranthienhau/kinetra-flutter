import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/sample_data.dart';
import '../../domain/models.dart';
import '../../state/providers.dart';
import 'goals_screen.dart';

/// Create a goal: type, what, current and target value, deadline, weekly reminder.
class NewGoalScreen extends ConsumerStatefulWidget {
  const NewGoalScreen({super.key});

  @override
  ConsumerState<NewGoalScreen> createState() => _NewGoalScreenState();
}

class _NewGoalScreenState extends ConsumerState<NewGoalScreen> {
  GoalType _type = GoalType.strength;
  final _what = TextEditingController(text: 'Squat');
  final _current = TextEditingController(text: '100');
  final _target = TextEditingController(text: '120');
  DateTime _deadline = DateTime(2027, 2, 28);
  bool _reminder = true;

  static const _defaults = {
    GoalType.strength: ('Squat', '100', '120', 'kg'),
    GoalType.distance: ('Run', '0', '60', 'km'),
    GoalType.bodyWeight: ('Body weight', '78.4', '76', 'kg'),
    GoalType.consistency: ('Workouts per week', '3', '5', 'workouts'),
  };

  @override
  void dispose() {
    _what.dispose();
    _current.dispose();
    _target.dispose();
    super.dispose();
  }

  String get _unit => _defaults[_type]!.$4;
  double? get _cur => double.tryParse(_current.text.replaceAll(',', '.'));
  double? get _tgt => double.tryParse(_target.text.replaceAll(',', '.'));

  String? get _error {
    if (_what.text.trim().isEmpty) return 'Name what you are working toward';
    if (_cur == null || _tgt == null) return 'Enter numbers for current and target';
    if (_type == GoalType.bodyWeight ? _tgt! >= _cur! : _tgt! <= _cur!) return 'Target must be beyond your current value';
    return null;
  }

  void _setType(GoalType t) {
    final d = _defaults[t]!;
    setState(() {
      _type = t;
      _what.text = d.$1;
      _current.text = d.$2;
      _target.text = d.$3;
    });
  }

  String get _title => switch (_type) {
        GoalType.strength => '${_what.text.trim()} ${_target.text} kg',
        GoalType.distance => '${_what.text.trim()} ${_target.text} km',
        GoalType.bodyWeight => 'Reach ${_target.text} kg',
        GoalType.consistency => 'Train ${_target.text}x per week',
      };

  String get _pace {
    if (_error != null) return _error!;
    final weeks = (_deadline.difference(kToday).inDays / 7).clamp(1, 520);
    final perWeek = ((_tgt! - _cur!).abs() / weeks);
    return switch (_type) {
      GoalType.consistency => 'About one more session every ${(weeks / (_tgt! - _cur!)).ceil()} weeks',
      _ => 'About ${_type == GoalType.bodyWeight ? '-' : '+'}${perWeek.toStringAsFixed(1)} $_unit per week',
    };
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: kToday.add(const Duration(days: 7)),
      lastDate: DateTime(2028, 12, 31),
    );
    if (d != null) setState(() => _deadline = d);
  }

  void _create() {
    if (_error != null) return;
    final exerciseId = _type == GoalType.strength
        ? exercises.where((e) => e.name.toLowerCase().contains(_what.text.trim().toLowerCase())).firstOrNull?.id
        : null;
    ref.read(goalsProvider.notifier).add(Goal(
          id: 'g-${DateTime.now().microsecondsSinceEpoch}',
          type: _type,
          title: _title,
          unit: _unit,
          start: _type == GoalType.bodyWeight ? _cur! : 0,
          current: _cur!,
          target: _tgt!,
          deadline: _deadline,
          exerciseId: exerciseId,
          reminder: _reminder,
        ));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Goal created: $_title')));
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          const DetailHeader(),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 24), children: [
              const Text('New goal', style: K.display),
              const SizedBox(height: 18),
              Text('Goal type', style: K.label.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(children: [
                for (final t in GoalType.values) ...[
                  Expanded(child: _TypeCard(type: t, selected: _type == t, onTap: () => _setType(t))),
                  if (t != GoalType.values.last) const SizedBox(width: 8),
                ],
              ]),
              const SizedBox(height: 18),
              _Field(label: _type == GoalType.strength ? 'Exercise' : 'Name', controller: _what, onChanged: () => setState(() {}), fieldKey: 'goal-what'),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _Field(label: 'Current ($_unit)', controller: _current, number: true, onChanged: () => setState(() {}), fieldKey: 'goal-current')),
                const SizedBox(width: 12),
                Expanded(child: _Field(label: 'Target ($_unit)', controller: _target, number: true, onChanged: () => setState(() {}), fieldKey: 'goal-target')),
              ]),
              const SizedBox(height: 14),
              Text('Deadline', style: K.label.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              InkWell(
                key: const Key('goal-deadline'),
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(K.rInput),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: K.surface,
                    borderRadius: BorderRadius.circular(K.rInput),
                    border: Border.all(color: K.borderStrong),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(DateFormat('MMM d, yyyy').format(_deadline), style: K.body)),
                    const Icon(Icons.calendar_today_outlined, size: 20, color: K.text2),
                  ]),
                ),
              ),
              const SizedBox(height: 18),
              InkCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('GOAL PREVIEW', style: K.caption.copyWith(color: K.onInkMuted, letterSpacing: .8, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text('$_title by ${DateFormat('MMM d').format(_deadline)}', key: const Key('goal-preview'), style: K.title.copyWith(color: Colors.white)),
                  const SizedBox(height: 14),
                  ProgressBar(value: error == null ? (goalProgressPreview(_type, _cur!, _tgt!)) : 0, onInk: true),
                  const SizedBox(height: 10),
                  Row(children: [
                    Icon(error == null ? Icons.trending_up_rounded : Icons.info_outline_rounded, size: 18, color: error == null ? K.neon : K.pink),
                    const SizedBox(width: 6),
                    Expanded(child: Text(_pace, style: K.label.copyWith(color: error == null ? K.neon : K.pink))),
                  ]),
                ]),
              ),
              const SizedBox(height: 14),
              KCard(
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Weekly reminder', style: K.body.copyWith(fontWeight: FontWeight.w600)),
                      Text('Mondays 8:00 AM', style: K.caption.copyWith(color: K.text3)),
                    ]),
                  ),
                  Switch(value: _reminder, onChanged: (v) => setState(() => _reminder = v)),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(K.pad, 8, K.pad, 16),
            child: PrimaryButton(key: const Key('create-goal'), label: 'Create goal', onTap: error == null ? _create : null),
          ),
        ]),
      ),
    );
  }
}

/// Where a new goal starts on its bar (strength/distance count from zero, weight from today).
double goalProgressPreview(GoalType t, double current, double target) => switch (t) {
      GoalType.bodyWeight => 0,
      _ => (current / target).clamp(0, 1).toDouble(),
    };

class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.type, required this.selected, required this.onTap});

  final GoalType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        key: Key('type-${type.name}'),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 84,
          decoration: BoxDecoration(
            color: selected ? K.ink : K.surface,
            borderRadius: BorderRadius.circular(K.rControl),
            border: Border.all(color: selected ? K.ink : K.border),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(goalIcon(type), color: selected ? K.neon : K.text2),
            const SizedBox(height: 6),
            Text(type.label,
                textAlign: TextAlign.center,
                style: K.caption.copyWith(fontSize: 12, color: selected ? K.neon : K.text2, fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.controller, required this.onChanged, required this.fieldKey, this.number = false});

  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final String fieldKey;
  final bool number;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: K.label.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          key: Key(fieldKey),
          controller: controller,
          onChanged: (_) => onChanged(),
          keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: K.body,
          decoration: InputDecoration(
            filled: true,
            fillColor: K.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(K.rInput), borderSide: const BorderSide(color: K.borderStrong)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(K.rInput), borderSide: const BorderSide(color: K.accentFill, width: 2)),
          ),
        ),
      ]);
}
