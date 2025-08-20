import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/project/models/project_model.dart';
import 'package:my_portfolio/src/features/project/viewmodels/project_viewmodel.dart';
import 'package:my_portfolio/src/features/project/views/widgets/tags_widget.dart';

class ProjectDetail extends StatelessWidget {
  const ProjectDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectModel project = Get.arguments;
    final projectC = Get.find<ProjectViewmodel>();

    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: Obx(() {
        final currentProject = projectC.projectData.firstWhereOrNull(
          (p) => p.id == project.id,
        );

        if (currentProject == null) {
          return const Center(child: Text('Project not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentProject.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                currentProject.subtitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                currentProject.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              const TagsWidget(),
              Text('Images:', style: Theme.of(context).textTheme.titleLarge),
              if (currentProject.imageUrl.isEmpty)
                const Text("No Image")
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
                              currentProject.imageUrl[index].url,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit Tag',
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete Tag',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
