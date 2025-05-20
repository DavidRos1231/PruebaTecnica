import 'package:flutter/material.dart';
import 'capacidad_demanda_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capacidad Demanda Manager',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          margin: EdgeInsets.all(8),
        ),
      ),
      home: CapacidadDemandaScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}