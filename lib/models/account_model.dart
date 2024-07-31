import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  final String id;
  final String name;
  final String icon;
  double balance;
  final String color;

  Account({
    required this.id,
    required this.name,
    required this.icon,
    required this.balance,
    required this.color,
  });

  factory Account.fromDocument(DocumentSnapshot doc) {
    return Account(
      id: doc.id,
      name: doc['name'],
      icon: doc['icon'],
      balance: doc['balance'],
      color: doc['color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'balance': balance,
      'color': color,
    };
  }

  Future<Account> copyWith({required String id}) {
    return Future.value(Account(
      id: id,
      name: name,
      icon: icon,
      balance: balance,
      color: color,
    ));
  }

  //tofirestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'balance': balance,
      'color': color,
    };
  }

  factory Account.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Account(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      balance: (data['balance'] ?? 0).toDouble(),
      color: data['color'] ?? '',
    );
  }
}
