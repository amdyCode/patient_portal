import 'package:flutter/material.dart';

class DoctorSelector extends StatelessWidget {
  final List<Map<String, String>> doctors;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const DoctorSelector({
    super.key,
    required this.doctors,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.03),
                    offset: Offset(0, isSelected ? 8 : 4),
                    blurRadius: isSelected ? 24 : 12,
                  ),
                ],
                border: Border.all(
                  color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(doctors[index]['image']!),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: isSelected ? Colors.white.withValues(alpha: 0.5) : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    doctors[index]['name']!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctors[index]['specialty']!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF64748B),
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
