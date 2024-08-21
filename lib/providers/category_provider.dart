import 'package:flutter/material.dart';
import 'package:pennywise/models/category_model.dart';
import 'package:pennywise/providers/loading_provider.dart';
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

  //get category by id
  Future<Category> getCategoryById(String categoryId) async {
    try {
      _loadingProvider.setLoading(true);
      //get by repository
      return await _categoryRepository.getCategoryById(categoryId);
    } catch (e) {
      print('Error getting category by id: $e');
      throw e;
    } finally {
      _loadingProvider.setLoading(false);
    }
  }
}
