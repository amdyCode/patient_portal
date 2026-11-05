import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _hasChangesToSync = false;

  // Getters
  Patient? get patient => _patient;
  List<RendezVous>? get rendezVous => _rendezVous;
  DossierMedical? get dossierMedical => _dossierMedical;
  RecommandationsData? get recommandationsData => _recommandationsData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasChangesToSync => _hasChangesToSync;

  Future<Patient> loadPatient() async {
    if (_patient != null) return _patient!;

    try {
      _setLoading(true);
      final doc = await FirebaseFirestore.instance.collection('patients').doc('current_patient').get();
      if (!doc.exists) throw Exception('Patient non trouvé dans Firestore.');
      _patient = Patient.fromJson(doc.data()!);
      _setLoading(false);
      return _patient!;
    } catch (e) {
      _setError('Erreur lors du chargement des données patient: $e');
      throw Exception('Erreur lors du chargement des données patient: $e');
    }
  }

  Future<List<RendezVous>> loadRendezVous() async {
    if (_rendezVous != null) return _rendezVous!;

    try {
      _setLoading(true);
      final snapshot = await FirebaseFirestore.instance.collection('rendezvous').get();
      
      _rendezVous = snapshot.docs
          .map((doc) => RendezVous.fromJson(doc.data()))
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
      final doc = await FirebaseFirestore.instance.collection('dossiers').doc('current_dossier').get();
      if (!doc.exists) throw Exception('Dossier introuvable dans Firestore. Veuillez lancer le Seed Database.');
      _dossierMedical = DossierMedical.fromJson(doc.data()!);
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
      final doc = await FirebaseFirestore.instance.collection('recommandations').doc('current_recommandations').get();
      if (!doc.exists) throw Exception('Recommandations introuvables.');
      _recommandationsData = RecommandationsData.fromJson(doc.data()!);
      _setLoading(false);
      return _recommandationsData!;
    } catch (e) {
      _setError('Erreur lors du chargement des recommandations: $e');
      throw Exception('Erreur lors du chargement des recommandations: $e');
    }
  }

  Future<RendezVous?> getDernierRendezVous() async {
    final rendezVousList = await loadRendezVous();
    final rendezVousPasses = rendezVousList
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
    final rendezVousList = await loadRendezVous();
    final rendezVousAVenir = rendezVousList
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
    final rendezVousList = await loadRendezVous();
    return rendezVousList.where((rdv) => rdv.statut == statut).toList();
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
    if (isDataCached) return;
    try {
      _setLoading(true);
      await Future.wait([
        loadPatient(),
        loadRendezVous(),
        loadDossierMedical(),
        loadRecommandations(),
        _checkIfJsonChanged(),
      ]);
      _setLoading(false);
    } catch (e) {
      _setError('Erreur lors du préchargement des données: $e');
      print('Erreur lors du préchargement des données: $e');
    }
  }

  Future<void> _checkIfJsonChanged() async {
    try {
      final String patientStr = await rootBundle.loadString('assets/patient.json');
      final String dossierStr = await rootBundle.loadString('assets/dossier.json');
      final String recStr = await rootBundle.loadString('assets/recommandations.json');
      final String rdvStr = await rootBundle.loadString('assets/rendezvous.json');
      
      final int currentHash = (patientStr + dossierStr + recStr + rdvStr).hashCode;
      
      final doc = await FirebaseFirestore.instance.collection('metadata').doc('sync').get();
      if (doc.exists) {
        final int storedHash = doc.data()?['jsonHash'] ?? 0;
        _hasChangesToSync = currentHash != storedHash;
      } else {
        _hasChangesToSync = true;
      }
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la vérification des changements JSON: $e');
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

  Future<Recommandation?> getRecommandationDuJour() async {
    final data = await loadRecommandations();
    if (data.recommandations.isEmpty) return null;
    return data.recommandations.first;
  }

  Future<List<Recommandation>> getRecommandationsByCategorie(CategorieRecommandation? categorie) async {
    final data = await loadRecommandations();
    if (categorie == null) return data.recommandations;
    return data.recommandations.where((r) => r.categorie == categorie).toList();
  }

  Future<void> seedDatabase() async {
    try {
      _setLoading(true);
      final firestore = FirebaseFirestore.instance;

      final String patientStr = await rootBundle.loadString('assets/patient.json');
      final String dossierStr = await rootBundle.loadString('assets/dossier.json');
      final String recStr = await rootBundle.loadString('assets/recommandations.json');
      final String rdvStr = await rootBundle.loadString('assets/rendezvous.json');

      // Update Patient
      await firestore.collection('patients').doc('current_patient').set(json.decode(patientStr), SetOptions(merge: true));

      // Update Dossier
      await firestore.collection('dossiers').doc('current_dossier').set(json.decode(dossierStr), SetOptions(merge: true));

      // Update Recommandations
      await firestore.collection('recommandations').doc('current_recommandations').set(json.decode(recStr), SetOptions(merge: true));

      // Update Rendez-vous (using their specific ID to merge instead of deleting everything)
      final Map<String, dynamic> rdvData = json.decode(rdvStr);
      final List rdvList = rdvData['rendezVous'];
      for (var rdv in rdvList) {
        final String? id = rdv['id'];
        if (id != null) {
          await firestore.collection('rendezvous').doc(id).set(rdv, SetOptions(merge: true));
        } else {
          await firestore.collection('rendezvous').add(rdv);
        }
      }

      // Save new hash
      final int newHash = (patientStr + dossierStr + recStr + rdvStr).hashCode;
      await firestore.collection('metadata').doc('sync').set({'jsonHash': newHash});

      _hasChangesToSync = false;
      _setLoading(false);
      clearCache(); // Force reload from firestore
      print("SEED TERMINÉ AVEC SUCCÈS");
    } catch (e) {
      _setError('Erreur lors du seed de la base de données: $e');
      print('Erreur lors du seed de la base de données: $e');
    }
  }
}
