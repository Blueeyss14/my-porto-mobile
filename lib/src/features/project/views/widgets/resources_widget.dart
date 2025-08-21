import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/project/models/project_model.dart';
import 'package:my_portfolio/src/features/project/viewmodels/project_viewmodel.dart';

class ResourcesWidget extends StatelessWidget {
  const ResourcesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectModel project = Get.arguments;
    final projectC = Get.find<ProjectViewmodel>();

    void showEditResourcesDialog(int index) {
      final currentProject = projectC.projectData.firstWhereOrNull(
        (p) => p.id == project.id,
      );
      if (currentProject == null) return;

      final nameController = TextEditingController(
        text: currentProject.resources[index].name,
      );
      final linkController = TextEditingController(
        text: currentProject.resources[index].link,
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Edit Resources'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  labelText: 'Link',
                  border: OutlineInputBorder(),
                ),
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
                if (nameController.text.isNotEmpty &&
                    linkController.text.isNotEmpty) {
                  final updatedResources = List<Resource>.from(
                    currentProject.resources,
                  );
                  updatedResources[index] = Resource(
                    name: nameController.text,
                    link: linkController.text,
                  );

                  await projectC.patchProject(
                    id: project.id,
                    resources: updatedResources
                        .map((c) => {'name': c.name, 'link': c.link})
                        .toList(),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      );
    }

    void showAddResourcesDialog() {
      final nameController = TextEditingController();
      final linkController = TextEditingController();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Add Resources'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  labelText: 'Link',
                  border: OutlineInputBorder(),
                ),
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
                if (nameController.text.isNotEmpty &&
                    linkController.text.isNotEmpty) {
                  final currentProject = projectC.projectData.firstWhereOrNull(
                    (p) => p.id == project.id,
                  );
                  if (currentProject == null) return;

                  final updateResources = List<Resource>.from(
                    currentProject.resources,
                  );
                  updateResources.add(
                    Resource(
                      name: nameController.text,
                      link: linkController.text,
                    ),
                  );

                  await projectC.patchProject(
                    id: project.id,
                    resources: updateResources
                        .map((c) => {'name': c.name, 'link': c.link})
                        .toList(),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    }

    void showDeleteResourcesDialog(int index) {
      final currentProject = projectC.projectData.firstWhereOrNull(
        (p) => p.id == project.id,
      );
      if (currentProject == null) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Resources'),
          content: Text(
            'Are you sure you want to delete "${currentProject.resources[index].name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedResources = List<Resource>.from(
                  currentProject.resources,
                );
                updatedResources.removeAt(index);

                await projectC.patchProject(
                  id: project.id,
                  resources: updatedResources
                      .map((c) => {'name': c.name, 'link': c.link})
                      .toList(),
                );
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
              Text('Resources:', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                onPressed: () => showAddResourcesDialog(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (currentProject.resources.isEmpty)
            const Text('No Resources')
          else
            ...List.generate(
              currentProject.resources.length,
              (index) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${currentProject.resources[index].name}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Link: ${currentProject.resources[index].link}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => showEditResourcesDialog(index),
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit Resources',
                      ),
                      IconButton(
                        onPressed: () => showDeleteResourcesDialog(index),
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete Resources',
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
