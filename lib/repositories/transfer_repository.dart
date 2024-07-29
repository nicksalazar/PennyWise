import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_harmony/models/transfer_model.dart';
import 'package:habit_harmony/models/account_model.dart';

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

  Future<void> createTransfer(TransferModel transfer) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Get the source and destination account documents
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
}
