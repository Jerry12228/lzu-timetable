import 'package:flutter/material.dart';

import '../models/timetable_sections.dart';

class SectionButtonGrid extends StatelessWidget {
  const SectionButtonGrid({
    super.key,
    required this.selectedSections,
    required this.keyPrefix,
    required this.onToggle,
  });

  final Set<String> selectedSections;
  final String keyPrefix;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: Column(
        children: [
          Expanded(child: _buttonRow(TimetableSections.all.take(7))),
          const SizedBox(height: 4),
          Expanded(child: _buttonRow(TimetableSections.all.skip(7))),
        ],
      ),
    );
  }

  Widget _buttonRow(Iterable<TimetableSectionDefinition> sections) {
    return Row(
      children: [
        for (final section in sections)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _SectionButton(
                key: ValueKey('$keyPrefix-${section.id}'),
                label: section.shortLabel,
                selected: selectedSections.contains(section.id),
                onPressed: () => onToggle(section.id),
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
