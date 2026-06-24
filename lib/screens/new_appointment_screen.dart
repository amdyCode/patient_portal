import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../widgets/doctor_selector.dart';
import '../widgets/date_selector.dart';
import '../widgets/time_selector.dart';
import '../theme/app_theme.dart';

class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  int _selectedDoctorIndex = -1;
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = -1;

  final List<Map<String, String>> doctors = [
    {
      'name': 'Dr. Sarah Martin',
      'specialty': 'Médecin Généraliste',
      'image': 'https://i.pravatar.cc/150?img=5',
    },
    {
      'name': 'Dr. Thomas Dubois',
      'specialty': 'Cardiologue',
      'image': 'https://i.pravatar.cc/150?img=11',
    },
    {
      'name': 'Dr. Marie Lambert',
      'specialty': 'Dermatologue',
      'image': 'https://i.pravatar.cc/150?img=9',
    },
  ];

  final List<String> dates = ['Auj', 'Dem', 'Jeu', 'Ven', 'Sam', 'Lun'];
  final List<String> daysNumber = ['14', '15', '16', '17', '18', '20'];
  
  final List<String> times = [
    '09:00', '09:30', '10:00', '11:00', '14:30', '15:00', '16:00', '17:30'
  ];

  void _confirmAppointment() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8 * anim1.value, sigmaY: 8 * anim1.value),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: AlertDialog(
              backgroundColor: AppTheme.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(32),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppTheme.neonGreen, size: 64),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Rendez-vous confirmé !',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Votre consultation avec ${doctors[_selectedDoctorIndex]['name']} est programmée.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white60, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop();
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Retour à l\'accueil',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canConfirm = _selectedDoctorIndex != -1 && _selectedTimeIndex != -1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('1. Choisissez un médecin'),
                    DoctorSelector(
                      doctors: doctors,
                      selectedIndex: _selectedDoctorIndex,
                      onChanged: (index) => setState(() => _selectedDoctorIndex = index),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('2. Date'),
                    DateSelector(
                      dates: dates,
                      daysNumber: daysNumber,
                      selectedIndex: _selectedDateIndex,
                      onChanged: (index) => setState(() => _selectedDateIndex = index),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('3. Heure disponible'),
                    TimeSelector(
                      times: times,
                      selectedIndex: _selectedTimeIndex,
                      onChanged: (index) => setState(() => _selectedTimeIndex = index),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: canConfirm ? _buildConfirmButton() : null,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 24, 24),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Nouveau RDV',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }



  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonPurple.withValues(alpha: 0.4),
                offset: const Offset(0, 10),
                blurRadius: 24,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _confirmAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Confirmer le rendez-vous',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
