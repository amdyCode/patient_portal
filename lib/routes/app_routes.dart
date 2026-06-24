import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/appointments_screen.dart';
import '../screens/dossier_screen.dart';
import '../screens/recommandations_screen.dart';
import '../widgets/main_navigation_wrapper.dart';
import '../screens/new_appointment_screen.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationWrapper(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/rendez-vous',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AppointmentsScreen(),
            ),
          ),
          GoRoute(
            path: '/dossier',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DossierScreen(),
            ),
          ),
          GoRoute(
            path: '/recommandations',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RecommendationsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/nouvelle-prise-rdv',
        builder: (context, state) => const NewAppointmentScreen(),
      ),
    ],
  );

  static const String home = '/';
  static const String appointments = '/rendez-vous';
  static const String dossier = '/dossier';
  static const String recommendations = '/recommandations';
}