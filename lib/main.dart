import 'package:flutter/material.dart';
import 'screens/lista_productos.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario Tienda',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const ListaProductosPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Charles Sleiter Valiente Farias - Flutter Inventario App