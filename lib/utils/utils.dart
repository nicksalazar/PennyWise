import 'package:flutter/material.dart';

Border getCategoryColor(String categoria) {
  switch (categoria) {
    case "Alimentación":
      return Border.all(color: Colors.green, width: 2.0);
    case "Transporte":
      return Border.all(color: Colors.blue, width: 2.0);
    case "Deporte y Ocio":
      return Border.all(color: Colors.red, width: 2.0);
    case "Salud":
      return Border.all(color: Colors.purple, width: 2.0);
    case "Regalos y Donaciones":
      return Border.all(color: Colors.orange, width: 2.0);
    case "Ropa y Accesorios":
      return Border.all(color: Colors.pink, width: 2.0);
    case "Inversiones y Finanzas":
      return Border.all(color: Colors.yellow, width: 2.0);
    case "Entretenimiento":
      return Border.all(color: Colors.teal, width: 2.0);
    case "Tecnología y Herramientas de Trabajo":
      return Border.all(color: Colors.brown, width: 2.0);
    case "Freelancing y Negocio":
      return Border.all(color: Colors.indigo, width: 2.0);
    case "Educación y Desarrollo Personal":
      return Border.all(color: Colors.cyan, width: 2.0);
    case "Aseo y Limpieza":
      return Border.all(color: Colors.lime, width: 2.0);
    case "Ocio":
      return Border.all(color: Colors.amber, width: 2.0);
    case "Vivienda":
      return Border.all(color: Colors.orange, width: 2.0);
    case "Other":
      return Border.all(color: Colors.grey, width: 2.0);
    default:
      return Border.all(color: Colors.black, width: 2.0);
  }
}

Color getCategoryColorChart(String categoria) {
  print("categoria $categoria");
  switch (categoria) {
    case "Alimentación":
      return Colors.green;
    case "Transporte":
      return Colors.blue;
    case "Deporte y Ocio":
      return Colors.red;
    case "Salud":
      return Colors.purple;
    case "Vivienda":
      return Colors.orange;
    case "Ropa y Accesorios":
      return Colors.pink;
    case "Inversiones y Finanzas":
      return Colors.yellow;
    case "Entretenimiento":
      return Colors.teal;
    case "Tecnología y Herramientas de Trabajo":
      return Colors.brown;
    case "Freelancing y Negocio":
      return Colors.indigo;
    case "Educación y Desarrollo Personal":
      return Colors.cyan;
    case "Aseo y Limpieza":
      return Colors.lime;
    case "Ocio":
      return Colors.amber;
    case "Regalos y Donaciones":
      return Colors.orange;
    case "Other":
      return Colors.grey;
    default:
      return Colors.tealAccent;
  }
  
}


formatCurrency(double amount) {
  return "S/."  + amount.toStringAsFixed(2);
}