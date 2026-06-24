import 'package:flutter/material.dart';
import '../models/recommandation.dart';
import '../theme/app_theme.dart';
import 'dart:ui';

class HealthTipCard extends StatelessWidget {
  final Recommandation recommandation;

  const HealthTipCard({
    super.key,
    required this.recommandation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getCategoryColor().withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommandation.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
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
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (recommandation.categorie) {
      case CategorieRecommandation.sommeil:
        return AppTheme.neonPurple;
      case CategorieRecommandation.nutrition:
        return AppTheme.neonGreen;
      case CategorieRecommandation.activitePhysique:
        return AppTheme.neonBlue;
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