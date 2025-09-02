import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_loader.dart';
import '../models/appointment.dart';
import '../widgets/appointment_card.dart';
import '../widgets/filter_tabs.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> 
    with TickerProviderStateMixin {
  int _selectedFilter = 0; // 0: Tous, 1: À venir, 2: Passés
  late AnimationController _listAnimationController;
  late Animation<double> _listAnimation;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _listAnimationController, curve: Curves.easeOut),
    );
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  void _onFilterChanged(int index) {
    setState(() {
      _selectedFilter = index;
    });
    _listAnimationController.reset();
    _listAnimationController.forward();
  }

  List<RendezVous> _getFilteredAppointments(List<RendezVous> appointments) {
    switch (_selectedFilter) {
      case 1: // À venir
        return appointments.where((apt) => apt.statut == StatutRendezVous.aVenir).toList();
      case 2: // Passés
        return appointments.where((apt) => apt.statut == StatutRendezVous.passe).toList();
      default: // Tous
        return appointments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            FilterTabs(
              selectedIndex: _selectedFilter,
              onChanged: _onFilterChanged,
              filters: const ['Tous', 'À venir', 'Passés'],
            ),
            Expanded(child: _buildAppointmentsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text(
            'Mes Rendez-vous',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return Consumer<DataLoader>(
      builder: (context, dataLoader, child) {
        return FutureBuilder<List<RendezVous>>(
          future: dataLoader.loadRendezVous(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF3B82F6),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 64,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun rendez-vous trouvé',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Vous n\'avez pas de rendez-vous planifiés.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showNewAppointmentDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Prendre un rendez-vous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            final filteredAppointments = _getFilteredAppointments(snapshot.data!);

            if (filteredAppointments.isEmpty) {
              String message = _selectedFilter == 1 
                  ? 'Aucun rendez-vous à venir'
                  : _selectedFilter == 2 
                    ? 'Aucun rendez-vous passé'
                    : 'Aucun rendez-vous';

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.event_busy_rounded,
                      size: 64,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              );
            }

            return FadeTransition(
              opacity: _listAnimation,
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: filteredAppointments.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return AppointmentCard(
                    appointment: filteredAppointments[index],
                    onModify: _showModifyAppointmentDialog,
                    onCancel: _showCancelAppointmentDialog,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showNewAppointmentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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

  void _showModifyAppointmentDialog(RendezVous appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Modifier le rendez-vous'),
          content: Text(
            'Modification du rendez-vous avec ${appointment.medecin.nomComplet} prévue bientôt.',
          ),
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

  void _showCancelAppointmentDialog(RendezVous appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Annuler le rendez-vous'),
          content: Text(
            'Êtes-vous sûr de vouloir annuler votre rendez-vous avec ${appointment.medecin.nomComplet} ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rendez-vous annulé'),
                    backgroundColor: Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
              ),
              child: const Text('Oui, annuler'),
            ),
          ],
        );
      },
    );
  }
}