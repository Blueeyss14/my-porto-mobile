import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/project/models/project_model.dart';
import 'package:my_portfolio/src/features/project/viewmodels/project_viewmodel.dart';
import 'package:my_portfolio/src/features/project/views/widgets/contributing_widget.dart';
import 'package:my_portfolio/src/features/project/views/widgets/description_widget.dart';
import 'package:my_portfolio/src/features/project/views/widgets/images_widget.dart';
import 'package:my_portfolio/src/features/project/views/widgets/resources_widget.dart';
import 'package:my_portfolio/src/features/project/views/widgets/subtitle_widget.dart';
import 'package:my_portfolio/src/features/project/views/widgets/tags_widget.dart';
import 'package:my_portfolio/src/features/project/views/widgets/thumbnail_widget.dart';
import 'package:my_portfolio/src/features/project/views/widgets/title_widget.dart';
import 'package:my_portfolio/src/shared/components/appbar_custom.dart';

class ProjectDetail extends StatelessWidget {
  const ProjectDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectModel project = Get.arguments;
    final projectC = Get.find<ProjectViewmodel>();

    return Scaffold(
      appBar: AppbarCustom(
        title: 'Project Detail',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Obx(() {
              final currentProject = projectC.projectData.firstWhereOrNull(
                (p) => p.id == project.id,
              );

              return Checkbox(
                value: currentProject?.isPinned ?? project.isPinned,
                onChanged: (val) async {
                  await projectC.patchProject(
                    id: project.id,
                    isPinned: val ?? false,
                  );
                },
              );
            }),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await projectC.fetchProjects();
        },
        child: Obx(() {
          final currentProject = projectC.projectData.firstWhereOrNull(
            (p) => p.id == project.id,
          );

          if (currentProject == null) {
            return const Center(child: Text('Project not found'));
          }

          return const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleWidget(),
                SubtitleWidget(),
                DescriptionWidget(),
                ThumbnailWidget(),
                TagsWidget(),
                ImagesWidget(),
                ContributingWidget(),
                ResourcesWidget(),
              ],
            ),
          );
        }),
      ),
    );
  }
}
