enum TypeAntecedent { maladie, chirurgie, familial, autre }
enum GraviteAllergie { legere, moderee, severe }
enum StatutTraitement { actif, suspendu, termine }

class DossierMedical {
  final String patientId;
  final List<Antecedent> antecedents;
  final List<Allergie> allergies;
  final List<Traitement> traitements;

  DossierMedical({
    required this.patientId,
    required this.antecedents,
    required this.allergies,
    required this.traitements,
  });

  factory DossierMedical.fromJson(Map<String, dynamic> json) {
    final dossierData = json['dossierMedical'];
    
    return DossierMedical(
      patientId: json['patientId'],
      antecedents: (dossierData['antecedents'] as List)
          .map((e) => Antecedent.fromJson(e))
          .toList(),
      allergies: (dossierData['allergies'] as List)
          .map((e) => Allergie.fromJson(e))
          .toList(),
      traitements: (dossierData['traitements'] as List)
          .map((e) => Traitement.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'dossierMedical': {
        'antecedents': antecedents.map((e) => e.toJson()).toList(),
        'allergies': allergies.map((e) => e.toJson()).toList(),
        'traitements': traitements.map((e) => e.toJson()).toList(),
      },
    };
  }

  List<Traitement> get traitementsActifs => 
      traitements.where((t) => t.statut == StatutTraitement.actif).toList();
}

class Antecedent {
  final String id;
  final TypeAntecedent type;
  final String nom;
  final DateTime? dateDebut;
  final String statut;
  final String description;

  Antecedent({
    required this.id,
    required this.type,
    required this.nom,
    this.dateDebut,
    required this.statut,
    required this.description,
  });

  factory Antecedent.fromJson(Map<String, dynamic> json) {
    TypeAntecedent typeEnum;
    switch (json['type'].toLowerCase()) {
      case 'maladie':
        typeEnum = TypeAntecedent.maladie;
        break;
      case 'chirurgie':
        typeEnum = TypeAntecedent.chirurgie;
        break;
      case 'familial':
        typeEnum = TypeAntecedent.familial;
        break;
      default:
        typeEnum = TypeAntecedent.autre;
    }

    return Antecedent(
      id: json['id'],
      type: typeEnum,
      nom: json['nom'],
      dateDebut: json['dateDebut'] != null 
          ? DateTime.parse(json['dateDebut']) 
          : null,
      statut: json['statut'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    String typeString;
    switch (type) {
      case TypeAntecedent.maladie:
        typeString = 'Maladie';
        break;
      case TypeAntecedent.chirurgie:
        typeString = 'Chirurgie';
        break;
      case TypeAntecedent.familial:
        typeString = 'Familial';
        break;
      case TypeAntecedent.autre:
        typeString = 'Autre';
        break;
    }

    return {
      'id': id,
      'type': typeString,
      'nom': nom,
      'dateDebut': dateDebut?.toIso8601String(),
      'statut': statut,
      'description': description,
    };
  }

  String get typeLibelle {
    switch (type) {
      case TypeAntecedent.maladie:
        return 'Maladie';
      case TypeAntecedent.chirurgie:
        return 'Chirurgie';
      case TypeAntecedent.familial:
        return 'Antécédent familial';
      case TypeAntecedent.autre:
        return 'Autre';
    }
  }
}

class Allergie {
  final String id;
  final String nom;
  final String type;
  final GraviteAllergie gravite;
  final List<String> symptomes;
  final DateTime dateDecouverte;

  Allergie({
    required this.id,
    required this.nom,
    required this.type,
    required this.gravite,
    required this.symptomes,
    required this.dateDecouverte,
  });

  factory Allergie.fromJson(Map<String, dynamic> json) {
    GraviteAllergie graviteEnum;
    switch (json['gravite'].toLowerCase()) {
      case 'légère':
      case 'legere':
        graviteEnum = GraviteAllergie.legere;
        break;
      case 'modérée':
      case 'moderee':
        graviteEnum = GraviteAllergie.moderee;
        break;
      case 'sévère':
      case 'severe':
        graviteEnum = GraviteAllergie.severe;
        break;
      default:
        graviteEnum = GraviteAllergie.legere;
    }

    return Allergie(
      id: json['id'],
      nom: json['nom'],
      type: json['type'],
      gravite: graviteEnum,
      symptomes: List<String>.from(json['symptomes']),
      dateDecouverte: DateTime.parse(json['dateDecouverte']),
    );
  }

  Map<String, dynamic> toJson() {
    String graviteString;
    switch (gravite) {
      case GraviteAllergie.legere:
        graviteString = 'Légère';
        break;
      case GraviteAllergie.moderee:
        graviteString = 'Modérée';
        break;
      case GraviteAllergie.severe:
        graviteString = 'Sévère';
        break;
    }

    return {
      'id': id,
      'nom': nom,
      'type': type,
      'gravite': graviteString,
      'symptomes': symptomes,
      'dateDecouverte': dateDecouverte.toIso8601String(),
    };
  }

  String get graviteLibelle {
    switch (gravite) {
      case GraviteAllergie.legere:
        return 'Légère';
      case GraviteAllergie.moderee:
        return 'Modérée';
      case GraviteAllergie.severe:
        return 'Sévère';
    }
  }
}

class Traitement {
  final String id;
  final String medicament;
  final String dosage;
  final String frequence;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final String prescripteur;
  final String indication;
  final StatutTraitement statut;

  Traitement({
    required this.id,
    required this.medicament,
    required this.dosage,
    required this.frequence,
    required this.dateDebut,
    this.dateFin,
    required this.prescripteur,
    required this.indication,
    required this.statut,
  });

  factory Traitement.fromJson(Map<String, dynamic> json) {
    StatutTraitement statutEnum;
    switch (json['statut'].toLowerCase()) {
      case 'actif':
        statutEnum = StatutTraitement.actif;
        break;
      case 'suspendu':
        statutEnum = StatutTraitement.suspendu;
        break;
      case 'terminé':
      case 'termine':
        statutEnum = StatutTraitement.termine;
        break;
      default:
        statutEnum = StatutTraitement.actif;
    }

    return Traitement(
      id: json['id'],
      medicament: json['medicament'],
      dosage: json['dosage'],
      frequence: json['frequence'],
      dateDebut: DateTime.parse(json['dateDebut']),
      dateFin: json['dateFin'] != null 
          ? DateTime.parse(json['dateFin']) 
          : null,
      prescripteur: json['prescripteur'],
      indication: json['indication'],
      statut: statutEnum,
    );
  }

  Map<String, dynamic> toJson() {
    String statutString;
    switch (statut) {
      case StatutTraitement.actif:
        statutString = 'Actif';
        break;
      case StatutTraitement.suspendu:
        statutString = 'Suspendu';
        break;
      case StatutTraitement.termine:
        statutString = 'Terminé';
        break;
    }

    return {
      'id': id,
      'medicament': medicament,
      'dosage': dosage,
      'frequence': frequence,
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin?.toIso8601String(),
      'prescripteur': prescripteur,
      'indication': indication,
      'statut': statutString,
    };
  }

  String get statutLibelle {
    switch (statut) {
      case StatutTraitement.actif:
        return 'En cours';
      case StatutTraitement.suspendu:
        return 'Suspendu';
      case StatutTraitement.termine:
        return 'Terminé';
    }
  }

  String get medicamentComplet => '$medicament $dosage';

  bool get estActif => statut == StatutTraitement.actif;
}