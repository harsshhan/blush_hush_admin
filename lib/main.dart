import 'package:blush_hush_admin/provider/manager_provider.dart';
import 'package:blush_hush_admin/provider/nav_provider.dart';
import 'package:blush_hush_admin/provider/project_provider.dart';
import 'package:blush_hush_admin/provider/client_provider.dart';
import 'package:blush_hush_admin/screens/splash_screen.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await FirebaseAuth.instance.signOut();
  // if (kDebugMode) {

  //   await FirebaseAuth.instance.useAuthEmulator('localhost', 5001);
  //   FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5002);
  //   FirebaseFirestore.instance.useFirestoreEmulator('localhost', 5003);
  // }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ManagerProvider()),
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      home: SplashScreen(),
    );
  }
}
