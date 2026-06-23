import 'package:flutter/material.dart';
import '../models/recommandation.dart';

class HealthTipCard extends StatelessWidget {
  final Recommandation recommandation;

  const HealthTipCard({
    super.key,
    required this.recommandation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_getCategoryColor(), _getCategoryColor().withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getCategoryIcon(),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Conseil du jour',
                      style: TextStyle(
                        fontSize: 14,
                        color: _getCategoryColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recommandation.categorieLibelle,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getCategoryColor(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  recommandation.titre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommandation.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (recommandation.categorie) {
      case CategorieRecommandation.sommeil:
        return const Color(0xFF8B5CF6);
      case CategorieRecommandation.nutrition:
        return const Color(0xFF10B981);
      case CategorieRecommandation.activitePhysique:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getCategoryIcon() {
    switch (recommandation.categorie) {
      case CategorieRecommandation.sommeil:
        return Icons.bedtime_rounded;
      case CategorieRecommandation.nutrition:
        return Icons.restaurant_rounded;
      case CategorieRecommandation.activitePhysique:
        return Icons.fitness_center_rounded;
    }
  }
}