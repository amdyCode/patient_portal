import 'package:flutter/material.dart';

class TimeSelector extends StatelessWidget {
  final List<String> times;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const TimeSelector({
    super.key,
    required this.times,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(times.length, (index) {
          bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: (MediaQuery.of(context).size.width - 48 - 24) / 3,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  times[index],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Theme.of(context).primaryColor : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
