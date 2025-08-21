import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/project/models/project_model.dart';
import 'package:my_portfolio/src/features/project/viewmodels/project_viewmodel.dart';

class ContributingWidget extends StatelessWidget {
  const ContributingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectModel project = Get.arguments;
    final projectC = Get.find<ProjectViewmodel>();

    void showEditContributingDialog(int index) {
      final currentProject = projectC.projectData.firstWhereOrNull(
        (p) => p.id == project.id,
      );
      if (currentProject == null) return;

      final nameController = TextEditingController(
        text: currentProject.contributing[index].name,
      );
      final linkController = TextEditingController(
        text: currentProject.contributing[index].link,
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Edit Contributing'),
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
                  final updatedContributing = List<Contributor>.from(
                    currentProject.contributing,
                  );
                  updatedContributing[index] = Contributor(
                    name: nameController.text,
                    link: linkController.text,
                  );

                  await projectC.patchProject(
                    id: project.id,
                    contributing: updatedContributing
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

    void showAddContributingDialog() {
      final nameController = TextEditingController();
      final linkController = TextEditingController();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Add Contributing'),
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

                  final updatedContributing = List<Contributor>.from(
                    currentProject.contributing,
                  );
                  updatedContributing.add(
                    Contributor(
                      name: nameController.text,
                      link: linkController.text,
                    ),
                  );

                  await projectC.patchProject(
                    id: project.id,
                    contributing: updatedContributing
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

    void showDeleteContributingDialog(int index) {
      final currentProject = projectC.projectData.firstWhereOrNull(
        (p) => p.id == project.id,
      );
      if (currentProject == null) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Contributing'),
          content: Text(
            'Are you sure you want to delete "${currentProject.contributing[index].name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedContributing = List<Contributor>.from(
                  currentProject.contributing,
                );
                updatedContributing.removeAt(index);

                await projectC.patchProject(
                  id: project.id,
                  contributing: updatedContributing
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
              Text(
                'Contributing:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () => showAddContributingDialog(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (currentProject.contributing.isEmpty)
            const Text('No Contributing')
          else
            ...List.generate(
              currentProject.contributing.length,
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
                              'Name: ${currentProject.contributing[index].name}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Link: ${currentProject.contributing[index].link}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => showEditContributingDialog(index),
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit Contributing',
                      ),
                      IconButton(
                        onPressed: () => showDeleteContributingDialog(index),
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete Contributing',
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
