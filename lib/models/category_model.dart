import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String id;
  String name;
  String icon;
  String color;
  String type; // 'expense' or 'income'

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
        id: map['id'],
        name: map['name'],
        icon: map['icon'],
        color: map['color'],
        type: map['type']);
  }

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'],
      icon: data['icon'],
      color: data['color'],
      type: data['type'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type,
    };
  }

  static List<Category> defaultCategories = [
    Category(
      id: '',
      name: 'Health',
      icon: 'favorite',
      color: '#F23535', // Rosa fuerte
      type: 'expense',
    ),
    Category(
      id: '',
      name: 'Leisure',
      icon: 'account_balance_wallet',
      color: '#6DA644', // Verde
      type: 'expense',
    ),
    Category(
      id: '',
      name: 'Home',
      icon: 'home',
      color: '#2196F3', // Azul
      type: 'expense',
    ),
    Category(
      id: '',
      name: 'Cafe',
      icon: 'restaurant',
      color: '#F2B807', // Amarillo
      type: 'expense',
    ),
    Category(
      id: '',
      name: 'Education',
      icon: 'school',
      color: '#D94E8F', // Morado
      type: 'expense',
    ),
    Category(
      id: '',
      name: 'Groceries',
      icon: 'shopping_cart',
      color: '#00BCD4', // Celeste
      type: 'expense',
    ),
    Category(
      id: '',
      name: 'Family',
      icon: 'family_restroom',
      color: '#FF5722', // Naranja rojizo
      type: 'expense',
    ),
    Category(
      id: '',
      name: 'Workout',
      icon: 'fitness_center',
      color: '#8BC34A', // Verde claro
      type: 'expense',
    ),
    Category(
      id: '',
      name: 'Transportation',
      icon: 'directions_bus',
      color: '#3F51B5', // Azul índigo
      type: 'expense',
    ),
    Category(
      id: '',
      name: 'Other',
      icon: 'help',
      color: '#607D8B', // Azul grisáceo
      type: 'expense',
    ),
    Category(
      id: '',
      name: 'Sport',
      icon: 'sports_soccer',
      color: '#CDDC39', // Lima
      type: 'expense',
    ),
    Category(
      id: '',
      name: 'Bike',
      icon: 'directions_bike',
      color: '#FF9800', // Naranja
      type: 'expense',
    ),
    Category(
      id: '',
      name: 'Comida afuera',
      icon: 'fastfood',
      color: '#795548', // Marrón
      type: 'expense',
    ),
    Category(
      id: '',
      name: 'Streaming',
      icon: 'videogame_asset',
      color: '#673AB7', // Morado oscuro
      type: 'expense',
    ),
    Category(
      id: '',
      name: 'Debt',
      icon: 'trending_up',
      color: '#F44336', // Rojo
      type: 'expense',
    ),
    // Categorías de ingresos
    Category(
      id: '',
      name: 'Salary',
      icon: 'attach_money',
      color: '#4CAF50', // Verde
      type: 'income',
    ),
    Category(
      id: '',
      name: 'Freelance',
      icon: 'work',
      color: '#FF9800', // Naranja
      type: 'income',
    ),
    Category(
      id: '',
      name: 'Investments',
      icon: 'trending_up',
      color: '#2196F3', // Azul
      type: 'income',
    ),
    Category(
      id: '',
      name: 'Gifts',
      icon: 'card_giftcard',
      color: '#E91E63', // Rosa
      type: 'income',
    ),
    Category(
      id: '',
      name: 'Rental Income',
      icon: 'home',
      color: '#9C27B0', // Morado
      type: 'income',
    ),
    Category(
      id: '',
      name: 'Other',
      icon: 'help',
      color: '#607D8B', // Azul grisáceo
      type: 'income',
    ),
  ];
}
