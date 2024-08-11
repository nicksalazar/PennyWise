import 'package:flutter/material.dart';
import 'package:habit_harmony/models/category_model.dart';
import 'package:habit_harmony/providers/loading_provider.dart';
import '../repositories/category_repository.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final LoadingProvider _loadingProvider;
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  CategoryProvider(this._loadingProvider) {
    _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    try {
      _loadingProvider.setLoading(true);
      await _categoryRepository.initializeDefaultCategories();
      _categories = await _categoryRepository.getCategories();
      notifyListeners();
    } catch (e) {
      print('Error initializing categories: $e');
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      _loadingProvider.setLoading(true);
      await _categoryRepository.addCategory(category);
      _categories = await _categoryRepository.getCategories();
      notifyListeners();
    } catch (e) {
      print('Error adding category: $e');
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      _loadingProvider.setLoading(true);
      await _categoryRepository.deleteCategory(categoryId);
      _categories = await _categoryRepository.getCategories();
      notifyListeners();
    } catch (e) {
      print('Error deleting category: $e');
    } finally {
      _loadingProvider.setLoading(false);
    }
  }
}
