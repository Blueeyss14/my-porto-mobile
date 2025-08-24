import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/project/models/project_model.dart';
import 'package:my_portfolio/src/features/project/viewmodels/project_viewmodel.dart';

class ImagesWidget extends StatelessWidget {
  const ImagesWidget({super.key});

  Future<PlatformFile?> _pickSingleImageWithBytes() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.bytes == null && file.path != null && !kIsWeb) {
          try {
            final fileBytes = await File(file.path!).readAsBytes();
            return PlatformFile(
              name: file.name,
              size: file.size,
              bytes: fileBytes,
              path: file.path,
            );
          } catch (e) {
            Get.snackbar('Error', 'Could not read file: $e');
            return null;
          }
        }

        if (file.bytes == null || file.bytes!.isEmpty) {
          Get.snackbar('Error', 'Could not read file data');
          return null;
        }

        return file;
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Error picking image: $e');
      return null;
    }
  }

  Future<List<PlatformFile>?> _pickMultipleImagesWithBytes() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        List<PlatformFile> validFiles = [];

        for (final file in result.files) {
          PlatformFile? processedFile;

          if (file.bytes == null && file.path != null && !kIsWeb) {
            try {
              final fileBytes = await File(file.path!).readAsBytes();
              processedFile = PlatformFile(
                name: file.name,
                size: file.size,
                bytes: fileBytes,
                path: file.path,
              );
            } catch (e) {
              print('Could not read file ${file.name}: $e');
              continue;
            }
          } else {
            processedFile = file;
          }

          if (processedFile.bytes != null && processedFile.bytes!.isNotEmpty) {
            validFiles.add(processedFile);
          }
        }

        if (validFiles.isEmpty) {
          Get.snackbar('Error', 'Could not read any file data');
          return null;
        }

        return validFiles;
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Error picking images: $e');
      return null;
    }
  }

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
                final pickedFile = await _pickSingleImageWithBytes();
                if (pickedFile != null) {
                  await projectC.patchProject(
                    id: project.id,
                    imageFiles: [pickedFile],
                    imageIndex: imgIndex,
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

    void showAddImageDialog() async {
      final pickedFiles = await _pickMultipleImagesWithBytes();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        final currentProject = projectC.projectData.firstWhereOrNull(
          (p) => p.id == project.id,
        );
        if (currentProject == null) return;

        await projectC.patchProject(
          id: project.id,
          imageFiles: pickedFiles,
          addImages: true,
        );
      }
    }

    void showDeleteImageDialog(int imgIndex) {
      final currentProject = projectC.projectData.firstWhereOrNull(
        (p) => p.id == project.id,
      );
      if (currentProject == null) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Image'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await projectC.patchProject(
                  id: project.id,
                  deleteIndex: imgIndex,
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
              Text('Images:', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                onPressed: () => showAddImageDialog(),
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
                        tooltip: 'Edit Image',
                      ),
                      IconButton(
                        onPressed: () => showDeleteImageDialog(index),
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete Image',
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
