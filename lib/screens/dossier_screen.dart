import 'package:flutter/material.dart';
import 'package:patient_portal/widgets/patient_info_card.dart';
import 'package:provider/provider.dart';
import '../services/data_loader.dart';
import '../models/dossier.dart';
import '../widgets/dossier_section.dart';
import '../theme/app_theme.dart';

class DossierScreen extends StatefulWidget {
  const DossierScreen({super.key});

  @override
  State<DossierScreen> createState() => _DossierScreenState();
}

class _DossierScreenState extends State<DossierScreen> 
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Créer des animations décalées pour chaque section
    _slideAnimations = List.generate(4, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
      ));
    });
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
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
                color: AppTheme.neonBlue.withValues(alpha: 0.1),
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
                color: AppTheme.neonPurple.withValues(alpha: 0.1),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
            _buildHeader(),
            Expanded(
              child: Consumer<DataLoader>(
                builder: (context, dataLoader, child) {
                  return FutureBuilder<DossierMedical>(
                    future: dataLoader.loadDossierMedical(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF3B82F6),
                          ),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_off_outlined,
                                size: 64,
                                color: Color(0xFF64748B),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Impossible de charger le dossier',
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

                      final dossier = snapshot.data!;
                      final patient = dataLoader.patient;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                        child: Column(
                          children: [
                            SlideTransition(
                              position: _slideAnimations[0],
                              child: PatientInfoCard(patient: patient),
                            ),
                            const SizedBox(height: 20),
                            SlideTransition(
                              position: _slideAnimations[1],
                              child: DossierSection(
                                title: 'Antécédents médicaux',
                                icon: Icons.history_rounded,
                                color: const Color(0xFF8B5CF6),
                                items: dossier.antecedents
                                    .map((ant) => '${ant.nom} - ${ant.description}')
                                    .toList(),
                                onEdit: () => _showEditSectionDialog('Antécédents médicaux'),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SlideTransition(
                              position: _slideAnimations[2],
                              child: DossierSection(
                                title: 'Allergies',
                                icon: Icons.warning_rounded,
                                color: const Color(0xFFF59E0B),
                                items: dossier.allergies
                                    .map((all) => '${all.nom} (${all.graviteLibelle}) - ${all.symptomes.join(', ')}')
                                    .toList(),
                                onEdit: () => _showEditSectionDialog('Allergies'),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SlideTransition(
                              position: _slideAnimations[3],
                              child: DossierSection(
                                title: 'Traitements en cours',
                                icon: Icons.medication_rounded,
                                color: const Color(0xFF10B981),
                                items: dossier.traitementsActifs
                                    .map((trait) => '${trait.medicamentComplet} - ${trait.frequence} (${trait.indication})')
                                    .toList(),
                                onEdit: () => _showEditSectionDialog('Traitements en cours'),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
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
            'Mon Dossier Médical',
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
              Icons.share_rounded,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSectionDialog(String sectionTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
          ),
          title: Text('Modifier $sectionTitle'),
          content: const Text('La modification de cette section sera bientôt disponible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}