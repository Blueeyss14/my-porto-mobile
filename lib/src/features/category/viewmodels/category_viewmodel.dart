import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_portfolio/src/features/category/models/category_models.dart';

class CategoryViewmodel extends GetxController {
  var categoryData = <CategoryModels>[].obs;

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  Map<String, String> headers = {
    'Authorization': dotenv.env['API_KEY'] ?? '',
    'Content-Type': 'application/json',
  };

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/categories'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body)['data'];
        categoryData.value = result
            .map<CategoryModels>(
              (category) =>
                  CategoryModels.fromJson(category as Map<String, dynamic>),
            )
            .toList();
        categoryData.sort((a, b) => a.id.compareTo(b.id));
        Get.snackbar(
          'Success',
          'Category loaded successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch messages: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Fetch exception: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> createCategory(String name) async {
    if (categoryData.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      Get.snackbar(
        'Error',
        'Category already exists',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['BASE_URL']}/categories/'),
        headers: headers,
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        final newCategory = CategoryModels.fromJson(result);
        categoryData.add(newCategory);

        Get.snackbar(
          'Success',
          'Category created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (response.statusCode == 409) {
        Get.snackbar(
          'Error',
          'Category already exists',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to create category: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Create exception: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteData(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${dotenv.env['BASE_URL']}/categories/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        categoryData.removeWhere((item) => item.id == id);
        Get.snackbar(
          'Success',
          'Message deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Delete exception: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
