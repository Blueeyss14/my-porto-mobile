import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/project/models/project_model.dart';
import 'package:http/http.dart' as http;

class ProjectViewmodel extends GetxController {
  var projectData = <ProjectModel>[].obs;

  @override
  void onInit() {
    fetchProjects();
    super.onInit();
  }

  Map<String, String> headers = {
    'Authorization': dotenv.env['API_KEY'] ?? '',
    'Content-Type': 'application/json',
  };

  Future<void> fetchProjects() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/projects'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body)['data'];
        projectData.value = result
            .map<ProjectModel>((project) => ProjectModel.fromJson(project))
            .toList();
        projectData.sort((a, b) => a.id.compareTo(b.id));
        Get.snackbar(
          'Success',
          'Category loaded successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch messages: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Fetch exception: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateData(
    int id,
    String newTitle,
    String newDescription,
  ) async {
    try {
      final index = projectData.indexWhere((p) => p.id == id);
      if (index == -1) return;

      final updatedProject = ProjectModel(
        id: projectData[index].id,
        title: newTitle,
        subtitle: projectData[index].subtitle,
        description: newDescription,
        category: projectData[index].category,
        isPinned: projectData[index].isPinned,
        imageUrl: projectData[index].imageUrl,
        tags: projectData[index].tags,
        thumbnail: projectData[index].thumbnail,
        contributing: projectData[index].contributing,
        resources: projectData[index].resources,
      );

      projectData[index] = updatedProject;

      final response = await http.patch(
        Uri.parse('${dotenv.env['BASE_URL']}/projects/$id/'),
        headers: headers,
        body: jsonEncode({'title': newTitle, 'description': newDescription}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar(
          'Success',
          'Project updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to update: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Update exception: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteData(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${dotenv.env['BASE_URL']}/projects/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        projectData.removeWhere((item) => item.id == id);
        Get.snackbar(
          'Success',
          'Message deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Delete exception: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
