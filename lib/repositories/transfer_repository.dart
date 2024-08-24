import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pennywise/models/transfer_model.dart';
import 'package:pennywise/models/account_model.dart';

class TransferRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TransferRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _getTransferCollection() {
    String userId = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(userId).collection('transfers');
  }

  CollectionReference _getAccountCollection() {
    String userId = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(userId).collection('accounts');
  }

  //funtion initial balance
  Future<void> createTransferInitital(TransferModel transfer) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference destAccountRef =
            _getAccountCollection().doc(transfer.destinationAccountId);

        DocumentSnapshot destAccountDoc = await transaction.get(destAccountRef);

        if (!destAccountDoc.exists) {
          throw Exception('Account does not exist');
        }

        // Convert to Account object
        Account destAccount = Account.fromFirestore(destAccountDoc);

        // Update balance
        destAccount.balance = transfer.amount;

        // Update the account in Firestore
        transaction.update(destAccountRef, destAccount.toFirestore());

        // Create the transfer document
        DocumentReference transferRef = _getTransferCollection().doc();
        transaction.set(transferRef, transfer.toFirestore());
      });
    } catch (e) {
      print('Error creating transfer: $e');
      throw e;
    }
  }

  Future<void> createTransfer(TransferModel transfer) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference sourceAccountRef =
            _getAccountCollection().doc(transfer.sourceAccountId);
        DocumentReference destAccountRef =
            _getAccountCollection().doc(transfer.destinationAccountId);

        DocumentSnapshot sourceAccountDoc =
            await transaction.get(sourceAccountRef);
        DocumentSnapshot destAccountDoc = await transaction.get(destAccountRef);

        if (!sourceAccountDoc.exists || !destAccountDoc.exists) {
          throw Exception('One or both accounts do not exist');
        }

        // Convert to Account objects
        Account sourceAccount = Account.fromFirestore(sourceAccountDoc);
        Account destAccount = Account.fromFirestore(destAccountDoc);

        // Check if source account has sufficient balance
        if (sourceAccount.balance < transfer.amount ||
            transfer.amount <= 0 ||
            transfer.sourceAccountId == transfer.destinationAccountId) {
          throw Exception('Insufficient balance in source account');
        }

        // Update balances
        sourceAccount.balance -= transfer.amount;
        destAccount.balance += transfer.amount;

        // Update the accounts in Firestore
        transaction.update(sourceAccountRef, sourceAccount.toFirestore());
        transaction.update(destAccountRef, destAccount.toFirestore());

        // Create the transfer document
        DocumentReference transferRef = _getTransferCollection().doc();
        transaction.set(transferRef, transfer.toFirestore());
      });
    } catch (e) {
      print('Error creating transfer: $e');
      throw e;
    }
  }

  Future<void> adjustBalance(String accountId, double amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Get the account document
        DocumentReference accountRef = _getAccountCollection().doc(accountId);
        DocumentSnapshot accountDoc = await transaction.get(accountRef);

        if (!accountDoc.exists) {
          throw Exception('Account does not exist');
        }

        // Convert to Account object
        Account account = Account.fromFirestore(accountDoc);

        // Update balance
        account.balance += amount;
        print("cuanto es el balance ${account.balance}");
        if (account.balance < 0) {
          throw Exception('Resulting balance cannot be negative');
        }

        // Update the account in Firestore
        transaction.update(accountRef, account.toFirestore());

        // Create the balance adjustment document
        DocumentReference adjustmentRef = _getTransferCollection().doc();
        TransferModel adjustment = TransferModel(
          id: adjustmentRef.id,
          sourceAccountId: accountId,
          destinationAccountId: '', // No destination for balance adjustment
          amount: amount,
          date: DateTime.now(),
          comment: 'Balance adjustment',
          type: 'adjustment',
        );
        transaction.set(adjustmentRef, adjustment.toFirestore());
      });
    } catch (e) {
      print('Error adjusting balance: $e');
      throw e;
    }
  }

  Future<List<TransferModel>> getTransfersByDateRange(
      DateTime start, DateTime end) {
    return _getTransferCollection()
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .orderBy('date', descending: true)
        .get()
        .then((snapshot) {
      return snapshot.docs
          .map((doc) => TransferModel.fromFirestore(doc))
          .toList();
    });
  }
}
