import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/project/viewmodels/project_viewmodel.dart';
import 'package:my_portfolio/src/routes/routes_name.dart';
import 'package:my_portfolio/src/shared/components/appbar_custom.dart';

class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final projectC = Get.find<ProjectViewmodel>();

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
                projectC.deleteData(projectC.projectData[index].id);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: const AppbarCustom(title: 'Projects'),

      body: Obx(
        () => ListView.builder(
          itemCount: projectC.projectData.length,
          itemBuilder: (context, index) => GestureDetector(
            onTap: () => Get.toNamed(
              RoutesName.projectDetail,
              arguments: projectC.projectData[index],
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        projectC.projectData[index].title,
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
    );
  }
}
