import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
                color: isSelected ? AppTheme.neonPurple.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppTheme.neonPurple : Colors.white.withValues(alpha: 0.1),
                  width: 1.5,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppTheme.neonPurple.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ] : [],
              ),
              child: Center(
                child: Text(
                  times[index],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppTheme.neonPurple : Colors.white60,
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
