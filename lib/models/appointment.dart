import 'package:flutter/material.dart';

enum StatutRendezVous { passe, aVenir, annule }

class RendezVous {
  final String id;
  final Medecin medecin;
  final DateTime date;
  final TimeOfDay heure;
  final Lieu lieu;
  final String type;
  final StatutRendezVous statut;
  final int duree; // en minutes
  final String? notes;

  RendezVous({
    required this.id,
    required this.medecin,
    required this.date,
    required this.heure,
    required this.lieu,
    required this.type,
    required this.statut,
    required this.duree,
    this.notes,
  });

  factory RendezVous.fromJson(Map<String, dynamic> json) {
    // Parser l'heure depuis le format "14:30"
    final timeParts = json['heure'].toString().split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Convertir le statut string en enum
    StatutRendezVous statutEnum;
    switch (json['statut']) {
      case 'passé':
        statutEnum = StatutRendezVous.passe;
        break;
      case 'à_venir':
        statutEnum = StatutRendezVous.aVenir;
        break;
      case 'annulé':
        statutEnum = StatutRendezVous.annule;
        break;
      default:
        statutEnum = StatutRendezVous.aVenir;
    }

    return RendezVous(
      id: json['id'],
      medecin: Medecin.fromJson(json['medecin']),
      date: DateTime.parse(json['date']),
      heure: TimeOfDay(hour: hour, minute: minute),
      lieu: Lieu.fromJson(json['lieu']),
      type: json['type'],
      statut: statutEnum,
      duree: json['duree'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    String statutString;
    switch (statut) {
      case StatutRendezVous.passe:
        statutString = 'passé';
        break;
      case StatutRendezVous.aVenir:
        statutString = 'à_venir';
        break;
      case StatutRendezVous.annule:
        statutString = 'annulé';
        break;
    }

    return {
      'id': id,
      'medecin': medecin.toJson(),
      'date': date.toIso8601String(),
      'heure': '${heure.hour.toString().padLeft(2, '0')}:${heure.minute.toString().padLeft(2, '0')}',
      'lieu': lieu.toJson(),
      'type': type,
      'statut': statutString,
      'duree': duree,
      'notes': notes,
    };
  }

  DateTime get dateTimeComplete {
    return DateTime(date.year, date.month, date.day, heure.hour, heure.minute);
  }

  bool get estPasse => dateTimeComplete.isBefore(DateTime.now());

  String get heureFormatee {
    return '${heure.hour.toString().padLeft(2, '0')}:${heure.minute.toString().padLeft(2, '0')}';
  }

  String get dureeFormatee {
    final hours = duree ~/ 60;
    final minutes = duree % 60;
    if (hours > 0) {
      return '${hours}h${minutes > 0 ? ' ${minutes}min' : ''}';
    }
    return '${minutes}min';
  }
}

class Medecin {
  final String nom;
  final String prenom;
  final String specialite;

  Medecin({
    required this.nom,
    required this.prenom,
    required this.specialite,
  });

  factory Medecin.fromJson(Map<String, dynamic> json) {
    return Medecin(
      nom: json['nom'],
      prenom: json['prenom'],
      specialite: json['specialite'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'specialite': specialite,
    };
  }

  String get nomComplet => '$prenom $nom';
}

class Lieu {
  final String cabinet;
  final String adresse;

  Lieu({
    required this.cabinet,
    required this.adresse,
  });

  factory Lieu.fromJson(Map<String, dynamic> json) {
    return Lieu(
      cabinet: json['cabinet'],
      adresse: json['adresse'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cabinet': cabinet,
      'adresse': adresse,
    };
  }
}