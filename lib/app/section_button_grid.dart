import 'package:flutter/material.dart';

import '../models/schedule_models.dart';

class SectionButtonGrid extends StatelessWidget {
  const SectionButtonGrid({
    super.key,
    required this.periods,
    required this.selectedSections,
    required this.keyPrefix,
    required this.onToggle,
  });

  final List<PeriodDefinition> periods;
  final Set<String> selectedSections;
  final String keyPrefix;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: Column(
        children: [
          Expanded(child: _buttonRow(periods.take(7))),
          const SizedBox(height: 4),
          Expanded(child: _buttonRow(periods.skip(7))),
        ],
      ),
    );
  }

  Widget _buttonRow(Iterable<PeriodDefinition> rowPeriods) {
    return Row(
      children: [
        for (final period in rowPeriods)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _SectionButton(
                key: ValueKey('$keyPrefix-${period.sections.single}'),
                label: _shortLabel(period.sections.single),
                selected: selectedSections.contains(period.sections.single),
                onPressed: () => onToggle(period.sections.single),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionButton extends StatelessWidget {
  const _SectionButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: selected
            ? scheme.onPrimaryContainer
            : scheme.onSurface,
        backgroundColor: selected ? scheme.primaryContainer : null,
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

String _shortLabel(String section) {
  final match = RegExp(r'^第(\d+)节$').firstMatch(section);
  if (match != null) {
    return match.group(1)!;
  }
  return section.replaceFirst('中午', '午').replaceAll('节', '');
}
