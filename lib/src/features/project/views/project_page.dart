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
          title: const Text('Delete Project'),
          content: const Text('Are you sure you want to delete this project?'),
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
        () => projectC.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  projectC.projectData[index].title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (projectC
                                    .projectData[index]
                                    .subtitle
                                    .isNotEmpty)
                                  Text(
                                    projectC.projectData[index].subtitle,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                Text(
                                  'Category: ${projectC.projectData[index].category}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (projectC.projectData[index].isPinned)
                            const Icon(Icons.push_pin, size: 16),
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
        onPressed: () => Get.toNamed(RoutesName.projectInputPage),
        child: const Icon(Icons.add),
      ),
    );
  }
}
