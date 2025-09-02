enum CategorieRecommandation { sommeil, nutrition, activitePhysique }
enum PrioriteRecommandation { faible, moyenne, haute }

class Recommandation {
  final String id;
  final String titre;
  final String description;
  final CategorieRecommandation categorie;
  final PrioriteRecommandation priorite;
  final DateTime dateCreation;
  final String source;

  Recommandation({
    required this.id,
    required this.titre,
    required this.description,
    required this.categorie,
    required this.priorite,
    required this.dateCreation,
    required this.source,
  });

  factory Recommandation.fromJson(Map<String, dynamic> json) {
    // Convertir la catégorie string en enum
    CategorieRecommandation categorieEnum;
    switch (json['categorie'].toLowerCase()) {
      case 'sommeil':
        categorieEnum = CategorieRecommandation.sommeil;
        break;
      case 'nutrition':
        categorieEnum = CategorieRecommandation.nutrition;
        break;
      case 'activité physique':
      case 'activite physique':
        categorieEnum = CategorieRecommandation.activitePhysique;
        break;
      default:
        categorieEnum = CategorieRecommandation.nutrition;
    }

    // Convertir la priorité string en enum
    PrioriteRecommandation prioriteEnum;
    switch (json['priorite'].toLowerCase()) {
      case 'faible':
        prioriteEnum = PrioriteRecommandation.faible;
        break;
      case 'moyenne':
        prioriteEnum = PrioriteRecommandation.moyenne;
        break;
      case 'haute':
        prioriteEnum = PrioriteRecommandation.haute;
        break;
      default:
        prioriteEnum = PrioriteRecommandation.moyenne;
    }

    return Recommandation(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      categorie: categorieEnum,
      priorite: prioriteEnum,
      dateCreation: DateTime.parse(json['dateCreation']),
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    // Convertir les enums en strings
    String categorieString;
    switch (categorie) {
      case CategorieRecommandation.sommeil:
        categorieString = 'Sommeil';
        break;
      case CategorieRecommandation.nutrition:
        categorieString = 'Nutrition';
        break;
      case CategorieRecommandation.activitePhysique:
        categorieString = 'Activité physique';
        break;
    }

    String prioriteString;
    switch (priorite) {
      case PrioriteRecommandation.faible:
        prioriteString = 'Faible';
        break;
      case PrioriteRecommandation.moyenne:
        prioriteString = 'Moyenne';
        break;
      case PrioriteRecommandation.haute:
        prioriteString = 'Haute';
        break;
    }

    return {
      'id': id,
      'titre': titre,
      'description': description,
      'categorie': categorieString,
      'priorite': prioriteString,
      'dateCreation': dateCreation.toIso8601String(),
      'source': source,
    };
  }

  String get categorieLibelle {
    switch (categorie) {
      case CategorieRecommandation.sommeil:
        return '😴 Sommeil';
      case CategorieRecommandation.nutrition:
        return '🍎 Nutrition';
      case CategorieRecommandation.activitePhysique:
        return '🏃‍♂️ Activité physique';
    }
  }

  String get prioriteLibelle {
    switch (priorite) {
      case PrioriteRecommandation.faible:
        return 'Faible';
      case PrioriteRecommandation.moyenne:
        return 'Moyenne';
      case PrioriteRecommandation.haute:
        return 'Haute';
    }
  }

  String get prioriteEmoji {
    switch (priorite) {
      case PrioriteRecommandation.faible:
        return '🔵';
      case PrioriteRecommandation.moyenne:
        return '🟡';
      case PrioriteRecommandation.haute:
        return '🔴';
    }
  }

  // Méthode helper pour filtrer par catégorie
  static List<Recommandation> filtrerParCategorie(
    List<Recommandation> recommandations,
    CategorieRecommandation? categorie,
  ) {
    if (categorie == null) return recommandations;
    return recommandations
        .where((r) => r.categorie == categorie)
        .toList();
  }

  // Méthode helper pour trier par priorité
  static List<Recommandation> trierParPriorite(
    List<Recommandation> recommandations,
  ) {
    final copy = List<Recommandation>.from(recommandations);
    copy.sort((a, b) {
      // Ordre: Haute -> Moyenne -> Faible
      const prioriteValues = {
        PrioriteRecommandation.haute: 3,
        PrioriteRecommandation.moyenne: 2,
        PrioriteRecommandation.faible: 1,
      };
      return prioriteValues[b.priorite]!
          .compareTo(prioriteValues[a.priorite]!);
    });
    return copy;
  }
}

// Classe helper pour gérer les recommandations
class RecommandationsData {
  final List<Recommandation> recommandations;

  RecommandationsData({required this.recommandations});

  factory RecommandationsData.fromJson(Map<String, dynamic> json) {
    return RecommandationsData(
      recommandations: (json['recommandations'] as List)
          .map((e) => Recommandation.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommandations': recommandations.map((e) => e.toJson()).toList(),
    };
  }

  List<Recommandation> get recommandationsSommeil =>
      Recommandation.filtrerParCategorie(
        recommandations,
        CategorieRecommandation.sommeil,
      );

  List<Recommandation> get recommandationsNutrition =>
      Recommandation.filtrerParCategorie(
        recommandations,
        CategorieRecommandation.nutrition,
      );

  List<Recommandation> get recommandationsActivitePhysique =>
      Recommandation.filtrerParCategorie(
        recommandations,
        CategorieRecommandation.activitePhysique,
      );

  List<Recommandation> get recommandationsHautePriorite =>
      recommandations
          .where((r) => r.priorite == PrioriteRecommandation.haute)
          .toList();

  // Recommandation aléatoire du jour
  Recommandation? get recommandationDuJour {
    if (recommandations.isEmpty) return null;
    
    // Utilise la date actuelle comme seed pour avoir toujours 
    // la même recommandation le même jour
    final today = DateTime.now();
    final seed = today.day + today.month * 31 + today.year * 365;
    final index = seed % recommandations.length;
    
    return recommandations[index];
  }
}