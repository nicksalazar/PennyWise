import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_harmony/models/account_model.dart';

class AccountsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference _getAccountCollection() {
    String userId = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(userId).collection('accounts');
  }

  Future<Account> insertAccount(Account account) async {
    DocumentReference docRef =
        await _getAccountCollection().add(account.toMap());
    return account.copyWith(id: docRef.id);
  }

  Future<void> deleteAccount(String id) async {
    print("deleta acount id: $id");
    await _getAccountCollection().doc(id).delete();
  }

  Future<List<Account>> getAccounts() async {
    QuerySnapshot snapshot = await _getAccountCollection().get();
    return snapshot.docs.map((doc) => Account.fromFirestore(doc)).toList();
  }

  Future<Account> updateAccount(Account account) async {
    await _getAccountCollection().doc(account.id).update(account.toMap());
    return account;
  }

  Future<void> updateBalance(String accountId, double amount) {
    return _getAccountCollection().doc(accountId).update({
      'balance': FieldValue.increment(amount),
    });
  }
}
