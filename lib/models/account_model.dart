import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  final String id;
  final String name;
  final String icon; // 'physical' or 'digital'
  final double balance;

  Account({
    required this.id,
    required this.name,
    required this.icon,
    required this.balance,
  });

  factory Account.fromDocument(DocumentSnapshot doc) {
    return Account(
      id: doc.id,
      name: doc['name'],
      icon: doc['icon'],
      balance: doc['balance'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'balance': balance,
    };
  }

  Future<Account> copyWith({required String id}) {
    return Future.value(Account(
      id: id,
      name: name,
      icon: icon,
      balance: balance,
    ));
  }

  factory Account.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Account(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      balance: (data['balance'] ?? 0).toDouble(),
    );
  }
}
