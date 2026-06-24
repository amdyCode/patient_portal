import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DateSelector extends StatelessWidget {
  final List<String> dates;
  final List<String> daysNumber;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const DateSelector({
    super.key,
    required this.dates,
    required this.daysNumber,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.neonGradient : null,
                color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppTheme.neonPurple.withValues(alpha: 0.4),
                    offset: const Offset(0, 8),
                    blurRadius: 16,
                  ),
                ] : [],
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dates[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    daysNumber[index],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
