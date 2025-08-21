import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/project/models/project_model.dart';
import 'package:my_portfolio/src/features/project/viewmodels/project_viewmodel.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectModel project = Get.arguments;
    final projectC = Get.find<ProjectViewmodel>();

    void showEditTitleDialog() {
      final currentProject = projectC.projectData.firstWhereOrNull(
        (p) => p.id == project.id,
      );
      if (currentProject == null) return;

      final titleController = TextEditingController(text: currentProject.title);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Edit Title'),
          content: TextField(
            maxLines: null,
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await projectC.patchProject(
                  id: project.id,
                  title: titleController.text,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    void showDeleteTitleDialog() {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Title'),
          content: const Text('Are you sure you want to delete this title?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final currentProject = projectC.projectData.firstWhereOrNull(
                  (p) => p.id == project.id,
                );
                if (currentProject == null) return;

                await projectC.patchProject(id: project.id, title: '');

                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }

    return Obx(() {
      final currentProject = projectC.projectData.firstWhereOrNull(
        (p) => p.id == project.id,
      );
      if (currentProject == null) {
        return const Center(child: Text('Project not found'));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Title:', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      currentProject.title.isEmpty
                          ? 'No title'
                          : currentProject.title,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: showEditTitleDialog,
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: showDeleteTitleDialog,
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }
}
