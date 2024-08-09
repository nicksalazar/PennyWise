import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_harmony/models/category_model.dart';

class CategoryRepository {
  CollectionReference _getCategoriesCollection() {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    String userId = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(userId).collection('categories');
  }

  Future<void> initializeDefaultCategories() async {
    CollectionReference userCategoriesCollection = _getCategoriesCollection();
    QuerySnapshot querySnapshot = await userCategoriesCollection.get();
    if (querySnapshot.docs.isEmpty) {
      for (Category category in Category.defaultCategories) {
        DocumentReference docRef = userCategoriesCollection.doc();
        category.id = docRef.id; // Asignar el ID generado por Firebase
        await docRef.set(category.toFirestore());
      }
    }
  }

  Future<List<Category>> getCategories() async {
    CollectionReference userCategoriesCollection = _getCategoriesCollection();
    QuerySnapshot querySnapshot = await userCategoriesCollection.get();
    return querySnapshot.docs
        .map((doc) => Category.fromFirestore(doc))
        .toList();
  }

  Future<void> addCategory(Category category) async {
    CollectionReference userCategoriesCollection = _getCategoriesCollection();
    if (category.id.isEmpty) {
      // Generar un nuevo ID si no se proporciona uno
      DocumentReference docRef = userCategoriesCollection.doc();
      category.id = docRef.id;
      await docRef.set(category.toFirestore());
    } else {
      // Usar el ID proporcionado
      await userCategoriesCollection
          .doc(category.id)
          .set(category.toFirestore());
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    CollectionReference userCategoriesCollection = _getCategoriesCollection();
    await userCategoriesCollection.doc(categoryId).delete();
  }
}
