import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/project/models/project_model.dart';
import 'package:my_portfolio/src/features/project/viewmodels/project_viewmodel.dart';

class ImagesWidget extends StatelessWidget {
  const ImagesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectModel project = Get.arguments;
    final projectC = Get.find<ProjectViewmodel>();

    void showEditImageDialog(int imgIndex) {
      final currentProject = projectC.projectData.firstWhereOrNull(
        (p) => p.id == project.id,
      );
      if (currentProject == null) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Edit Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text('Current: ${currentProject.imageUrl[imgIndex]}')],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.media,
                );
                if (result != null && result.files.single.path != null) {
                  List<PlatformFile> updatedImages = [];

                  for (int i = 0; i < currentProject.imageUrl.length; i++) {
                    if (i == imgIndex) {
                      updatedImages.add(result.files.single);
                    } else {
                      updatedImages.add(
                        PlatformFile(name: currentProject.imageUrl[i], size: 0),
                      );
                    }
                  }

                  await projectC.patchProject(
                    id: project.id,
                    imageFiles: updatedImages,
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

    void showAddTagDialog() {}

    void showDeleteTagDialog(int tagIndex) {}

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
              Text('Images:', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                onPressed: () => showAddTagDialog(),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (currentProject.imageUrl.isEmpty)
            const Text('No Image')
          else
            ...List.generate(
              currentProject.imageUrl.length,
              (index) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          currentProject.imageUrl[index],
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => showEditImageDialog(index),
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
