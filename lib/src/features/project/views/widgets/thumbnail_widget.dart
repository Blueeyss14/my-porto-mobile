import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/project/models/project_model.dart';
import 'package:my_portfolio/src/features/project/viewmodels/project_viewmodel.dart';

class ThumbnailWidget extends StatelessWidget {
  const ThumbnailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectModel project = Get.arguments;
    final projectC = Get.find<ProjectViewmodel>();

    void showEditThumbnailDialog() {
      final currentProject = projectC.projectData.firstWhereOrNull(
        (p) => p.id == project.id,
      );
      if (currentProject == null) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Edit Thumbnail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text('Current: ${currentProject.thumbnail}')],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final pickedFile = await projectC.pickSingleImage();
                if (pickedFile != null) {
                  await projectC.patchProject(
                    id: project.id,
                    thumbnail: pickedFile,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Text('Pick New File'),
            ),
          ],
        ),
      );
    }

    void showAddThumbnailDialog() async {
      final pickedFile = await projectC.pickSingleImage();
      if (pickedFile != null) {
        await projectC.patchProject(id: project.id, thumbnail: pickedFile);
      }
    }

    void showDeleteThumbnailDialog() {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Thumbnail'),
          content: const Text(
            'Are you sure you want to delete this thumbnail?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await projectC.patchProject(id: project.id, thumbnail: null);
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
              Text('Thumbnail:', style: Theme.of(context).textTheme.titleLarge),
              if (currentProject.thumbnail.isEmpty)
                IconButton(
                  onPressed: () => showAddThumbnailDialog(),
                  icon: const Icon(Icons.add),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (currentProject.thumbnail.isEmpty)
            const Text('No Thumbnail')
          else
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        currentProject.thumbnail,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => showEditThumbnailDialog(),
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit Thumbnail',
                    ),
                    IconButton(
                      onPressed: () => showDeleteThumbnailDialog(),
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete Thumbnail',
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}
