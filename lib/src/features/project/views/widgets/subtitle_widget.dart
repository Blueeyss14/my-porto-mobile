import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/project/models/project_model.dart';
import 'package:my_portfolio/src/features/project/viewmodels/project_viewmodel.dart';

class SubtitleWidget extends StatelessWidget {
  const SubtitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectModel project = Get.arguments;
    final projectC = Get.find<ProjectViewmodel>();

    void showEdiSubtitleDialog() {
      final currentProject = projectC.projectData.firstWhereOrNull(
        (p) => p.id == project.id,
      );
      if (currentProject == null) return;

      final subtitleController = TextEditingController(
        text: currentProject.subtitle,
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Edit Subtitle'),
          content: TextField(
            maxLines: null,
            controller: subtitleController,
            decoration: const InputDecoration(labelText: 'Subtitle'),
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
                  subtitle: subtitleController.text,
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

    void showDeleteSubtitleDialog() {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Subtitle'),
          content: const Text('Are you sure you want to delete this subtitle?'),
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

                await projectC.patchProject(id: project.id, subtitle: '');

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
              Text('Subtitle:', style: Theme.of(context).textTheme.titleLarge),
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
                      currentProject.subtitle.isEmpty
                          ? 'No subtitle'
                          : currentProject.subtitle,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: showEdiSubtitleDialog,
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: showDeleteSubtitleDialog,
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
