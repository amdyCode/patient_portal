import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routes/app_routes.dart';
import 'services/data_loader.dart';

void main() {
  runApp(const MedicalPortalApp());
}

class MedicalPortalApp extends StatelessWidget {
  const MedicalPortalApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DataLoader(),
      child: MaterialApp.router(
        title: 'Portail Patient',
        theme: ThemeData(
          textTheme: GoogleFonts.outfitTextTheme(
            Theme.of(context).textTheme,
          ),
          scaffoldBackgroundColor: const Color(0xFFF4F7FC),
          primaryColor: const Color(0xFF4F46E5), // Deep Indigo
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4F46E5),
            primary: const Color(0xFF4F46E5),
            secondary: const Color(0xFF10B981), // Emerald accent
            surface: Colors.white,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        routerConfig: AppRoutes.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}