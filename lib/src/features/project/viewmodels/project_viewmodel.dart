import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/project/models/project_model.dart';
import 'package:http/http.dart' as http;

class ProjectViewmodel extends GetxController {
  var projectData = <ProjectModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchProjects();
    super.onInit();
  }

  Map<String, String> headers = {
    'Authorization': dotenv.env['API_KEY'] ?? '',
    'Content-Type': 'application/json',
  };
  Map<String, String> multipartHeaders = {
    'Authorization': dotenv.env['API_KEY'] ?? '',
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
            .map<ProjectModel>(
              (project) =>
                  ProjectModel.fromJson(project as Map<String, dynamic>),
            )
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

  Future<void> addProject({
    required String title,
    required String subtitle,
    required String description,
    required String category,
    required bool isPinned,
    PlatformFile? thumbnail,
    List<PlatformFile>? imageFiles,
    List<String>? tags,
    List<Map<String, String>>? contributing,
    List<Map<String, String>>? resources,
  }) async {
    try {
      isLoading.value = true;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.env['BASE_URL']}/projects'),
      );

      request.headers.addAll(multipartHeaders);

      request.fields['title'] = title;
      request.fields['subtitle'] = subtitle;
      request.fields['description'] = description;
      request.fields['category'] = category;
      request.fields['is_pinned'] = isPinned.toString();

      if (thumbnail != null && thumbnail.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'thumbnail',
            thumbnail.bytes!,
            filename: thumbnail.name,
          ),
        );
      }

      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (int i = 0; i < imageFiles.length; i++) {
          final file = imageFiles[i];
          if (file.bytes != null) {
            request.files.add(
              http.MultipartFile.fromBytes(
                'image_url',
                file.bytes!,
                filename: file.name,
              ),
            );
          }
        }
      }

      if (tags != null && tags.isNotEmpty) {
        request.fields['tags'] = jsonEncode(tags);
      }

      if (contributing != null && contributing.isNotEmpty) {
        request.fields['contributing'] = jsonEncode(contributing);
      }

      if (resources != null && resources.isNotEmpty) {
        request.fields['resources'] = jsonEncode(resources);
      }
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Project added successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

        await fetchProjects();
      } else {
        final errorData = jsonDecode(responseBody);
        Get.snackbar(
          'Error',
          'Failed to add project: ${errorData['message'] ?? response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Add project exception: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<PlatformFile?> pickSingleImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error picking image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  Future<List<PlatformFile>?> pickMultipleImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files;
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error picking images: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
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
