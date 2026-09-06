import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class WeekSelector extends StatefulWidget {
  const WeekSelector({
    super.key,
    required this.maxWeek,
    required this.selectedWeek,
    required this.onChanged,
  }) : assert(maxWeek > 0),
       assert(selectedWeek > 0 && selectedWeek <= maxWeek);

  final int maxWeek;
  final int selectedWeek;
  final ValueChanged<int> onChanged;

  @override
  State<WeekSelector> createState() => _WeekSelectorState();
}

class _WeekSelectorState extends State<WeekSelector> {
  final _controller = ScrollController();
  final _selectedButtonKey = GlobalKey();
  double? _viewportWidth;
  bool _needsReveal = true;

  @override
  void didUpdateWidget(covariant WeekSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedWeek != oldWidget.selectedWeek ||
        widget.maxWeek != oldWidget.maxWeek) {
      _needsReveal = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _revealSelected() {
    if (!mounted || !_controller.hasClients) return;
    final target = _selectedButtonKey.currentContext?.findRenderObject();
    if (target == null) return;
    // Reveal only within this row, without scrolling an enclosing import page.
    _controller.position.ensureVisible(target, alignment: 0.5);
  }

  @override
  Widget build(BuildContext context) {
    final behavior = ScrollConfiguration.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_viewportWidth != constraints.maxWidth) {
          _viewportWidth = constraints.maxWidth;
          _needsReveal = true;
        }
        if (_needsReveal) {
          _needsReveal = false;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _revealSelected(),
          );
        }
        return ScrollConfiguration(
          behavior: behavior.copyWith(
            dragDevices: {...behavior.dragDevices, PointerDeviceKind.mouse},
            scrollbars: false,
          ),
          child: SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var week = 1; week <= widget.maxWeek; week++)
                  Padding(
                    padding: EdgeInsets.only(
                      right: week == widget.maxWeek ? 0 : 8,
                    ),
                    child: Semantics(
                      key: week == widget.selectedWeek
                          ? _selectedButtonKey
                          : null,
                      selected: week == widget.selectedWeek,
                      child: week == widget.selectedWeek
                          ? FilledButton(
                              key: ValueKey('week-button-$week'),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(64, 48),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              onPressed: () {},
                              child: Text('第$week周'),
                            )
                          : OutlinedButton(
                              key: ValueKey('week-button-$week'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(64, 48),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              onPressed: () => widget.onChanged(week),
                              child: Text('第$week周'),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
