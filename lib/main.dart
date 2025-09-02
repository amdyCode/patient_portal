import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'services/data_loader.dart';

void main() {
  runApp(MedicalPortalApp());
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
          fontFamily: 'SF Pro Display',
          scaffoldBackgroundColor: Color(0xFFF8FAFC),
          primaryColor: Color(0xFF2563EB),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFF2563EB),
            brightness: Brightness.light,
          ),
        ),
        routerConfig: AppRoutes.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}