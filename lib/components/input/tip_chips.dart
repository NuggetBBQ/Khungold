import 'package:flutter/material.dart';

class TipChips extends StatelessWidget {
  const TipChips({
    super.key,
    required this.choices,
    required this.selectedIndex,
    required this.onChanged,
  });
  final List<int> choices;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: List.generate(choices.length, (i) {
        final sel = selectedIndex == i;
        return ChoiceChip(
          label: Text('${choices[i]} บาท'),
          selected: sel,
          onSelected: (_) => onChanged(i),
        );
      }),
    );
  }
}