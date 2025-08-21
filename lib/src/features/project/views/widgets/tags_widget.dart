import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/project/models/project_model.dart';
import 'package:my_portfolio/src/features/project/viewmodels/project_viewmodel.dart';

class TagsWidget extends StatelessWidget {
  const TagsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectModel project = Get.arguments;
    final projectC = Get.find<ProjectViewmodel>();

    void showEditTagsDialog(int tagIndex) {
      ///pake dart aseli (work)
      // final currentProject = projectC.projectData.firstWhere(
      //   (p) => p.id == project.id,
      // );

      final currentProject = projectC.projectData.firstWhereOrNull(
        (p) => p.id == project.id,
      );
      if (currentProject == null) return;

      final tagController = TextEditingController(
        text: currentProject.tags[tagIndex],
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Edit Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tagController,
                decoration: const InputDecoration(labelText: 'Tag Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                List<String> updatedTags = List<String>.from(project.tags);
                updatedTags[tagIndex] = tagController.text.trim();

                await projectC.patchProject(id: project.id, tags: updatedTags);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    void showAddTagDialog() {
      final tagController = TextEditingController();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Add New Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tagController,
                decoration: const InputDecoration(labelText: 'Tag Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (tagController.text.trim().isNotEmpty) {
                  final currentProject = projectC.projectData.firstWhereOrNull(
                    (p) => p.id == project.id,
                  );
                  if (currentProject == null) return;

                  List<String> updatedTags = List<String>.from(
                    currentProject.tags,
                  );
                  updatedTags.add(tagController.text.trim());

                  await projectC.patchProject(
                    id: project.id,
                    tags: updatedTags,
                  );
                }

                Get.back();
              },

              child: const Text('Add'),
            ),
          ],
        ),
      );
    }

    void showDeleteTagDialog(int tagIndex) {
      final currentProject = projectC.projectData.firstWhereOrNull(
        (p) => p.id == project.id,
      );
      if (currentProject == null) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Tag'),
          content: Text(
            'Are you sure you want to delete "${currentProject.tags[tagIndex]}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                List<String> updatedTags = List<String>.from(
                  currentProject.tags,
                );
                updatedTags.removeAt(tagIndex);

                await projectC.patchProject(id: project.id, tags: updatedTags);

                Get.back();
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
              Text('Tags:', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                onPressed: () => showAddTagDialog(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (currentProject.tags.isEmpty)
            const Text('No tags available')
          else
            ...List.generate(
              currentProject.tags.length,
              (index) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          currentProject.tags[index],
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => showEditTagsDialog(index),
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit Tag',
                      ),
                      IconButton(
                        onPressed: () => showDeleteTagDialog(index),
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete Tag',
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
