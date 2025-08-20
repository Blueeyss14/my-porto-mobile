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
        Get.snackbar('Success', 'Category loaded successfully');
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch messages: ${response.statusCode}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Fetch exception: $e');
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

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.env['BASE_URL']}/projects'),
      );

      request.headers.addAll(multipartHeaders);

      request.fields['title'] = title;
      request.fields['subtitle'] = subtitle;
      request.fields['description'] = description;
      request.fields['category'] = category;
      request.fields['is_pinned'] = isPinned.toString();

      ///THUMBNAIL
      if (thumbnail != null) {
        if ((thumbnail.path ?? '').isNotEmpty) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'thumbnail',
              thumbnail.path!,
              filename: thumbnail.name,
            ),
          );
        } else if (thumbnail.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'thumbnail',
              thumbnail.bytes!,
              filename: thumbnail.name,
            ),
          );
        }
      }

      ///image_url
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (final file in imageFiles) {
          if ((file.path ?? '').isNotEmpty) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'image_url',
                file.path!,
                filename: file.name,
              ),
            );
          } else if (file.bytes != null) {
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
        final errorData = () {
          try {
            return jsonDecode(responseBody);
          } catch (_) {
            return {'message': responseBody};
          }
        }();
        Get.snackbar(
          'Error',
          'Failed to add project: ${errorData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Add project exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> patchProject({
    required int id,
    String? title,
    String? subtitle,
    String? description,
    String? category,
    bool? isPinned,
    PlatformFile? thumbnail, // kirim untuk ganti thumbnail
    List<PlatformFile>? imageFiles, // kirim untuk ganti semua image_url
    List<String>? tags, // kirim [] untuk clear
    List<Map<String, String>>? contributing, // kirim [] untuk clear
    List<Map<String, String>>? resources, // kirim [] untuk clear
  }) async {
    try {
      isLoading.value = true;

      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('${dotenv.env['BASE_URL']}/projects/$id'),
      );

      request.headers.addAll(multipartHeaders);

      // Only send fields that are provided (partial update)
      if (title != null) request.fields['title'] = title;
      if (subtitle != null) request.fields['subtitle'] = subtitle;
      if (description != null) request.fields['description'] = description;
      if (category != null) request.fields['category'] = category;
      if (isPinned != null) request.fields['is_pinned'] = isPinned.toString();

      // Thumbnail: only replaces if you send a new file
      if (thumbnail != null) {
        if ((thumbnail.path ?? '').isNotEmpty) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'thumbnail',
              thumbnail.path!,
              filename: thumbnail.name,
            ),
          );
        } else if (thumbnail.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'thumbnail',
              thumbnail.bytes!,
              filename: thumbnail.name,
            ),
          );
        }
      }

      // Images: backend akan REPLACE semua images jika field ini DIKIRIM
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (final file in imageFiles) {
          if ((file.path ?? '').isNotEmpty) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'image_url',
                file.path!,
                filename: file.name,
              ),
            );
          } else if (file.bytes != null) {
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

      if (tags != null) {
        request.fields['tags'] = jsonEncode(tags);
      }
      if (contributing != null) {
        request.fields['contributing'] = jsonEncode(contributing);
      }
      if (resources != null) {
        request.fields['resources'] = jsonEncode(resources);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Project updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchProjects();
      } else {
        final errorData = () {
          try {
            return jsonDecode(responseBody);
          } catch (_) {
            return {'message': responseBody};
          }
        }();
        Get.snackbar(
          'Error',
          'Failed to update project: ${errorData['error'] ?? errorData['message'] ?? response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Update project exception: $e',
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
      Get.snackbar('Error', 'Error picking image: $e');
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
      Get.snackbar('Error', 'Error picking images: $e');
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
        Get.snackbar('Success', 'Message deleted successfully');
      } else {
        Get.snackbar('Error', 'Failed to delete: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Delete exception: $e');
    }
  }
}
