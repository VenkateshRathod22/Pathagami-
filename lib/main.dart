import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tripried/view/splash_screen/splace_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();

    print("Firebase Connected Successfully!");
    print("Firebase App Name: ${Firebase.app().name}");
    print("Firebase Project ID: ${Firebase.app().options.projectId}");
  } catch (e) {
    print("Firebase Connection Failed: $e");
  }



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPiNGO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF65A30D),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF65A30D),
          primary: const Color(0xFF65A30D),
          secondary: const Color(0xFF84CC16),
        ),
      ),
      home: const SplaceScreen(),
    );
  }
}
