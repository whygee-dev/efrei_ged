import 'package:efrei_ged/colors.dart';
import 'package:efrei_ged/pages/documentTypes.dart';
import 'package:efrei_ged/pages/home.dart';
import 'package:efrei_ged/pages/login.dart';
import 'package:efrei_ged/pages/signup.dart';
import 'package:efrei_ged/supabase.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await initSupabase();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Efrei GED',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          errorColor: Colors.red,
          backgroundColor: primaryColor,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: secondaryColor,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 52.0,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
          headlineMedium: TextStyle(
            fontSize: 36.0,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
          bodyLarge: TextStyle(
            fontSize: 18.0,
            color: secondaryColor,
          ),
          bodyMedium: TextStyle(
            fontSize: 14.0,
            color: secondaryColor,
          ),
          bodySmall: TextStyle(
            fontSize: 10.0,
            color: secondaryColor,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: secondaryColor,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: secondaryColor,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(secondaryColor),
            foregroundColor: MaterialStateProperty.all(primaryColor),
          ),
        ),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/signup': (context) => const SignupPage(),
        '/document-types': (context) => const DocumentTypesPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
