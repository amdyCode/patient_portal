import 'package:flutter/material.dart';

class InteractiveMoodSelector extends StatefulWidget {
  const InteractiveMoodSelector({super.key});

  @override
  State<InteractiveMoodSelector> createState() => _InteractiveMoodSelectorState();
}

class _InteractiveMoodSelectorState extends State<InteractiveMoodSelector> {
  int? _selectedIndex;

  final List<Map<String, dynamic>> _moods = [
    {'icon': '😢', 'label': 'Pas top', 'color': Color(0xFFEF4444)},
    {'icon': '😐', 'label': 'Moyen', 'color': Color(0xFFF59E0B)},
    {'icon': '🙂', 'label': 'Bien', 'color': Color(0xFF10B981)},
    {'icon': '😁', 'label': 'Super', 'color': Color(0xFF3B82F6)},
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
            color: Color(0xFF64748B),
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
                  color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? color.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
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
