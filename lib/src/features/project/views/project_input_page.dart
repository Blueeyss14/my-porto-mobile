import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/project/viewmodels/project_viewmodel.dart';
import 'package:my_portfolio/src/shared/components/appbar_custom.dart';

class ProjectInputPage extends StatelessWidget {
  const ProjectInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    final projectC = Get.find<ProjectViewmodel>();

    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final tagController = TextEditingController();
    final contributorNameController = TextEditingController();
    final contributorLinkController = TextEditingController();
    final resourceNameController = TextEditingController();
    final resourceLinkController = TextEditingController();

    bool isPinned = false;
    PlatformFile? thumbnail;
    List<PlatformFile> imageFiles = [];
    List<String> tags = [];
    List<Map<String, String>> contributing = [];
    List<Map<String, String>> resources = [];
    return Scaffold(
      appBar: const AppbarCustom(title: 'Project Input'),

      body: StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final file = await projectC.pickSingleImage();
                      if (file != null) {
                        setState(() {
                          thumbnail = file;
                        });
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: Text(
                      thumbnail == null
                          ? 'Select Thumbnail'
                          : 'Thumbnail: ${thumbnail!.name}',
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: subtitleController,
                  decoration: const InputDecoration(
                    labelText: 'Subtitle *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pin this project:'),
                    Checkbox(
                      value: isPinned,
                      onChanged: (val) {
                        setState(() => isPinned = val ?? false);
                      },
                    ),
                  ],
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final files = await projectC.pickMultipleImages();
                      if (files != null) {
                        setState(() {
                          imageFiles = files;
                        });
                      }
                    },
                    icon: const Icon(Icons.photo_library),
                    label: Text('Images Selected: ${imageFiles.length}'),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tags:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tagController,
                        decoration: const InputDecoration(
                          labelText: 'Add Tag',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (tagController.text.isNotEmpty) {
                          setState(() {
                            tags.add(tagController.text);
                            tagController.clear();
                          });
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      onDeleted: () {
                        setState(() {
                          tags.remove(tag);
                        });
                      },
                    );
                  }).toList(),
                ),
                const Text(
                  'Contributors:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: contributorNameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: contributorLinkController,
                        decoration: const InputDecoration(
                          labelText: 'Link',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (contributorNameController.text.isNotEmpty &&
                            contributorLinkController.text.isNotEmpty) {
                          setState(() {
                            contributing.add({
                              'name': contributorNameController.text,
                              'link': contributorLinkController.text,
                            });
                            contributorNameController.clear();
                            contributorLinkController.clear();
                          });
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...contributing.map((contributor) {
                  return Card(
                    child: ListTile(
                      dense: true,
                      title: Text(contributor['name'] ?? ''),
                      subtitle: Text(contributor['link'] ?? ''),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            contributing.remove(contributor);
                          });
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                  );
                }),
                const Text(
                  'Resources:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: resourceNameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: resourceLinkController,
                        decoration: const InputDecoration(
                          labelText: 'Link',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (resourceNameController.text.isNotEmpty &&
                            resourceLinkController.text.isNotEmpty) {
                          setState(() {
                            resources.add({
                              'name': resourceNameController.text,
                              'link': resourceLinkController.text,
                            });
                            resourceNameController.clear();
                            resourceLinkController.clear();
                          });
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...resources.map((resource) {
                  return Card(
                    child: ListTile(
                      dense: true,
                      title: Text(resource['name'] ?? ''),
                      subtitle: Text(resource['link'] ?? ''),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            resources.remove(resource);
                          });
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: projectC.isLoading.value
                          ? null
                          : () async {
                              final title = titleController.text.trim();
                              final subtitle = subtitleController.text.trim();
                              final description = descriptionController.text
                                  .trim();
                              final category = categoryController.text.trim();

                              if (title.isEmpty ||
                                  subtitle.isEmpty ||
                                  description.isEmpty ||
                                  category.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Title, Subtitle, Description, and Category are required',
                                );
                                return;
                              }

                              await projectC.addProject(
                                title: title,
                                subtitle: subtitle,
                                description: description,
                                category: category,
                                isPinned: isPinned,
                                thumbnail: thumbnail,
                                imageFiles: imageFiles.isNotEmpty
                                    ? imageFiles
                                    : null,
                                tags: tags.isNotEmpty ? tags : null,
                                contributing: contributing.isNotEmpty
                                    ? contributing
                                    : null,
                                resources: resources.isNotEmpty
                                    ? resources
                                    : null,
                              );
                            },
                      child: projectC.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
