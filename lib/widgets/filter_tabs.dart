import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FilterTabs extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;
  final List<String> filters;

  const FilterTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: List.generate(
          filters.length,
          (index) => _buildFilterTab(context, filters[index], index),
        ),
      ),
    );
  }

  Widget _buildFilterTab(BuildContext context, String title, int index) {
    bool isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.neonGradient : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.neonPurple.withValues(alpha: 0.4),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}