import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InteractiveMoodSelector extends StatefulWidget {
  const InteractiveMoodSelector({super.key});

  @override
  State<InteractiveMoodSelector> createState() => _InteractiveMoodSelectorState();
}

class _InteractiveMoodSelectorState extends State<InteractiveMoodSelector> {
  int? _selectedIndex;

  final List<Map<String, dynamic>> _moods = [
    {'icon': '😢', 'label': 'Pas top', 'color': Color(0xFFFF5252)},
    {'icon': '😐', 'label': 'Moyen', 'color': AppTheme.neonOrange},
    {'icon': '🙂', 'label': 'Bien', 'color': AppTheme.neonGreen},
    {'icon': '😁', 'label': 'Super', 'color': AppTheme.neonBlue},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comment vous sentez-vous aujourd\'hui ?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white60,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_moods.length, (index) {
            final isSelected = _selectedIndex == index;
            final mood = _moods[index];
            final color = mood['color'] as Color;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 20 : 16,
                  vertical: isSelected ? 16 : 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
                    width: isSelected ? 2 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Text(
                      mood['icon'] as String,
                      style: TextStyle(
                        fontSize: isSelected ? 32 : 24,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 8),
                      Text(
                        mood['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
