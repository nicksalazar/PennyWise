import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pennywise/models/account_model.dart';

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

  Future<void> updateBalance(
      String accountId, double amount, String transactionType) async {
    final account = await _getAccountCollection().doc(accountId).get();
    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot accountDoc = account;
      if (!accountDoc.exists) {
        throw Exception('Account does not exist');
      }
      Account destAccount = Account.fromFirestore(accountDoc);
      // Adjust the balance based on the transaction type
      if (transactionType == 'income') {
        destAccount.balance += amount;
      } else {
        destAccount.balance -= amount;
      }

      transaction.update(account.reference, destAccount.toMap());
    });
  }
}
