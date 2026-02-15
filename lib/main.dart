import 'package:flutter/material.dart';
import 'features/auth/presentation/pages/home_page.dart'; // путь к файлу с маленькими буквами

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bazar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  HomePage(), // стартовый экран без авторизации
    );
  }
}


