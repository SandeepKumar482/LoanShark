import 'package:flutter/material.dart';
import 'package:loan_shark/login_screen.dart';
import 'package:loan_shark/routes.dart';

import 'HomeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      title: 'VAZIR FINANCE',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        appBarTheme:  AppBarTheme(
          //titleSpacing: 100.0,
          toolbarHeight: height*0.080,
          centerTitle: true,
          shadowColor: Colors.black12,
          //     shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.vertical(
          //     bottom: Radius.circular(10),
          //       top: Radius.circular(10)
          // ),
          // ),
          backgroundColor: Colors.black,
          // Keep your background color
          elevation: 10.0, // Keep your elevation
        ),
        brightness: Brightness.light,
        primaryColor: Colors.brown[700],
        // Dark brown primary color
        scaffoldBackgroundColor: Colors.brown,
        // Light brown background
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.brown[900]),
          // Dark brown body text
          bodyMedium: TextStyle(color: Colors.brown[900]),
          // Dark brown body text
          headlineMedium: TextStyle(
            color: Colors.brown[700], // Dark brown headline color
            fontWeight: FontWeight.bold,
          ),
          // ... other text styles ...
        ),
        colorScheme: ColorScheme.light(
          primary: Colors.brown[700]!, // Dark brown primary color
          secondary: Colors.orange[400]!, // Orange secondary color
          onPrimary: Colors.white, // White text on primary color
          onSecondary:
              const Color(0xFF3E2723), // Dark brown text on secondary color
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown[700], // Dark brown button color
            foregroundColor: Colors.white, // White text on button
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        // ... other theme properties ...
      ),
      initialRoute: Routes.login,
      // Set the initial route to the login screen
      routes: {
        Routes.login: (context) => const LoginScreen(),
        Routes.home: (context) => HomeScreen(),
        // ... other routes ...
      },
    );
  }
}
