import 'package:flutter/material.dart';
import 'package:patient_portal/widgets/last_appointment_card.dart';
import 'package:patient_portal/widgets/stat_card.dart';
import 'package:provider/provider.dart';
import '../services/data_loader.dart';
import '../models/patient.dart';
import '../models/recommandation.dart';
import '../widgets/health_tip_card.dart';
import '../widgets/interactive_mood_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataLoader>().preloadAllData();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  String _getTimeGreeting() {
    DateTime now = DateTime.now();
    if (now.hour < 12) return 'Bonjour';
    if (now.hour < 17) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: SlideTransition(
          position: _slideAnimation,
          child: Consumer<DataLoader>(
            builder: (context, dataLoader, child) {
              if (dataLoader.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (dataLoader.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Erreur de chargement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dataLoader.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          dataLoader.clearCache();
                          dataLoader.preloadAllData();
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(dataLoader.patient),
                    const SizedBox(height: 30),
                    const InteractiveMoodSelector(),
                    const SizedBox(height: 30),
                    _buildQuickStatsRow(),
                    const SizedBox(height: 25),
                    LastAppointmentCard(dataLoader: dataLoader),
                    const SizedBox(height: 25),
                    _buildHealthTipCard(dataLoader),
                    const SizedBox(height: 25),
                    _buildQuickActionsGrid(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(Patient? patient) {
    String firstName = patient?.prenom ?? 'Utilisateur';
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getTimeGreeting()},',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              firstName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'), // Fake avatar
          ),
        )
      ],
    );
  }

  Widget _buildQuickStatsRow() {
    return Consumer<DataLoader>(
      builder: (context, dataLoader, child) {
        return FutureBuilder<Map<String, dynamic>>(
          future: dataLoader.getStatistiques(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }
            
            final stats = snapshot.data!;
            
            return Row(
              children: [
                Expanded(
                  child: StatCard(
                    value: '${stats['nombreProchainRendezVous']}',
                    label: 'RDV à venir',
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: StatCard(
                    value: '${stats['nombreTraitementsActifs']}',
                    label: 'Traitements',
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: StatCard(
                    value: '${stats['nombreAllergies']}',
                    label: 'Allergies',
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHealthTipCard(DataLoader dataLoader) {
    return FutureBuilder<Recommandation?>(
      future: dataLoader.getRecommandationDuJour(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        return HealthTipCard(recommandation: snapshot.data!);
      },
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Nouveau RDV',
                Icons.calendar_month_rounded,
                Theme.of(context).primaryColor,
                _showNewAppointmentDialog,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildActionCard(
                'Urgence',
                Icons.local_hospital_rounded,
                const Color(0xFFEF4444),
                _showEmergencyDialog,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewAppointmentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Nouveau rendez-vous'),
          content: const Text('Cette fonctionnalité sera bientôt disponible.'),
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

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text('Urgence médicale'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('En cas d\'urgence vitale, appelez immédiatement le :'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_in_talk_rounded, color: Color(0xFFEF4444)),
                    SizedBox(width: 8),
                    Text(
                      '15 - SAMU',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Compris'),
            ),
          ],
        );
      },
    );
  }
}