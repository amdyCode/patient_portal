class Patient {
  final String id;
  final String prenom;
  final String nom;
  final DateTime dateNaissance;
  final String numeroSecu;
  final String telephone;
  final String email;
  final Adresse adresse;

  Patient({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.dateNaissance,
    required this.numeroSecu,
    required this.telephone,
    required this.email,
    required this.adresse,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      prenom: json['prenom'],
      nom: json['nom'],
      dateNaissance: DateTime.parse(json['dateNaissance']),
      numeroSecu: json['numeroSecu'],
      telephone: json['telephone'],
      email: json['email'],
      adresse: Adresse.fromJson(json['adresse']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prenom': prenom,
      'nom': nom,
      'dateNaissance': dateNaissance.toIso8601String(),
      'numeroSecu': numeroSecu,
      'telephone': telephone,
      'email': email,
      'adresse': adresse.toJson(),
    };
  }

  String get nomComplet => '$prenom $nom';

  int get age {
    final now = DateTime.now();
    int age = now.year - dateNaissance.year;
    if (now.month < dateNaissance.month ||
        (now.month == dateNaissance.month && now.day < dateNaissance.day)) {
      age--;
    }
    return age;
  }
}

class Adresse {
  final String rue;
  final String ville;
  final String codePostal;

  Adresse({
    required this.rue,
    required this.ville,
    required this.codePostal,
  });

  factory Adresse.fromJson(Map<String, dynamic> json) {
    return Adresse(
      rue: json['rue'],
      ville: json['ville'],
      codePostal: json['codePostal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rue': rue,
      'ville': ville,
      'codePostal': codePostal,
    };
  }

  String get adresseComplete => '$rue, $codePostal $ville';
}