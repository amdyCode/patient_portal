import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import '../models/dossier.dart';
import '../models/recommandation.dart';

class DataLoader extends ChangeNotifier {
  static final DataLoader _instance = DataLoader._internal();
  factory DataLoader() => _instance;
  DataLoader._internal();

  Patient? _patient;
  List<RendezVous>? _rendezVous;
  DossierMedical? _dossierMedical;
  RecommandationsData? _recommandationsData;

  bool _isLoading = false;
  String? _error;

  // Getters
  Patient? get patient => _patient;
  List<RendezVous>? get rendezVous => _rendezVous;
  DossierMedical? get dossierMedical => _dossierMedical;
  RecommandationsData? get recommandationsData => _recommandationsData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<Patient> loadPatient() async {
    if (_patient != null) return _patient!;

    try {
      _setLoading(true);
      final String jsonString = await rootBundle.loadString(
        'assets/patient.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _patient = Patient.fromJson(jsonData);
      _setLoading(false);
      return _patient!;
    } catch (e) {
      _setError('Erreur lors du chargement des données patient: $e');
      throw Exception('Erreur lors du chargement des données patient: $e');
    }
  }

  // Charge tous les rendez-vous depuis le fichier JSON
  Future<List<RendezVous>> loadRendezVous() async {
    if (_rendezVous != null) return _rendezVous!;

    try {
      _setLoading(true);
      final String jsonString = await rootBundle.loadString(
        'assets/rendezvous.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _rendezVous = (jsonData['rendezVous'] as List)
          .map((rdvJson) => RendezVous.fromJson(rdvJson))
          .toList();

      // Tri par date (les plus récents en premier)
      _rendezVous!.sort(
        (a, b) => b.dateTimeComplete.compareTo(a.dateTimeComplete),
      );

      _setLoading(false);
      return _rendezVous!;
    } catch (e) {
      _setError('Erreur lors du chargement des rendez-vous: $e');
      throw Exception('Erreur lors du chargement des rendez-vous: $e');
    }
  }

  Future<DossierMedical> loadDossierMedical() async {
    if (_dossierMedical != null) return _dossierMedical!;

    try {
      _setLoading(true);
      final String jsonString = await rootBundle.loadString(
        'assets/dossier.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _dossierMedical = DossierMedical.fromJson(jsonData);
      _setLoading(false);
      return _dossierMedical!;
    } catch (e) {
      _setError('Erreur lors du chargement du dossier médical: $e');
      throw Exception('Erreur lors du chargement du dossier médical: $e');
    }
  }

  Future<RecommandationsData> loadRecommandations() async {
    if (_recommandationsData != null) return _recommandationsData!;

    try {
      _setLoading(true);
      final String jsonString = await rootBundle.loadString(
        'assets/recommandations.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _recommandationsData = RecommandationsData.fromJson(jsonData);
      _setLoading(false);
      return _recommandationsData!;
    } catch (e) {
      _setError('Erreur lors du chargement des recommandations: $e');
      throw Exception('Erreur lors du chargement des recommandations: $e');
    }
  }

  Future<RendezVous?> getDernierRendezVous() async {
    final rendezVous = await loadRendezVous();
    final rendezVousPasses = rendezVous
        .where((rdv) => rdv.statut == StatutRendezVous.passe)
        .toList();

    if (rendezVousPasses.isEmpty) return null;

    // Tri par date décroissante et prendre le premier
    rendezVousPasses.sort(
      (a, b) => b.dateTimeComplete.compareTo(a.dateTimeComplete),
    );
    return rendezVousPasses.first;
  }

  Future<List<RendezVous>> getProchainRendezVous() async {
    final rendezVous = await loadRendezVous();
    final rendezVousAVenir = rendezVous
        .where((rdv) => rdv.statut == StatutRendezVous.aVenir)
        .toList();

    // Tri par date croissante (les plus proches en premier)
    rendezVousAVenir.sort(
      (a, b) => a.dateTimeComplete.compareTo(b.dateTimeComplete),
    );
    return rendezVousAVenir;
  }

  Future<RendezVous?> getNextRendezVous() async {
    final prochains = await getProchainRendezVous();
    return prochains.isNotEmpty ? prochains.first : null;
  }

  Future<List<RendezVous>> getRendezVousByStatut(
    StatutRendezVous statut,
  ) async {
    final rendezVous = await loadRendezVous();
    return rendezVous.where((rdv) => rdv.statut == statut).toList();
  }

  Future<Recommandation?> getRecommandationDuJour() async {
    final recommandationsData = await loadRecommandations();
    return recommandationsData.recommandationDuJour;
  }

  Future<List<Recommandation>> getRecommandationsByCategorie(
    CategorieRecommandation? categorie,
  ) async {
    final recommandationsData = await loadRecommandations();
    return Recommandation.filtrerParCategorie(
      recommandationsData.recommandations,
      categorie,
    );
  }

  Future<List<Traitement>> getTraitementsActifs() async {
    final dossier = await loadDossierMedical();
    return dossier.traitementsActifs;
  }

  Future<List<Allergie>> getAllergiesByGravite(GraviteAllergie gravite) async {
    final dossier = await loadDossierMedical();
    return dossier.allergies.where((a) => a.gravite == gravite).toList();
  }

  Future<List<Antecedent>> getAntecedentsByType(TypeAntecedent type) async {
    final dossier = await loadDossierMedical();
    return dossier.antecedents.where((a) => a.type == type).toList();
  }

  Future<void> preloadAllData() async {
    try {
      _setLoading(true);
      await Future.wait([
        loadPatient(),
        loadRendezVous(),
        loadDossierMedical(),
        loadRecommandations(),
      ]);
      _setLoading(false);
    } catch (e) {
      _setError('Erreur lors du préchargement des données: $e');
      throw Exception('Erreur lors du préchargement des données: $e');
    }
  }

  void clearCache() {
    _patient = null;
    _rendezVous = null;
    _dossierMedical = null;
    _recommandationsData = null;
    _error = null;
    notifyListeners();
  }

  bool get isDataCached =>
      _patient != null &&
      _rendezVous != null &&
      _dossierMedical != null &&
      _recommandationsData != null;

  Future<Map<String, dynamic>> getStatistiques() async {
    await preloadAllData();

    final prochains = await getProchainRendezVous();
    final passes = await getRendezVousByStatut(StatutRendezVous.passe);
    final traitements = await getTraitementsActifs();

    return {
      'nombreProchainRendezVous': prochains.length,
      'nombreRendezVousPasses': passes.length,
      'nombreTraitementsActifs': traitements.length,
      'nombreAllergies': _dossierMedical?.allergies.length ?? 0,
      'nombreAntecedents': _dossierMedical?.antecedents.length ?? 0,
      'nombreRecommandations':
          _recommandationsData?.recommandations.length ?? 0,
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _error = null;
    Future.microtask(() => notifyListeners());
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    Future.microtask(() => notifyListeners());
  }
}
