import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'services/data_loader.dart';
import 'theme/app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
// import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );
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
        theme: AppTheme.darkTheme,
        routerConfig: AppRoutes.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}