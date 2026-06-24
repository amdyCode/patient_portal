import 'package:flutter/material.dart';
import 'package:patient_portal/widgets/recommendation_card.dart';
import 'package:provider/provider.dart';
import '../services/data_loader.dart';
import '../models/recommandation.dart';
import '../theme/app_theme.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with TickerProviderStateMixin {
  int _selectedCategory = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _changeCategory(int index) {
    setState(() {
      _selectedCategory = index;
    });
    _fadeController.reset();
    _fadeController.forward();
  }

  CategorieRecommandation? _getCategorieFromIndex(int index) {
    switch (index) {
      case 0:
        return CategorieRecommandation.sommeil;
      case 1:
        return CategorieRecommandation.nutrition;
      case 2:
        return CategorieRecommandation.activitePhysique;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.neonGreen.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.neonBlue.withValues(alpha: 0.1),
              ),
            ),
          ),
          SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryTabs(),
            Expanded(child: _buildRecommendationsList()),
          ],
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text(
            'Recommandations',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonBlue.withValues(alpha: 0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.bookmark_outline_rounded,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          _buildCategoryTab('Sommeil', 0, Icons.bedtime_rounded),
          _buildCategoryTab('Nutrition', 1, Icons.restaurant_rounded),
          _buildCategoryTab('Activité', 2, Icons.fitness_center_rounded),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String title, int index, IconData icon) {
    bool isSelected = _selectedCategory == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _changeCategory(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.neonGradient : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.neonPurple.withValues(alpha: 0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white60,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsList() {
    return Consumer<DataLoader>(
      builder: (context, dataLoader, child) {
        final category = _getCategorieFromIndex(_selectedCategory);

        return FutureBuilder<List<Recommandation>>(
          future: dataLoader.getRecommandationsByCategorie(category),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 64,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aucune recommandation trouvée',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            final recommendations = snapshot.data!;

            if (recommendations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 64,
                      color: const Color(0xFF64748B),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucune recommandation disponible',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Revenez plus tard pour de nouveaux conseils.',
                      style: TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              );
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                itemCount: recommendations.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final recommendation = recommendations[index];
                  final categoryColor = _getRecommendationColor(
                    recommendation.categorie,
                  );
                  return RecommendationCard(
                    recommendation: recommendation,
                    categoryColor: categoryColor,
                    onMarkAsRead: () => _markAsRead(recommendation),
                    onBookmark: () => _bookmarkRecommendation(recommendation),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _markAsRead(Recommandation recommendation) {
    final categoryColor = _getRecommendationColor(recommendation.categorie);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Recommandation marquée comme lue'),
        backgroundColor: categoryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _bookmarkRecommendation(Recommandation recommendation) {
    final categoryColor = _getRecommendationColor(recommendation.categorie);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Recommandation ajoutée aux favoris'),
        backgroundColor: categoryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Color _getRecommendationColor(CategorieRecommandation categorie) {
    switch (categorie) {
      case CategorieRecommandation.sommeil:
        return AppTheme.neonPurple;
      case CategorieRecommandation.nutrition:
        return AppTheme.neonGreen;
      case CategorieRecommandation.activitePhysique:
        return AppTheme.neonBlue;
    }
  }

  IconData _getCategoryIcon(CategorieRecommandation? categorie) {
    if (categorie == null) return Icons.lightbulb_outline;

    switch (categorie) {
      case CategorieRecommandation.sommeil:
        return Icons.bedtime_rounded;
      case CategorieRecommandation.nutrition:
        return Icons.restaurant_rounded;
      case CategorieRecommandation.activitePhysique:
        return Icons.fitness_center_rounded;
    }
  }
}
