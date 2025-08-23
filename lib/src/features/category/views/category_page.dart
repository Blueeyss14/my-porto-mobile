import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/category/viewmodels/category_viewmodel.dart';
import 'package:my_portfolio/src/shared/components/appbar_custom.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryC = Get.find<CategoryViewmodel>();

    String capitalizeEachWord(String text) {
      return text
          .split(' ')
          .map((word) {
            if (word.isEmpty) return word;
            return word[0].toUpperCase() + word.substring(1);
          })
          .join(' ');
    }

    void showAddDialog() {
      final TextEditingController nameController = TextEditingController();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Add Category'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String name = capitalizeEachWord(nameController.text.trim());
                if (name.isNotEmpty) {
                  await categoryC.createCategory(name);
                  Get.back();
                } else {
                  Get.snackbar(
                    'Error',
                    'Name cannot be empty',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    void showDeleteDialog(int index) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Category'),
          content: const Text('Are you sure you want to delete this Category?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                categoryC.deleteData(categoryC.categoryData[index].id);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: const AppbarCustom(title: 'Category Page'),

      body: RefreshIndicator(
        onRefresh: () async {
          await Get.find<CategoryViewmodel>().fetchCategories();
        },
        child: Obx(
          () => ListView.builder(
            itemCount: categoryC.categoryData.length,
            itemBuilder: (context, index) => Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        categoryC.categoryData[index].name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => showDeleteDialog(index),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
